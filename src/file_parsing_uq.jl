using Distributions
using EnsembleKalmanProcesses.ParameterDistributionStorage


get_parameter_distribution(param_set::ParamDict{FT}, names) where {FT} =
    get_parameter_distribution(param_set.data, names)

function get_parameter_distribution(data::Dict, names)
    """
    get_parameter_distribution(data, names)

    Construct a `ParameterDistribution` from the prior distribution and
    constraint given in `data`
    """
    names_vec = (typeof(names) <: AbstractVector) ? names : [names]
    param_distr = []

    for name in names_vec
        # Constructing a parameter distribution requires prior distribution(s)
        # and constraint(s)
        constraint = construct_constraint(data[name])
        prior = construct_prior(data[name])
        push!(param_distr, ParameterDistribution(prior, constraint, name))
    end

    return (typeof(names) <: AbstractVector) ? param_distr : param_distr[1]
end

function construct_constraint(param_info::Dict)
    """
    construct_constraint(param_info)

    Extracts information on type and arguments of each constraint and uses that
    information to construct an actual `Constraint`.
    Returns a single `Constraint` if `param_set` only contains one constraint,
    otherwise it returns an array of `Constraint`s
    """
    @assert(haskey(param_info, "constraint"))
    c = Meta.parse(param_info["constraint"])
    if c.head == Symbol("vect")
        # Multiple constraints
        n_constraints = length(c.args)
        constraints = Array{Constraint}(undef, n_constraints)
        for i in range(1, stop=n_constraints)
            constraints[i] = 
                getfield(Main, c.args[i].args[1])(c.args[i].args[2:end]...)
        end
        return constraints
    else
        # Single constraint
        return getfield(Main, c.args[1])(c.args[2:end]...)
    end
end

function construct_prior(param_info::Dict)
    """
    construct_prior(param_info)

    Extracts information on type and arguments of the prior distribution and use
    that information to construct an actual `Distribution`
    Returns a single or array of ParameterDistributionType derived objects
    """
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


function construct_2d_array(expr)
    """
    construct_2d_array(expr)

    Reconstructs 2d array of samples
    `expr` is an expression (has type `Expr`) and a head `vcat`.
    Returns a 2d array of samples constructed from the arguments of `expr`
    """
    @assert(expr.head == Symbol("vcat"))
    n_rows = length(expr.args)
    arr_of_rows = [expr.args[i].args for i in 1:n_rows]

    return Float64.(vcat(arr_of_rows'...))
end


