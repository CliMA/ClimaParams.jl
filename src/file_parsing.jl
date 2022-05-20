"""
    AbstractTOMLDict{FT <: AbstractFloat}

Abstract parameter dict. Two subtypes:
 - [`ParamDict`](@ref)
 - [`AliasParamDict`](@ref)
"""
abstract type AbstractTOMLDict{FT <: AbstractFloat} end

const NAMESTYPE =
    Union{AbstractVector{S}, NTuple{N, S} where {N}} where {S <: AbstractString}

"""
    ParamDict(data::Dict, override_dict::Union{Nothing,Dict})

Structure to hold information read-in from TOML
file, as well as a parametrization type `FT`.

Uses the name to search

# Fields

$(DocStringExtensions.FIELDS)
"""
struct ParamDict{FT} <: AbstractTOMLDict{FT}
    "dictionary representing a default/merged parameter TOML file"
    data::Dict
    "either a nothing, or a dictionary representing an override parameter TOML file"
    override_dict::Union{Nothing, Dict}
end

"""
    AliasParamDict(data::Dict, override_dict::Union{Nothing,Dict})

Structure to hold information read-in from TOML
file, as well as a parametrization type `FT`.

Uses the alias to search

# Fields

$(DocStringExtensions.FIELDS)
"""
struct AliasParamDict{FT} <: AbstractTOMLDict{FT}
    "dictionary representing a default/merged parameter TOML file"
    data::Dict
    "either a nothing, or a dictionary representing an override parameter TOML file"
    override_dict::Union{Nothing, Dict}
    "Alias->name map"
    alias_to_name_map::Dict
    function AliasParamDict{FT}(
        data::Dict,
        override_dict::Union{Nothing, Dict},
    ) where {FT}
        alias_to_name_map = Dict(map(collect(keys(data))) do key
            Pair(data[key]["alias"], key)
        end)
        return new{FT}(data, override_dict, alias_to_name_map)
    end
end


"""
    float_type(::AbstractTOMLDict)

The float type from the parameter dict.
"""
float_type(::AbstractTOMLDict{FT}) where {FT} = FT

function Base.iterate(pd::AliasParamDict)
    it = iterate(pd.data)
    if it !== nothing
        return (Pair(it[1].second["alias"], it[1].second), it[2])
    else
        return nothing
    end
end

function Base.iterate(pd::AliasParamDict, state)
    it = iterate(pd.data, state)
    if it !== nothing
        return (Pair(it[1].second["alias"], it[1].second), it[2])
    else
        return nothing
    end
end

Base.iterate(pd::ParamDict, state) = Base.iterate(pd.data, state)
Base.iterate(pd::ParamDict) = Base.iterate(pd.data)

Base.getindex(pd::ParamDict, i) = getindex(pd.data, i)
Base.getindex(pd::AliasParamDict, i) =
    getindex(pd.data, pd.alias_to_name_map[i])

"""
    log_component!(pd::AbstractTOMLDict, names, component)

Adds a new key,val pair: `("used_in",component)` to each
named parameter in `pd`.
Appends a new val: `component` if "used_in" key exists.
"""
function log_component!(
    pd::AliasParamDict,
    names::NAMESTYPE,
    component::AbstractString,
)
    component_key = "used_in"
    data = pd.data
    for name in names
        for (key, val) in data
            name ≠ val["alias"] && continue
            data[key][component_key] = if component_key in keys(data[key])
                unique([data[key][component_key]..., component])
            else
                [component]
            end
        end
    end
end

function log_component!(
    pd::ParamDict,
    names::NAMESTYPE,
    component::AbstractString,
)
    component_key = "used_in"
    data = pd.data
    for name in names
        for (key, val) in data
            name ≠ key && continue
            data[key][component_key] = if component_key in keys(data[key])
                unique([data[key][component_key]..., component])
            else
                [component]
            end
        end
    end
end

"""
    _get_typed_value(pd, val, valname, valtype)

enforces `val` to be of type as specified in the toml file
- `float_type(pd)` if type=\"float\"
- `Int` if type=\"integer\"
- `String` if  type=\"string\"
Default type of `String` is used if no type is provided.
"""
function _get_typed_value(
    pd::AbstractTOMLDict,
    val,
    valname::AbstractString,
    valtype,
)

    if valtype == "float"
        return float_type(pd)(val)
    elseif valtype == "integer"
        return Int(val)
    elseif valtype == "string"
        return String(val)
    else
        error(
            "For parameter with identifier: \"",
            valname,
            "\", the attribute: type = \"",
            valtype,
            "\", is not recognised, ",
            "\n please select from: type = \"string\", \"float\", or \"integer\" ",
        )
    end
end



"""
    get_values(pd::AbstractTOMLDict, names)

gets the `value` of the named parameters.
"""
function get_values(pd::AliasParamDict, aliases::NAMESTYPE)
    data = pd.data
    # TODO: use map
    ret_values = []
    for alias in aliases
        for (key, val) in data
            alias ≠ val["alias"] && continue
            param_value = val["value"]
            param_type = haskey(val, "type") ? val["type"] : "string"
            elem =
                isa(param_value, AbstractVector) ?
                map(
                    x -> _get_typed_value(pd, x, alias, param_type),
                    param_value,
                ) : _get_typed_value(pd, param_value, alias, param_type)
            push!(ret_values, Pair(Symbol(alias), elem))
        end
    end
    return ret_values
end

function get_values(pd::ParamDict, names::NAMESTYPE)
    data = pd.data
    ret_values = map(names) do name
        param_value = data[name]["value"]
        param_type =
            haskey(data[name], "type") ? data[name]["type"] : "string"
        elem =
            isa(param_value, AbstractVector) ?
            map(x -> _get_typed_value(pd, x, name, param_type), param_value) : _get_typed_value(pd, param_value, name, param_type)
        Pair(Symbol(name), elem)
    end
    return ret_values
