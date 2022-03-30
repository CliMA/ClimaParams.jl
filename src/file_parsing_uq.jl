using TOML
using Distributions
using EnsembleKalmanProcesses.ParameterDistributions


# "Public" functions (i.e., functions intended to be called by user):
#    - read_parameters
#    - get_UQ_parameters
#    - get_parameter_distribution
#    - save_parameter_ensemble

"""
read_parameters(path_to_toml_file)

Read parameters from toml file

Args:
`path_to_toml_file` - path of the toml file containing the parameters to be
                      read.
                      See `CLIMAParameters/test/uq_test_parameters.toml` for
                      an example toml file that illustrates the expected
                      format of the parameter information.

Returns a nested dictionary whose keys are the parameter names (= headers of
the toml tables) and whose values are dictionaries containing the corresponding
parameter information (e.g., "prior", "constraint", "value", etc.)
"""
function read_parameters(path_to_toml_file::AbstractString)
    param_dict = TOML.parsefile(path_to_toml_file)
    return param_dict
end


"""
get_parameter_distribution(param_dict, names)

Construct a `ParameterDistribution` from the prior distribution(s) and
constraint(s) given in `param_dict`

Args:
`param_dict` - nested dictionary that has parameter names as keys and the
               corresponding dictionary of parameter information as values
`names` - list of parameter names or single parameter name

Returns a `ParameterDistribution`
"""
function get_parameter_distribution(param_dict::Dict, names::Union{AbstractString, Array{String, 1}})

    names_vec = (typeof(names) <: AbstractVector) ? names : [names]
    n_names = length(names_vec)
    constraint = []
    prior = []
    param_names = []

    for name in names_vec
        # Constructing a parameter distribution requires prior distribution(s),
        # constraint(s), and name(s).
        d = construct_prior(param_dict[name])
        is_array = typeof(d) <: AbstractArray ? true : false
        ((is_array) && (n_names > 1)) ? push!(prior, d...) : push!(prior, d)
        c = construct_constraint(param_dict[name], is_array)
        ((is_array) && (n_names > 1)) ? push!(constraint, c...) : push!(constraint, c)
        # Names can usually be taken directly from the title of the
        # corresponding parameter table in the toml file. However, names
        # have to be generated when the construction of a prameter distribution
        # involves broadcasting of priors / constraints.
        if is_array
            # A broadcast parameter
            push!(param_names, broadcast_name(name, length(d))...)
        else
            # Not a broadcast parameter
            push!(param_names, name)
        end
    end

    if length(vcat(param_names...)) != length(names_vec)
        # The ParameterDistribution contains at least one broadcast parameter 
        # parameters
        if typeof(names) <: AbstractString
            # The broadcast parameter is the only building block of the
            # parameter distribution
            return ParameterDistribution(
                prior[1],
                constraint[1],
                identity.(param_names))
        else
            # The ParaeterDistribution consists of a broadcast parameter and at
            # least one additional parameter
            return ParameterDistribution(
                identity.(prior),
                identity.(constraint),
                identity.(param_names))
        end

    elseif length(param_names) > 1
        # The ParameterDistribution consists of multiple parameters
        return ParameterDistribution(
            identity.(prior),
            identity.(constraint),
            identity.(param_names))
    else
        # The ParameterDistribution consists of a single (non-broadcast)
        # parameter
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
`param_info` - dictionary with (at least) a key "constraint", whose value is
               the parameter's constraint(s) (as parsed from TOML file)

`is_array` - true if this constraint is associated with an array of
             distributions (which typically results from parsing expressions
             of type "repeat([distribution], n_repetitions)"), false otherwise.
             Matters for the `ParameterDistribution` constructor, which
             requires constraints to be given as a list of 1-element lists if
             `is_array` is true (e.g., [[no_constraint()], [no_constraint()]])

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
`param_info` - dictionary with (at least) a key "prior", whose value is the
               parameter's distribution(s) (as parsed from TOML file)

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


"""
broadcast_name(base_name, n_repetitions)

Generates numbered parameter names <base_name>_(<i>); i in 1, ..., n_repetitions
Example:
    broadcast_name("my_param", 3)
    returns ["my_param_(1)", "my_param_(2)", "my_param_(3)"]

Args:
`base_name` - base name to which numbers will be added
`n_repetitions` - number of derived parameter names to generate from `base_name`

Returns an array of length n_repetitions
"""
function broadcast_name(base_name::AbstractString, n_repetitions::Int)

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
`is_array` - true if this constraint is associated with an array of
             distributions (which typically results from parsing expressions
             of type "repeat([distribution], n_repetitions)"), false otherwise.

