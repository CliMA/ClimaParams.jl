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
    n_names = length(names_vec)
    constraint = []
    prior = []
    param_names = []

    for name in names_vec
        # Constructing a parameter distribution requires prior distribution(s),
        # constraint(s), and name(s).
        d = construct_prior(data[name])
        is_array = typeof(d) <: AbstractArray ? true : false
        ((is_array) && (n_names > 1)) ? push!(prior, d...) : push!(prior, d)
        c = construct_constraint(data[name], is_array)
        ((is_array) && (n_names > 1)) ? push!(constraint, c...) : push!(constraint, c)
        # Names can usually be taken directly from the title of the
        # corresponding parameter table in the toml file. However, names
        # have to be generated when the construction of a prameter distribution
        # involves broadcasting of priors / constraints.
        if is_array
            # A broadcast parameter
            push!(param_names, construct_name(name, length(d))...)
        else
            # Not a broadcast parameter
            push!(param_names, name)
        end
    end

    if length(vcat(param_names...)) != length(names_vec)
        # This parameter was broadcast
        if typeof(names) <: AbstractString
            # The broadcast parameter is the only building block of the
            # requested parameter distribution
            return ParameterDistribution(
                prior[1],
                constraint[1],
                identity.(param_names))
        else
            # The requested parameter distribution consists of a broadcast
            # parameter and at least one additional parameter
            return ParameterDistribution(
                identity.(prior),
                identity.(constraint),
                identity.(param_names))
        end

    elseif length(param_names) > 1
        return ParameterDistribution(
            identity.(prior),
            identity.(constraint),
            identity.(param_names))
    else
        return ParameterDistribution(
            prior[1],
            constraint[1],
            param_names[1])
    end
end


"""
construct_constraint(param_info, is_array)

Extracts information on type and arguments of each constraint and uses that
information to construct an actual `Constraint`.

Args:
`param_info` - a dictionary with (at least) a key "constraint", whose
                value is the parameter's constraint(s) (as parsed from
                TOML file)

Returns a single `Constraint` if `param_info` only contains one constraint,
otherwise it returns an array of `Constraint`s
"""
function construct_constraint(param_info::Dict, is_array::Bool)

    @assert(haskey(param_info, "constraint"))
    c = Meta.parse(param_info["constraint"])

    if c.args[1] == Symbol("repeat")
        # There are multiple constraints described by an expression of the
        # form "repeat([constraint], n_repetitions)"
        return broadcast_constraint(c, is_array)

    elseif c.head == Symbol("vect")
        # There are multiple parameters, hence multiple constraints
        return get_multidim_constraint(c)

    else
        # There is only a single 1-dim parameter, hence a single constraint
        return get_onedim_constraint(c)
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

    if d.args[1] == Symbol("repeat")
        # There are multiple distributions described by an expression of the
        # form "repeat([distribution], n_repetitions)"
        return broadcast_prior(d)

    elseif d.head == Symbol("vect")
        # Multiple distributions
        return get_multidim_prior(d)

    else
        # Single distribution
        return get_onedim_prior(d)
    end
end

function construct_name(base_name::String, n_repetitions::Int)

    param_name(j) = base_name * "_(" * lpad(j,ndigits(n_repetitions), "0") * ")"

    return [param_name(j) for j in 1:n_repetitions]
end

"""
broadcast_constraint(expr, is_array)

Constructs an array of constraints from an expression of the sort
    "repeat([no_constraint], 10)",
    "repeat([bounded_below(0.3)], 100),
    etc.

Args:
`expr`  - expression with expr.args[1] == Symbol("repeat")


Returns an array of constraints
"""
function broadcast_constraint(c, is_array)

    @assert(c.args[1] == Symbol("repeat"))
    constraint = get_onedim_constraint(c.args[2].args[1])
    n_repetitions  = c.args[3]
    if is_array
        return repeat([[constraint]], n_repetitions)
    else
        return repeat([constraint], n_repetitions)
    end
end


function get_multidim_constraint(c)

    constraints = []
    constraint_groups = c.args
    n_constraint_groups = length(c.args)

    for i in 1:n_constraint_groups

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
                      constraint_groups[i].args[2:end]...))
        end
    end

    return [constraints[i] for i in 1:length(constraints)]
end


function get_onedim_constraint(c)

    return getfield(Main, c.args[1])(c.args[2:end]...)
