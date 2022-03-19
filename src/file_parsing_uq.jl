using Distributions
using EnsembleKalmanProcesses.ParameterDistributions


get_parameter_distribution(param_set::ParamDict{FT}, names) where {FT} =
    get_parameter_distribution(param_set.data, names)

"""
get_parameter_distribution(data, names)

Construct a `ParameterDistribution` from the prior distribution(s) and
constraint(s) given in `data`

Args:
`data` - nested dictionary that has parameter names as keys and the
          corresponding dictionary of parameter information as values
`names` - list of parameter names or single parameter name

Returns a `ParameterDistribution`
"""
function get_parameter_distribution(data::Dict, names)

    names_vec = (typeof(names) <: AbstractVector) ? names : [names]
    constraint = []
    prior = []

    for name in names_vec
        # Constructing a parameter distribution requires prior distribution(s)
        # and constraint(s)
        push!(constraint, construct_constraint(data[name]))
        push!(prior, construct_prior(data[name]))
    end
        # Use the name of the TOML table describing the parameter
    if typeof(names) <: AbstractVector
        return ParameterDistribution(
            identity.(prior),
            identity.(constraint),
            names)
    else
        return ParameterDistribution(prior[1],
                                     constraint[1],
                                     names)
    end
end


"""
construct_constraint(param_info)

Extracts information on type and arguments of each constraint and uses that
information to construct an actual `Constraint`.

Args:
`param_info` - a dictionary with (at least) a key "constraint", whose
                value is the parameter's constraint(s) (as parsed from
                TOML file)

Returns a single `Constraint` if `param_info` only contains one constraint,
otherwise it returns an array of `Constraint`s
"""
function construct_constraint(param_info::Dict)
    @assert(haskey(param_info, "constraint"))
    c = Meta.parse(param_info["constraint"])
    if c.head == Symbol("vect")
        # There are multiple parameters, hence multiple constraints
        constraints = []
        constraint_groups = c.args 
        n_constraint_groups = length(c.args)

        for i in 1:n_constraint_groups
            # The dimensionality of the parameter equals the number of
            # constraints
            if constraint_groups[i].head == Symbol("vect")
                # This is a multidimensional parameter
                n_param_constraints = length(constraint_groups[i].args)
                param_constraints = []
                for j in 1:n_param_constraints
                    push!(
                        param_constraints,
                        getfield(Main, constraint_groups[i].args[j].args[1])(
                            constraint_groups[i].args[j].args[2:end]...)
                    )
                end
                push!(constraints, param_constraints)
            else
                # This is a single parameter
                push!(constraints,
                      getfield(Main, constraint_groups[i].args[1])(
                          constraint_groups[i].args[2:end]...)
                )
            end
        end

        return [constraints[i] for i in 1:length(constraints)]

    else
        # There is only a single 1-dim parameter, hence a single constraint
        return getfield(Main, c.args[1])(c.args[2:end]...)
    end
end


"""
construct_prior(param_info)

Extracts information on type and arguments of the prior distribution and use
that information to construct an actual `Distribution`

Args:
`param_info` - a dictionary with (at least) a key "prior", whose
                value is the parameter's distribution(s) (as parsed from
                TOML file)

Returns a single or array of ParameterDistributionType derived objects
"""
function construct_prior(param_info::Dict)
    @assert(haskey(param_info, "prior"))
    d = Meta.parse(param_info["prior"])
    if d.head == Symbol("vect")
        # Multiple distributions
        n_distributions = length(d.args)
        distributions = Array{ParameterDistributionType}(undef, n_distributions)

        for i in range(1, stop=n_distributions)
            dist_type_symb = d.args[i].args[1]
            dist_type = getfield(Main, dist_type_symb)

            if dist_type_symb == Symbol("Parameterized")
                dist = getfield(Main, d.args[i].args[2].args[1])
                dist_args = d.args[i].args[2].args[2:end]
                distributions[i] = dist_type(dist(dist_args...))

            elseif dist_type_symb == Symbol("Samples")
                dist_args = construct_2d_array(d.args[i].args[2])
                distributions[i] = dist_type(dist_args)

            else
                throw(error("Unknown distribution type ", dist_type))
            end
        end

        return distributions

    else
        # Single distribution
        dist_type_symb = d.args[1]
        dist_type = getfield(Main, dist_type_symb)
        if dist_type_symb == Symbol("Parameterized")
            dist = getfield(Main, d.args[2].args[1])
            dist_args = d.args[2].args[2:end]
            return dist_type(dist(dist_args...))

        elseif dist_type_symb == Symbol("Samples")
            dist_args = construct_2d_array(d.args[2])
            return dist_type(dist_args)
        else
            throw(error("Unknown distribution type ", dist_type))
        end
    end