Returns an array of constraints
"""
function broadcast_constraint(c::Expr, is_array::Bool)

    @assert(c.args[1] == Symbol("repeat"))
    constraint = get_onedim_constraint(c.args[2].args[1])
    n_repetitions  = c.args[3]
    if is_array
        return repeat([[constraint]], n_repetitions)
    else
        return repeat([constraint], n_repetitions)
    end
end


"""
get_multidim_constraints(c)

Parses multidimensional constraints

Args:
`c`  - expression containing the constraint information

Returns an array of `Constraint`s
"""
function get_multidim_constraint(c::Expr)

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


"""
get_onedim_constraints(c)

Parses a one-dimensional constraint

Args:
`c`  - expression containing the constraint information

Returns a `Constraint`
"""
function get_onedim_constraint(c::Expr)

    return getfield(Main, c.args[1])(c.args[2:end]...)
end


"""
broadcast_prior(d)

Constructs an array of constraints or distributions from an expression of
the sort
    "repeat([Parameterized(Gamma(2.0, 3.0))], 50)",
    "repeat([Samples([1.0 1.5 2.0; 0.7 1.2 1.8])], 100)",
    etc.

Args:
`d`  - expression with expr.args[1] == Symbol("repeat")

Returns an array of prior distributions
"""
function broadcast_prior(d::Expr)

    @assert(d.args[1] == Symbol("repeat"))
    prior = get_onedim_prior(d.args[2].args[1])
    n_repetitions  = d.args[3]

    return repeat([prior], n_repetitions)
end


"""
get_multidim_prior(d)

Parses multidimensional prior distributions

Args:
`d`  - expression containing the distribution information

Returns an array of prior distributions (`Parameterized` or `Samples`)
"""
function get_multidim_prior(d::Expr)

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


"""
get_onedim_prior(d)

Parses a one-dimensional prior distributions

Args:
`d`  - expression containing the distribution information

