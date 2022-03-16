using Distributions
using EnsembleKalmanProcesses.ParameterDistributions


get_parameter_distribution(param_set::ParamDict{FT}, names) where {FT} =
    get_parameter_distribution(param_set.data, names)

"""
get_parameter_distribution(data, names)

Construct a `ParameterDistribution` from the prior distribution and
constraint given in `data`

Args:
`data` - nested dictionary that has parameter names as keys and the
          corresponding dictionary of parameter information as values
`names` - list of parameter names or single parameter name

Returns a `ParameterDistribution`
"""
function get_parameter_distribution(data::Dict, names)
    names_vec = (typeof(names) <: AbstractVector) ? names : [names]
    param_distr = []

    for name in names_vec
        # Constructing a parameter distribution requires prior distribution(s)
        # and constraint(s)
        constraint = construct_constraint(data[name])
        prior = construct_prior(data[name])
        if !haskey(data[name], "name")
            # Try using the name of the TOML table describing the parameter
            push!(
                param_distr,
                ParameterDistribution(prior, constraint, name)
            )
        else
            # Use the given "name" entry
            push!(
                param_distr,
                ParameterDistribution(prior, constraint, data[name]["name"])
            )
        end

    end

    return (typeof(names) <: AbstractVector) ? param_distr : param_distr[1]

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


"""
save_parameter_ensemble(param_array, param_name, save_path, iteration=nothing)

Saves the parameters in the given `param_array` to TOML files. The intended
use is for saving the ensemble of parameters after each update of an
ensemble Kalman process.
Each ensemble member (column of `param_array`) is saved to a separate file
named "member_<i>.toml" (i=1, ..., N_ens). If an `iteration` number is
given, a directory "iteration_<j>" is created in `save_path`, and all
member files are saved there.

Args:
`param_array` - array of size N_param x N_ens
`param_name` - array of parameter names or single parameter name
`save_path` - path to where the parameters will be saved
`iteration` - which iteration of the ensemble Kalman process the given
              `param_array` represents.
"""
function save_parameter_ensemble(param_array::Array{FT, 2}, param_name, save_path::String, iteration::Union{Int, Nothing}=nothing) where {FT}
    N_par, N_ens = size(param_array)
    file_names = generate_file_names(N_ens)

    # If needed, create directory where files will be stored
    save_dir = isnothing(iteration) ? save_path : joinpath(save_path, join(["iteration", lpad(iteration, 2, "0")], "_"))
    mkpath(save_dir)

    for i in 1:N_ens
        open(joinpath(save_dir, file_names[i]), "w") do io
        for j in 1:N_par
            param_info = Dict(
                "value" => param_array[j, i],
                "name" => param_name[j]
            )
            param_dict = Dict(param_name[j] => param_info)
            TOML.print(io, param_dict)
            print(io, "\n")
        end
        end
    end
end

function generate_file_names(N_ens::Int, prefix::String="member", suffix="toml")
    max_n_digits = Int(ceil(log10(N_ens)))
    member(j) = join([prefix, lpad(j, max_n_digits, "0")], "_")
    return [join([member(j), suffix], ".") for j in 1:N_ens]
end
           
