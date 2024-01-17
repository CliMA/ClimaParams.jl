"""
    AbstractTOMLDict{FT <: AbstractFloat}

Abstract parameter dict. One subtype:
 - [`ParamDict`](@ref)
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
    float_type(::AbstractTOMLDict)

The float type from the parameter dict.
"""
float_type(::AbstractTOMLDict{FT}) where {FT} = FT

Base.iterate(pd::ParamDict, state) = Base.iterate(pd.data, state)
Base.iterate(pd::ParamDict) = Base.iterate(pd.data)

Base.getindex(pd::ParamDict, i) = getindex(pd.data, i)

"""
    log_component!(pd::AbstractTOMLDict, names, component)

Adds a new key,val pair: `("used_in",component)` to each
named parameter in `pd`.
Appends a new val: `component` if "used_in" key exists.
"""
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
    elseif valtype == "bool"
        return Bool(val)
    else
        error(
            "For parameter with identifier: \"",
            valname,
            "\", the attribute: type = \"",
            valtype,
            "\", is not recognised, ",
            "\n please select from: type = \"string\", \"float\", \"integer\", or \"bool\"",
        )
    end
end

"""
    get_values(pd::AbstractTOMLDict, names)

Gets the values of the parameters in `names` from the TOML dict `pd`.
"""
function get_values(pd::ParamDict, names::NAMESTYPE)
    data = pd.data
    ret_values = map(names) do name
        param_data = data[name]
        param_value = param_data["value"]
        param_type = get(param_data, "type", "string")

        elem = if param_value isa AbstractVector
            map(x -> _get_typed_value(pd, x, name, param_type), param_value)
        else
            _get_typed_value(pd, param_value, name, param_type)
        end

        Pair(Symbol(name), elem)
    end
    return (; ret_values...)
end

"""
    get_parameter_values(
        pd::AbstractTOMLDict,
        names::Union{String,Vector{String}},
        component::String
    )

    get_parameter_values(
        pd::AbstractTOMLDict,
        name_map::Union{Dict, Vector{Pair}, NTuple{N, Pair}, Vararg{Pair}},
        component::String
    )

Given a toml dict and a list of parameter names, returns a NamedTuple of the 
parameters and their values. If a component is specified, the parameter is
logged as being used in that component.

Instead of a list of parameter names, this can take an iterable mapping from
parameter names to variable names in code. Then, this function retrieves all parameters 
from the long names and returns a NamedTuple where the keys are the variable names.
"""
function get_parameter_values(
    pd::AbstractTOMLDict,
    names::AbstractString,
    component = nothing,
)
    return get_parameter_values(pd, [names], component)
end

function get_parameter_values(
    pd::AbstractTOMLDict,
    names::NAMESTYPE,
    component::Union{AbstractString, Nothing} = nothing,
)
    if !isnothing(component)
        log_component!(pd, names, component)
    end
    return get_values(pd, names)
end

function get_parameter_values(
    pd::AbstractTOMLDict,
    name_map::Union{AbstractVector{Pair{S, S}}, NTuple{N, Pair}},
    component = nothing,
) where {S, N}
    return get_parameter_values(pd, Dict(name_map), component)
end

function get_parameter_values(
    pd::AbstractTOMLDict,
    name_map::Vararg{Pair};
    component = nothing,
)
    return get_parameter_values(
        pd,
        Dict(Symbol(key) => Symbol(value) for (key, value) in name_map),
        component,
    )
end

function get_parameter_values(
    pd::AbstractTOMLDict,
    name_map::Dict{S, S},
    component = nothing,
) where {S <: AbstractString}

    return get_parameter_values(
        pd,
        Dict(Symbol(key) => Symbol(value) for (key, value) in name_map),
        component,
    )
end

function get_parameter_values(
    pd::AbstractTOMLDict,
    name_map::NamedTuple,
    component = nothing,
)
    return get_parameter_values(pd, Dict(pairs(name_map)), component)
end

function get_parameter_values(
    pd::AbstractTOMLDict,
    name_map::Dict{Symbol, Symbol},
    component = nothing,
)
    params = get_parameter_values(pd, string.(keys(name_map)), component)
    return (;
        [
            short_name => getfield(params, long_name) for
            (long_name, short_name) in name_map
        ]...
    )
end

"""
    create_parameter_struct(
        toml_dict,
        param_struct_type,
        name_map,
        nested_structs = (;),
    )

Constructs the parameter struct from the TOML dictionary. If the parameter struct
has nested parameter structs, they must be passed.
Floating type is inherited from the TOML dictionary.

This is fairly rigid and makes a few assumptions:
 - The parameter struct has a constructor that takes keyword arguments
 - The parameter struct's first type parameter is the floating point type
 - All nested parameter structs are given.
"""
function create_parameter_struct(
    param_struct_type,
    toml_dict,
    name_map,
    nested_structs = (;),
)
    params = get_parameter_values(toml_dict, name_map)
    FT = float_type(toml_dict)
    return param_struct_type{FT, typeof.(values(nested_structs))...}(;
        params...,
        nested_structs...,
    )