end

"""
    get_parameter_values!(
        pd::AbstractTOMLDict,
        names::Union{String,Vector{String}},
        component::String
    )

(Note the `!`) Gets the parameter values, and logs
the component (if given) where parameters are used.
"""
function get_parameter_values!(
    pd::AbstractTOMLDict,
    names::NAMESTYPE,
    component::Union{AbstractString, Nothing} = nothing,
)
    if !isnothing(component)
        log_component!(pd, names, component)
    end
    return get_values(pd, names)
end

get_parameter_values!(
    pd::AbstractTOMLDict,
    names::AbstractString,
    args...;
    kwargs...,
) = first(get_parameter_values!(pd, [names], args..., kwargs...))

"""
    get_parameter_values(pd::AbstractTOMLDict, names)

Gets the parameter values only.
"""
get_parameter_values(
    pd::AbstractTOMLDict,
    names::Union{NAMESTYPE, AbstractString},
) = get_parameter_values!(pd, names, nothing)

"""
    check_override_parameter_usage(pd::ParamDict, strict)

Checks if parameters in the ParamDict.override_dict have the
key "used_in" (i.e. were these parameters used within the model run).
Throws warnings in each where parameters are not used. Also throws
an error if `strict == true` .
"""
check_override_parameter_usage(pd::AbstractTOMLDict, strict::Bool) =
    check_override_parameter_usage(pd, strict, pd.override_dict)

check_override_parameter_usage(pd::AbstractTOMLDict, strict::Bool, ::Nothing) =
    nothing

function check_override_parameter_usage(
    pd::AbstractTOMLDict,
    strict::Bool,
    override_dict,
)
    unused_override = Dict()
    for (key, val) in override_dict
        logged_val = pd.data[key]
        unused_override[key] = !("used_in" in keys(logged_val))
    end
    if any(values(unused_override))
        unused_override_keys = collect(keys(unused_override))
        filter!(key -> unused_override[key], unused_override_keys)
        @warn(
            string(
                "Keys are present in parameter file but not used",
                "in the simulation. \n Typically this is due to",
                "a mismatch in parameter name in toml and in source.",
                "Offending keys: $(unused_override_keys)",
            )
        )
        if strict
            @error(
                "At least one override parameter set and not used in simulation"
            )
            error(
                "Halting simulation due to unused parameters." *
                "\n Typically this is due to a typo in the parameter name." *
                "\n change `strict` flag to `true` to prevent this causing an exception",
            )
        end
    end
    return nothing
end

"""
    write_log_file(pd::AbstractTOMLDict, filepath)

Writes a log file of all used parameters of `pd` at
the `filepath`. This file can be used to rerun the experiment.
"""
function write_log_file(pd::AbstractTOMLDict, filepath::AbstractString)
    used_parameters = Dict()
    for (key, val) in pd.data
        if "used_in" in keys(val)
            used_parameters[key] = val
        end
    end
    open(filepath, "w") do io
        TOML.print(io, used_parameters)
    end
end


"""
    log_parameter_information(
        pd::AbstractTOMLDict,
        filepath;
        strict::Bool = false
    )

Writes the parameter log file at `filepath`; checks that
override parameters are all used.

If `strict = true`, errors if override parameters are unused.
"""
function log_parameter_information(
    pd::AbstractTOMLDict,
    filepath::AbstractString;
    strict::Bool = false,
)
    #[1.] write the parameters to log file
    write_log_file(pd, filepath)
    #[2.] send warnings or errors if parameters were not used
    check_override_parameter_usage(pd, strict)
end


"""
    merge_override_default_values(
        override_toml_dict::AbstractTOMLDict{FT},
        default_toml_dict::AbstractTOMLDict{FT}
    ) where {FT}

Combines the `default_toml_dict` with the `override_toml_dict`,
precedence is given to override information.
"""
function merge_override_default_values(
    override_toml_dict::PDT,
    default_toml_dict::PDT,
) where {FT, PDT <: AbstractTOMLDict{FT}}
    data = default_toml_dict.data
    override_dict = override_toml_dict.override_dict
    for (key, val) in override_toml_dict.data
        if !(key in keys(data))
            data[key] = val
        else
            for (kkey, vval) in val # as val is a Dict too
                data[key][kkey] = vval
            end
        end
    end
    return PDT(data, override_dict)
end

"""
    create_toml_dict(FT;
        override_file,
        default_file,
        dict_type="alias"
    )

Creates a `ParamDict{FT}` struct, by reading and merging upto
two TOML files with override information taking precedence over
default information.
"""
function create_toml_dict(
    ::Type{FT};
    override_file::Union{Nothing, String} = nothing,
    default_file::String = joinpath(@__DIR__, "parameters.toml"),
    dict_type = "alias",
) where {FT <: AbstractFloat}
    @assert dict_type in ("alias", "name")
    PDT = _toml_dict(dict_type, FT)
    if isnothing(override_file)
        return PDT(TOML.parsefile(default_file), nothing)
    end
    override_toml_dict =
        PDT(TOML.parsefile(override_file), TOML.parsefile(override_file))
    default_toml_dict = PDT(TOML.parsefile(default_file), nothing)

    #overrides the defaults where they clash
    return merge_override_default_values(override_toml_dict, default_toml_dict)
end

function _toml_dict(s::String, ::Type{FT}) where {FT}
    if s == "alias"
        return AliasParamDict{FT}
    elseif s == "name"
        return ParamDict{FT}
    else
        error("Bad string option given")
    end
end