Returns a single prior distributions (`Parameterized` or `Samples`)
"""
function get_onedim_prior(d::Expr)

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
construct_2d_array(arr)

Reconstructs 2d array of samples

Args:
`arr`  - expression (has type `Expr`) with head `vcat`.

Returns a 2d array of samples constructed from the arguments of `expr`
"""
function construct_2d_array(arr::Expr)

    @assert(arr.head == Symbol("vcat"))
    n_rows = length(arr.args)
    arr_of_rows = [arr.args[i].args for i in 1:n_rows]

    return Float64.(vcat(arr_of_rows'...))
end


"""
save_parameter_ensemble(
    param_array,
    param_distribution,
    default_param_data,
    save_path,
    save_file,
    iter=nothing)

Saves the parameters in the given `param_array` to TOML files. The intended
use is for saving the ensemble of parameters after each update of an
ensemble Kalman process.
Each ensemble member (column of `param_array`) is saved in a separate
directory "member_<j>" (j=1, ..., N_ens). The name of the saved toml file is
given by `save_file`; it is the same for all members.
If an iteration `iter` is given, a directory "iteration_<iter>" is created in
`save_path`, which contains all the "member_<j>" subdirectories.

Args:
`param_array` - array of size N_param x N_ens
`param_distribution` - the parameter distribution underlying `param_array`
`default_param_data` - dict of default parameters to be combined and saved with
                       the parameters in `param_array` into a toml file
`save_path` - path to where the parameters will be saved
`save_file` - name of the toml files to be generated
`iter` - the iteration of the ensemble Kalman process represented by the given
         `param_array`
"""
function save_parameter_ensemble(
    param_array::Array{FT, 2},
    param_distribution::ParameterDistribution,
    default_param_data::Dict,
    save_path::AbstractString,
    save_file::AbstractString,
    iter::Union{Int, Nothing}=nothing) where {FT}

    # The parameter values are currently in the unconstrained space
    # where the ensemble Kalman algorithm takes place
    save_array = transform_unconstrained_to_constrained(
        param_distribution,
        param_array)

    # The number of rows in param_array represent the sum of all parameter
    # dimensions. We need to determine the slices of rows that belong to
    # each parameter. E.g., an array with 6 rows could be sliced into
    # one 1-dim parameter (first row), one 3-dim parameter (rows 2 to 4),
    # and a 2-dim parameter (rows 5 to 6)
    param_slices = batch(param_distribution)
    param_names = get_name(param_distribution)

    N_ens = size(save_array)[2]

    # If needed, create directory where files will be stored
    save_dir = isnothing(iter) ? save_path : joinpath(save_path, join(["iteration", lpad(iter, 2, "0")], "_"))
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

        param_dict_updated = assign_values!(
            i,
            save_array,
            param_distribution,
            param_slices,
            param_dict,
            param_names)

        open(joinpath(save_dir, subdir_names[i], toml_file), "w") do io
            TOML.print(io, param_dict_updated)
        end
    end
end


"""
assign_values!(member, param_array, param_distribution, param_slices,
param_dict, param_names)

Updates `param_dict` with the values of the given `member` of the `param_array`

Args:
`member`  - ensemble member (corresponds to column of `param_array`)
`param_array` - N_par x N_ens array of parameter values
`param_distribution` - the parameter distribution underlying `param_array`
`param_slices` - list of contiguous `[collect(1:i), collect(i+1:j),... ]` used
                 to split parameter arrays by distribution dimensions
`param_dict` - the dict of parameters to be updated with new parameter values
`param_names` - names of the parameters

Returns the updated `param_dict`
"""
function assign_values!(
    member::Int,
    param_array::Array{FT,2},
    param_distribution::ParameterDistribution,
    param_slices::Array{Array{Int64,1},1},
    param_dict::Dict,
    param_names::Array{String}) where {FT}
    
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


function is_broadcast(param_name::AbstractString)

    if endswith(param_name, ")") && occursin("_(", param_name)
        return true
    else
        return false
    end
end


function merge_names(param_names::Union{AbstractString, Array{String, 1}})

    base_names = first.(split.(param_names, "_("))

    return unique!(base_names)
end


function get_base_name(param_name::Union{AbstractString, Array{String, 1}})

    base_param_name = first.(split.(param_name, "_("))

    return unique!(base_param_name)
end


"""
merge_slices(param_slices, broadcast_mask)

Merges the slices that belong to broadcast parameters. When writing parameters
to file, we want to write e.g.
    [param_i]
    value = [1.0, 1.5, 0.5, 0.8]
    prior = "repeat([Parameterized(Normal(1.0, 0.5)], 4)"
    constraint = "repeat([no_constraint()], 4)"

rather than to write each of the four individual "subparameters" `param_i` gets
broadcast to internally (`param_i_(1)`, `param_i_(2)`, `param_i_(3)`,
`param_i_(4)`). This requires merging of the single-dimension parameter slices
corresponding to these subparameters back into one 4-element slice

Args:
`param_slices` - array of contiguous `[collect(1:i), collect(i+1:j),... ]` used
                 to split parameter arrays by distribution dimensions
`broadcast_mask` - boolean array whose jth element is true if the jth parameter
                   is broadcast, false otherwise

Returns an array of contiguous `[collect(1:i), collect(i+1:j),... ]` used to
split parameter arrays by distribution dimensions, where the dimensions of 
broadcast parameters have been merged into a single slice.
"""
function merge_slices(param_slices::Union{Array{Int, 1}, Array{Array{Int, 1}, 1}}, broadcast_mask::Array{Bool, 1})

    @assert(length(param_slices) == length(broadcast_mask))

    merge_slices = [] # slices to be merged
    for j in 1:length(broadcast_mask)
        if broadcast_mask[j]
            if j == 1 || !broadcast_mask[j-1]
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


"""
generate_subdir_names(N_ens, prefix="member")

Generates `N_ens` directory names "<prefix>_<i>"; i=1, ..., N_ens

Args:
`N_ens`  - number of ensemble members (= number of subdirectories)
`prefix` - prefix used for generation of subdirectory names

Returns a list of directory names
"""
function generate_subdir_names(N_ens::Int, prefix::AbstractString="member")

    member(j) = join([prefix, lpad(j, ndigits(N_ens), "0")], "_")

    return [member(j) for j in 1:N_ens]
end


"""
get_UQ_parameters(param_dict)

Finds all UQ parameters in `param_dict`.

Args:
`param_dict` - nested dictionary that has parameter names as keys and the
               corresponding dictionaries of parameter information as values

Returns an array of the names of all UQ parameters in `param_dict`.
UQ parameters are those parameters that have a key "prior" whose value is not
set to "fixed". They will enter the uncertainty quantification pipeline.
"""
function get_UQ_parameters(param_dict::Dict)

    uq_param = String[]

    for (key, val) in param_dict
        if haskey(val, "prior") && val["prior"] != "fixed"
            push!(uq_param, string(key))
        end
    end

    return uq_param
end