end


"""
broadcast_prior(expr)

Constructs an array of constraints or distributions from an expression of
the sort
    "repeat([Parameterized(Gamma(2.0, 3.0))], 50)",
    "repeat([Samples([1.0 1.5 2.0; 0.7 1.2 1.8])], 100)",
    etc.

Args:
`expr`  - expression with expr.args[1] == Symbol("repeat")

Returns an array of prior distributions
"""
function broadcast_prior(d)

    @assert(d.args[1] == Symbol("repeat"))
    prior = get_onedim_prior(d.args[2].args[1])
    n_repetitions  = d.args[3]

    return repeat([prior], n_repetitions)
end


function get_multidim_prior(d)

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
end


function get_onedim_prior(d)

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

        param_dict_updated = assign_values(
            i,
            param_array,
            param_slices,
            param_dict,
            param_names)

        open(joinpath(save_dir, subdir_names[i], toml_file), "w") do io
            TOML.print(io, param_dict_updated)
        end
    end
end

function assign_values(member::Int,
                       param_array::Array{FT,2},
                       param_slices::Array{Array{Int64,1},1},
                       param_dict::Dict,
                       param_names::Array{String,1}) where {FT}

    broadcast_mask = repeat([false], length(param_names))
    param_names_vec = typeof(param_names) <: AbstractVector ? param_names : [param_names]

    for j in 1:length(param_names_vec)

        if is_broadcast(param_names_vec[j])
            broadcast_mask[j] = true
        end
    end

    merged_param_slices = merge_slices(param_slices, broadcast_mask)
    merged_param_names = merge_names(param_names_vec)

    for (j, slice) in enumerate(merged_param_slices)
        value = length(slice) > 1 ? param_array[slice, member] : param_array[slice, member][1]
        param_dict[merged_param_names[j]]["value"] = value
    end

    return param_dict
end

function is_broadcast(param_name)

    if endswith(param_name, ")") && occursin("_(", param_name)
        return true
    else
        return false
    end
end

function merge_names(param_names)

    base_names = first.(split.(param_names, "_("))

    return unique!(base_names)
end

function get_base_name(name)

    base_name = first.(split.(name, "_("))

    return unique!(base_name)
end


"""
merge_slices(param_slices, broadcast_mask)

Merges the slices that belong to broadcast parameters. When writing
parameters to file, we want to write e.g.
    [param_i]
    value = [1.0, 1.5, 0.5, 0.8]
    prior = "repeat([Parameterized(Normal(1.0, 0.5)], 4)"
    constraint = "repeat([no_constraint()], 4)"

rather than to write `param_i` as the four individual "subparameters"
it gets broadcast to internally (`param_i_(1)`, `param_i_(2)`, `param_i_(3)`,
`param_i_(4)`. This requires merging of the single-dimension parameter slices
corresponding to these subparameters back into one 4-element slice
"""
function merge_slices(param_slices, broadcast_mask)

    @assert(length(param_slices) == length(broadcast_mask))

    merge_slices = [] # slices to be merged
    for j in 1:length(broadcast_mask)
        if broadcast_mask[j]
            if j == 0 || !broadcast_mask[j-1]
                push!(merge_slices, deepcopy(param_slices[j]))
            else
                push!(merge_slices[end], deepcopy(param_slices[j][1]))
            end
        end
    end

    if isempty(merge_slices)
        # No broadcasting involved
        return param_slices
    else
        combined_slices = sort(vcat(param_slices, merge_slices))
        delete_indices = []
        all_merged_indices = vcat(merge_slices...)

        for (i, slice) in enumerate(combined_slices)
            if (length(slice) == 1) && (slice[1] in all_merged_indices)
                push!(delete_indices, i)
            end
        end


        return deleteat!(combined_slices, delete_indices)
    end
end


function generate_subdir_names(N_ens::Int, prefix::String="member")

    member(j) = join([prefix, lpad(j, ndigits(N_ens), "0")], "_")

    return [member(j) for j in 1:N_ens]
end


get_UQ_parameters(param_set::ParamDict{FT}) where {FT} = get_UQ_parameters(param_set.data)

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
function get_UQ_parameters(data::Dict)

    uq_param = String[]

    for (key, val) in data
        if haskey(val, "prior") && val["prior"] != "fixed"
            push!(uq_param, string(key))
        end
    end

    return uq_param
end