end


"""
construct_2d_array(expr)

Reconstructs 2d array of samples

Args:
`expr`  - expression (has type `Expr`) with head `vcat`.

Returns a 2d array of samples constructed from the arguments of `expr`
"""
function construct_2d_array(expr)
    @assert(expr.head == Symbol("vcat"))
    n_rows = length(expr.args)
    arr_of_rows = [expr.args[i].args for i in 1:n_rows]

    return Float64.(vcat(arr_of_rows'...))
end


save_parameter_ensemble(param_array::Array{FT, 2}, param_distribution::ParameterDistribution, default_param_set::ParamDict{FT}, save_path::String, save_file::String, iteration::Union{Int, Nothing}=nothing) where {FT} = save_parameter_ensemble(param_array, param_distribution, default_param_set.data, save_path, save_file, iteration)
"""
save_parameter_ensemble(
    param_array,
    param_distribution,
    default_param_data,
    save_path,
    save_file,
    iteration=nothing)

Saves the parameters in the given `param_array` to TOML files. The intended
use is for saving the ensemble of parameters after each update of an
ensemble Kalman process.
Each ensemble member (column of `param_array`) is saved to a separate file
named "member_<i>.toml" (i=1, ..., N_ens). If an `iteration` number is
given, a directory "iteration_<j>" is created in `save_path`, and all
member files are saved there.

Args:
`param_array` - array of size N_param x N_ens
`names` - array of parameter names or single parameter name
`save_path` - path to where the parameters will be saved
`iteration` - which iteration of the ensemble Kalman process the given
              `param_array` represents.
"""
function save_parameter_ensemble(
    param_array::Array{FT, 2},
    param_distribution::ParameterDistribution,
    default_param_data::Dict,
    save_path::String,
    save_file::String,
    iteration::Union{Int, Nothing}=nothing) where {FT}

    # The number of rows in param_array represent the sum of all parameter
    # dimensions. We need to determine the slices of rows that belong to
    # each parameter. E.g., an array with 6 rows could be sliced into
    # one 1-dim parameter (first row), one 3-dim parameter (rows 2 to 4),
    # and a 2-dim parameter (rows 5 to 6)
    param_slices = batch(param_distribution)
    param_names = get_name(param_distribution)

    N_ens = size(param_array)[2]

    # If needed, create directory where files will be stored
    save_dir = isnothing(iteration) ? save_path : joinpath(save_path, join(["iteration", lpad(iteration, 2, "0")], "_"))
    mkpath(save_dir)

    # Each ensemble member gets its own subdirectory
    subdir_names = generate_subdir_names(N_ens)

    # All parameter toml files (one for each ensemble member) have the same name
    toml_file = endswith(save_file, ".toml") ? save_file : save_file * ".toml"

    for i in 1:N_ens
        mkpath(joinpath(save_dir, subdir_names[i]))
        # Override the value (or add a value, if no value exists yet)
        # of the parameter in the original parameter dict with the
        # corresponding value in param_array
        param_dict = deepcopy(default_param_data)
        for (j, slice) in enumerate(param_slices)
            value = length(slice) > 1 ? param_array[slice, i] : param_array[slice, i][1]
            param_dict[param_names[j]]["value"] = value
        end
        open(joinpath(save_dir, subdir_names[i], toml_file), "w") do io
            TOML.print(io, param_dict)
        end
    end
end


function generate_subdir_names(N_ens::Int, prefix::String="member")
    max_n_digits = Int(ceil(log10(N_ens)))
    member(j) = join([prefix, lpad(j, max_n_digits, "0")], "_")
    return [member(j) for j in 1:N_ens]
end

"""
get_UQ_parameters(data)

Finds all parameters in data that have a key "prior" that isn't set to "fixed".
These are the parameters that will enter the uncertainty quantification
pipeline.

Args:
`data` - nested dictionary that has parameter names as keys and the
         corresponding dictionary of parameter information as values

Returns an array of the names of all UQ parameters in data
"""
get_UQ_parameters(param_set::ParamDict{FT}) where {FT} = get_UQ_parameters(param_set.data)

function get_UQ_parameters(data::Dict)
    uq_param = String[]
    for (key, val) in data
        if haskey(val, "prior") && val["prior"] != "fixed"
            push!(uq_param, string(key))
        end
    end
    return uq_param
end