end

"""
    merge_toml_files(filepaths; override)

Parses and merges all of the given TOML filepaths and returns them as a Dict.
This allows a toml_dict to be constructed from multiple TOML files.
By default, non-unique TOML entries are not allowed, but this can be
changed by setting `override = true`.
"""
function merge_toml_files(filepaths; override = false)
    merged_dict = Dict{String, Any}()
    for filepath in filepaths
        toml_data = TOML.parsefile(filepath)
        for (table_name, table_data) in toml_data
            if haskey(merged_dict, table_name)
                override || error("Duplicate TOML entry: $table_name")
                @warn """
'$table_name' is being overwritten by '$filepath'
Current entry: $(merged_dict[table_name]["type"])($(merged_dict[table_name]["value"]))
New entry: $(table_data["type"])($(table_data["value"]))"""
            end
        end
        merge!(merged_dict, toml_data)
    end
    return merged_dict
end

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
    for (key, _) in override_dict
        logged_val = pd.data[key]
        unused_override[key] = !("used_in" in keys(logged_val))
    end
    if any(values(unused_override))
        unused_override_keys = collect(keys(unused_override))
        filter!(key -> unused_override[key], unused_override_keys)
        @warn(
            string(
                "Keys are present in parameter file but not used ",
                "in the simulation. \n Typically this is due to ",
                "a mismatch in parameter name in toml and in source. ",
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
    )

Creates a `ParamDict{FT}` struct, by reading and merging upto
two TOML files or Julia Dicts with override information taking precedence over
default information.
"""
function create_toml_dict(
    ::Type{FT};
    override_file::Union{Nothing, String, Dict} = nothing,
    default_file::Union{String, Dict} = joinpath(@__DIR__, "parameters.toml"),
) where {FT <: AbstractFloat}

    default_dict =
        default_file isa String ? TOML.parsefile(default_file) : default_file
    default_toml_dict = ParamDict{FT}(default_dict, nothing)
    isnothing(override_file) && return default_toml_dict

    override_dict =
        override_file isa String ? TOML.parsefile(override_file) : override_file
    override_toml_dict = ParamDict{FT}(override_dict, override_dict)

    return merge_override_default_values(override_toml_dict, default_toml_dict)
end

# Extend Base.print to AbstractTOMLDict
Base.print(td::AbstractTOMLDict, io = stdout) = TOML.print(io, td.data)


"""
    get_tagged_parameter_names(pd::AbstractTOMLDict, tag::AbstractString)
    get_tagged_parameter_names(pd::AbstractTOMLDict, tags::Vector{AbstractString})

Returns a list of the parameters with a given tag.
"""
function get_tagged_parameter_names(pd::AbstractTOMLDict, tag::AbstractString)
    data = pd.data
    ret_values = String[]
    for (key, val) in data
        if any(fuzzy_match.(tag, get(val, "tag", [])))
            push!(ret_values, key)
        end
    end
    return ret_values
end

get_tagged_parameter_names(
    pd::AbstractTOMLDict,
    tags::Vector{S},
) where {S <: AbstractString} =
    vcat(map(x -> get_tagged_parameter_names(pd, x), tags)...)

"""
    fuzzy_match(s1::AbstractString, s2::AbstractString)

Takes two strings and checks them for equality. 
This strips punctuation [' ', '_', '*', '.', ',', '-', '(', ')'] and removes capitalization.
"""
function fuzzy_match(s1::AbstractString, s2::AbstractString)
    strip_chars(x) = replace(x, [' ', '_', '*', '.', ',', '-', '(', ')'] => "")
    return lowercase(strip_chars(s1)) == lowercase(strip_chars(s2))
end

"""
    get_tagged_parameter_values(pd::AbstractTOMLDict, tag::AbstractString)
    get_tagged_parameter_values(pd::AbstractTOMLDict, tags::Vector{AbstractString})

Returns a list of name-value Pairs of the parameters with the given tag(s).
"""
get_tagged_parameter_values(pd::AbstractTOMLDict, tag::AbstractString) =
    get_parameter_values(pd, get_tagged_parameter_names(pd, tag))

get_tagged_parameter_values(
    pd::AbstractTOMLDict,
    tags::Vector{S},
) where {S <: AbstractString} =
    merge(map(x -> get_tagged_parameter_values(pd, x), tags)...)
