"""
    ClimaParams

Centralized parameter management for the CliMA ecosystem.

`ClimaParams` reads physical constants and tunable model parameters from TOML
files and returns them as typed Julia values. A default file bundled with the
package (`src/parameters.toml`) holds the ecosystem-wide values; experiments
layer override files on top of it.

The entry point is [`create_toml_dict`](@ref), which returns a
[`ParamDict`](@ref). Values are read out with [`get_parameter_values`](@ref) or
by indexing. Every read is recorded, so [`log_parameter_information`](@ref) can
write a reproducible record of the parameters a simulation used.

# Examples

```julia
import ClimaParams as CP

toml_dict = CP.create_toml_dict(Float64)
params = CP.get_parameter_values(toml_dict, ["gravitational_acceleration"])
params.gravitational_acceleration
```
"""
module ClimaParams

using TOML
import Dates: DateTime

export ParamDict

export float_type,
    get_parameter_values,
    write_log_file,
    log_parameter_information,
    create_toml_dict,
    merge_toml_files,
    get_tagged_parameter_values,
    get_tagged_parameter_names,
    fuzzy_match

const NAMESTYPE =
    Union{AbstractVector{S}, NTuple{N, S} where {N}} where {S <: AbstractString}

"""
    ParamDict{FT}

A parameter dictionary holding the effective set of parameters read from TOML
files: the defaults merged with any overrides.

`FT` is the floating-point type that `"float"` parameters are converted to. The
dictionary also tracks which override parameters have been read, which
[`log_parameter_information`](@ref) uses to catch typos in override files.

Construct one with [`create_toml_dict`](@ref) rather than calling the inner
constructor directly.

# Fields
- `data::Dict`: The main dictionary holding the complete, merged set of parameter values and their metadata.
- `override_dict::Union{Nothing, Dict}`: A dictionary containing only the parameters from an override file, used for tracking purposes. Is `nothing` if no override file was provided.
"""
struct ParamDict{FT}
    "The main dictionary holding the complete, merged set of parameter values and their metadata."
    data::Dict
    "A dictionary containing only the parameters from an override file, used for tracking purposes. Is `nothing` if no override file was provided."
    override_dict::Union{Nothing, Dict}
end

"""
    float_type(pd::ParamDict)

Return the float type `FT` with which the parameter dictionary `pd` was initialized.

Downstream constructors should derive `FT` from this function rather than
hard-coding a float type.

# Examples

```julia
toml_dict = CP.create_toml_dict(Float32)
CP.float_type(toml_dict)  # Float32
```
"""
float_type(::ParamDict{FT}) where {FT} = FT

"""
    iterate(pd::ParamDict, [state])

Iterate over the underlying `name => metadata` pairs of `pd`.

The second element of each pair is the raw metadata `Dict` read from the TOML
file (`"value"`, `"type"`, `"description"`, ...), *not* the typed value.
Use [`Base.getindex`](@ref) or [`get_parameter_values`](@ref) to obtain typed
values.
"""
Base.iterate(pd::ParamDict, state) = Base.iterate(pd.data, state)
Base.iterate(pd::ParamDict) = Base.iterate(pd.data)


"""
    getindex(pd::ParamDict, name)

Retrieve the parameter `name`, converted to the type declared in the TOML file.

The parameter is logged as used by the component `"getindex"`, so values read
this way still appear in the file written by [`write_log_file`](@ref).

# Arguments
- `name`: The name of the parameter to retrieve.

# Returns
The parameter's value, cast to the type given by its `type` metadata (e.g.
`FT`, `Int`, `String`, `Bool`, `DateTime`). Array-valued parameters return a
`Vector` of that type.

# Examples

```julia
toml_dict = CP.create_toml_dict(Float64)
toml_dict["planet_radius"]  # 6.371e6
```

See also [`get_parameter_values`](@ref).
"""
function Base.getindex(pd::ParamDict, i)
    val = _getindex(pd, i)
    log_component!(pd, (i,), "getindex")
    return val
end

"""
    _getindex(pd::ParamDict, name)

Retrieve the parameter `name`, converted to the type declared in the TOML file,
without logging it as used.

Called from [`Base.getindex`](@ref) and [`get_parameter_values`](@ref), which
handle logging themselves.
"""
function _getindex(pd::ParamDict, i)
    param_data = getindex(pd.data, i)
    param_value = param_data["value"]
    param_type = get(param_data, "type", nothing)
    isnothing(param_type) && error("No type found for parameter `$i`")

    if param_value isa AbstractVector
        val = map(x -> _get_typed_value(pd, x, i, param_type), param_value)
    else
        val = _get_typed_value(pd, param_value, i, param_type)
    end
    return val
end

"""
    log_component!(pd::ParamDict, names::NAMESTYPE, component::AbstractString)

Log that a set of parameters is used by the model `component`.

This function modifies the parameter dictionary in-place by adding or appending
the `component` string to a `"used_in"` entry for each parameter specified in `names`.
This is crucial for tracking which parameters are active in a simulation.

# Arguments
- `pd`: The parameter dictionary to be modified.
- `names`: A vector or tuple of strings with the names of parameters to log.
- `component`: The name of the model component using the parameters.
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
    _get_typed_value(pd::ParamDict, val, valname, valtype)

Convert a raw parameter `val` to the Julia type named by the `valtype` string
from the TOML file.

Called from [`_getindex`](@ref).

# Arguments
- `pd`: The parameter dictionary, used to get the float type.
- `val`: The raw value of the parameter.
- `valname`: The name of the parameter, used in error messages.
- `valtype`: The type string: `"float"`, `"integer"`, `"string"`, `"bool"`, or `"datetime"`.

# Returns
The value `val` converted to the corresponding type. Throws an error for an
unrecognized `valtype`.
"""
function _get_typed_value(
    pd::ParamDict{FT},
    val,
    valname::AbstractString,
    valtype,
) where {FT}
    valid_types = Dict(
        "float" => FT,
        "integer" => Int,
        "string" => String,
        "bool" => Bool,
        "datetime" => DateTime,
    )
    if valtype in keys(valid_types)
        return valid_types[valtype](val)
    else
        error(
            """ For parameter with identifier: $valname, the attribute: type = $valtype, is not recognised,
            please select from: $(keys(valid_types))
            """,
        )
    end
end

"""
    get_parameter_values(pd, name, [component])
    get_parameter_values(pd, names, [component])
    get_parameter_values(pd, name_map, [component])
    get_parameter_values(pd, name_map...; component = nothing)

Retrieve parameter values from `pd` as a `NamedTuple`, converted to the types
declared in the TOML file.

Parameters can be requested either by name, in which case the TOML names become
the `NamedTuple` keys, or through a `name_map`, which renames them to shorter
local names.

If `component` is given, the parameters are also logged as used by that
component, so they appear with a `used_in` entry in the file written by
[`write_log_file`](@ref).

# Arguments
- `name::AbstractString`: A single parameter name.
- `names`: A `Vector` or `Tuple` of parameter names.
- `name_map`: A `Dict`, `NamedTuple`, or iterable of `Pair`s mapping the TOML
  parameter name to the desired local name, e.g.
  `"gravitational_acceleration" => "g"`. Keys and values may be `String`s or
  `Symbol`s.
- `component`: The name of the model component reading these parameters. In the
  varargs method it is a keyword argument; in all others it is the third
  positional argument.

# Returns
A `NamedTuple` keyed by the parameter names, or by the local names when a
`name_map` is used.

!!! note "Field order"
    With a `name_map`, the fields of the returned `NamedTuple` follow the
    iteration order of the underlying `Dict`, not the order in which the pairs
    were written. Splat the result into keyword arguments, as
    [`create_parameter_struct`](@ref) does, rather than into positional ones.

# Examples

```julia
# Retrieve by name
params = CP.get_parameter_values(
    toml_dict,
    ["gravitational_acceleration", "planet_radius"],
)
params.gravitational_acceleration  # 9.81

# Retrieve, rename, and log the use
params = CP.get_parameter_values(
    toml_dict,
    Dict("gravitational_acceleration" => "g"),
    "Thermodynamics",
)
params.g  # 9.81

# Varargs form; `component` is a keyword argument here
params = CP.get_parameter_values(
    toml_dict,
    :gravitational_acceleration => :g,
    :planet_radius => :R_p;
    component = "Thermodynamics",
)
```

See also [`get_tagged_parameter_values`](@ref) and [`create_parameter_struct`](@ref).
"""
function get_parameter_values(
    pd::ParamDict,
    names::AbstractString,
    component = nothing,
)
    return get_parameter_values(pd, [names], component)
end

function get_parameter_values(
    pd::ParamDict,
    names::NAMESTYPE,
    component::Union{AbstractString, Nothing} = nothing,
)
    if !isnothing(component)
        log_component!(pd, names, component)
    end
    return NamedTuple(map(x -> Symbol(x) => _getindex(pd, x), names))
end



function get_parameter_values(
    pd::ParamDict,
    name_map::Union{AbstractVector{Pair{S, S}}, NTuple{N, Pair}},
    component = nothing,
) where {S, N}
    return get_parameter_values(pd, Dict(name_map), component)
end

function get_parameter_values(
    pd::ParamDict,
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
    pd::ParamDict,
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
    pd::ParamDict,
    name_map::NamedTuple,
    component = nothing,
)
    return get_parameter_values(pd, Dict(pairs(name_map)), component)
end

function get_parameter_values(
    pd::ParamDict,
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
    create_parameter_struct(param_struct_type, toml_dict, name_map, [nested_structs])

Construct an instance of a parameter struct from a TOML dictionary.

Retrieve all required parameter values using `name_map` and instantiate
`param_struct_type`, including any `nested_structs`.

This function makes several assumptions about the parameter struct:
- It has a constructor that accepts keyword arguments for its fields.
- Its first type parameter is the floating-point type (e.g., `MyParams{FT}`).
- All nested parameter structs required by the constructor are passed via `nested_structs`.

# Arguments
- `param_struct_type`: The type of the parameter struct to be created (e.g., `MyParams`).
- `toml_dict::ParamDict`: The TOML dictionary containing the parameter values.
- `name_map`: A `Dict` or other iterable of `Pair`s to map TOML names to struct field names.
- `nested_structs`: A `NamedTuple` of already-constructed nested parameter structs, if any.

# Examples

```julia
Base.@kwdef struct GravityParameters{FT}
    g::FT
    planet_radius::FT
end

name_map = Dict("gravitational_acceleration" => "g", "planet_radius" => "planet_radius")
params = CP.create_parameter_struct(GravityParameters, toml_dict, name_map)
```
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
    merge_toml_files(filepaths; override::Bool=false)

Parse and merge multiple TOML files into a single dictionary.

# Arguments
- `filepaths`: An iterable of strings, where each string is a path to a TOML file.
- `override::Bool`: If `false` (the default), an error is thrown for duplicate parameter entries across files. If `true`, a warning is issued and later files in the `filepaths` list will overwrite earlier entries.

# Returns
- `Dict{String, Any}`: A dictionary containing the merged data from all TOML files.
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
    check_override_parameter_usage(pd::ParamDict, strict::Bool)

Verify that every parameter supplied in an override file was used during the
simulation, by checking for the `"used_in"` log entry.

Does nothing when `pd` was created without an override file.

# Arguments
- `strict`: If `true`, throw an error when any override parameter is unused. If
  `false`, only warn.
"""
check_override_parameter_usage(pd::ParamDict, strict::Bool) =
    check_override_parameter_usage(pd, strict, pd.override_dict)

check_override_parameter_usage(pd::ParamDict, strict::Bool, ::Nothing) = nothing

function check_override_parameter_usage(
    pd::ParamDict,
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
                "\n change `strict` flag to `false` to prevent this causing an exception",
            )
        end
    end
    return nothing
end

"""
    check_override_parameter_usage(pd::ParamDict, params, strict::Bool)

Verify that the subset of override parameters listed in `params` was used during
the simulation, by checking for the `"used_in"` log entry.

Throws an error if `pd` was created without an override file, or if any name in
`params` is absent from it.

# Arguments
- `params`: An iterable of parameter names, each of which must appear in the
  override file.
- `strict`: If `true`, throw an error when any of these parameters is unused. If
  `false`, only warn.
"""
function check_override_parameter_usage(pd::ParamDict, params, strict::Bool)
    isnothing(pd.override_dict) &&
        error("Override file was not provided when creating ParamDict")
    params = Set(params)
    params_not_in_override =
        filter(param -> param ∉ keys(pd.override_dict), params)
    isempty(params_not_in_override) || error(
        "Parameters ($(join(params_not_in_override, ", "))) does not exist in override file",
    )
    override_dict = Dict(k => v for (k, v) in pd.override_dict if k in params)
    return check_override_parameter_usage(pd, strict, override_dict)
end

"""
    write_log_file(pd::ParamDict, filepath::AbstractString)

Save all *used* parameters to a TOML file at `filepath`.

Only parameters that have been logged with [`log_component!`](@ref) are written,
so the result is a record of the parameters an experiment read. The
file is itself a valid parameter file and can be passed back as an
`override_file` to reproduce the run.

# Arguments
- `pd`: The parameter dictionary containing usage logs.
- `filepath`: The path where the log file will be saved.
"""
function write_log_file(pd::ParamDict, filepath::AbstractString)
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
    log_parameter_information(pd::ParamDict, filepath; strict::Bool = false)

Perform end-of-setup parameter handling: write the log file and check the
override file for unused entries.

Calls [`write_log_file`](@ref) to save the used parameters, then
[`check_override_parameter_usage`](@ref) to verify that every override parameter
was read by some component. Call it after all parameter structs have been
constructed and before the run starts.

# Arguments
- `filepath`: The path for the output log file.

# Keyword Arguments
- `strict = false`: If `true`, error when override parameters are unused;
  otherwise warn.

# Examples

```julia
toml_dict = CP.create_toml_dict(Float64; override_file = "my_experiment.toml")
# ... construct parameter structs ...
CP.log_parameter_information(toml_dict, "parameter_log.toml")
```
"""
function log_parameter_information(
    pd::ParamDict,
    filepath::AbstractString;
    strict::Bool = false,
)
    #[1.] write the parameters to log file
    write_log_file(pd, filepath)
    #[2.] send warnings or errors if parameters were not used
    check_override_parameter_usage(pd, strict)
end

"""
    merge_override_default_values(override_toml_dict, default_toml_dict)

Merge two `ParamDict` objects, with entries from `override_toml_dict` taking
precedence over those in `default_toml_dict`.

Merging is per-attribute: an override that sets only `value` keeps the
`description` and any other metadata from the default entry.

Called from [`create_toml_dict`](@ref).
"""
function merge_override_default_values(
    override_toml_dict::ParamDict{FT},
    default_toml_dict::ParamDict{FT},
) where {FT}
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
    return ParamDict{FT}(data, override_dict)
end

"""
    create_toml_dict(
        FT;
        override_file::Union{String, Dict, Nothing}=nothing,
        default_file::Union{String, Dict}="parameters.toml",
    )

Create a `ParamDict{FT}` by reading and merging default and override parameter
sources.

This is the main entry point for constructing a parameter dictionary. It reads
`default_file` and, optionally, `override_file`, with parameters from the
override file taking precedence. Either source may be a file path or an
already-parsed Julia `Dict`.

# Arguments
- `FT`: The floating-point type used for all `"float"` parameters.

# Keyword Arguments
- `override_file = nothing`: Path to a TOML file, or a `Dict`, of override parameters.
- `default_file`: Path to the default TOML file, or a `Dict`, of default
  parameters. Defaults to the `parameters.toml` file bundled with the package.

# Returns
A `ParamDict{FT}` containing the merged and typed parameters.

# Examples

```julia
toml_dict = CP.create_toml_dict(Float64)

toml_dict = CP.create_toml_dict(
    Float32;
    override_file = joinpath(@__DIR__, "my_experiment.toml"),
)
```
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

"""
    create_toml_dict(
        ::Type{FT},
        override_files::String...;
        default_file::Union{String, Dict} = joinpath(@__DIR__, "parameters.toml"),
    )

Create a `ParamDict{FT}` from the default file and any number of override files,
given as positional arguments.

The override files are merged in the order given, so a parameter set in more
than one file takes its value from the last file that defines it; each such
duplicate raises a warning. The merged result then overrides `default_file`.

# Arguments
- `FT`: The floating-point type used for all `"float"` parameters.
- `override_files`: Paths to TOML files. Each path must end in `.toml`. Unlike
  the single-file method, this method does not accept `Dict`s; merge them
  yourself and pass the result as `override_file`.

# Keyword Arguments
- `default_file`: Path to the default TOML file, or a `Dict`, of default
  parameters. Defaults to the `parameters.toml` file bundled with the package.

# Returns
A `ParamDict{FT}` containing the merged and typed parameters.

# Examples

```julia
toml_dict = CP.create_toml_dict(Float64, "site_parameters.toml", "experiment.toml")
```

See also [`merge_toml_files`](@ref).
"""
function create_toml_dict(
    ::Type{FT},
    override_files::String...;
    default_file::Union{String, Dict} = joinpath(@__DIR__, "parameters.toml"),
) where {FT <: AbstractFloat}
    isempty(override_files) &&
        return create_toml_dict(FT; override_file = nothing, default_file)
    all(filepath -> endswith(filepath, ".toml"), override_files) ||
        error("File paths ($override_files) must be TOML files")

    # Merge the override files in order.
    override_dict = merge_toml_files(collect(override_files); override = true)

    return create_toml_dict(FT; override_file = override_dict, default_file)
end

"""
    print(pd::ParamDict, io = stdout)

Print the full contents of `pd`, including all metadata, as TOML.

The arguments are in the opposite order to the Julia convention. There is
deliberately no `print(io::IO, pd)` method: defining one would also capture
`println(pd)`, `string(pd)`, and string interpolation, which fall through to
`show` and give a one-line summary.

Use [`write_log_file`](@ref) to write only the parameters that were used.
"""
Base.print(td::ParamDict, io = stdout) = TOML.print(io, td.data)

"""
    show(io::IO, pd::ParamDict)

Show a one-line summary of `pd`: its float type and the number of parameters it
holds.
"""
function Base.show(io::IO, d::ClimaParams.ParamDict{FT}) where {FT}
    n = length(d.data)
    print(io, "ParamDict{$FT} with $n parameters")
end

"""
    ==(pd1::ParamDict, pd2::ParamDict)

Compare two parameter dictionaries.

Two `ParamDict`s are equal when they share a float type and hold identical
parameter data and override data. Because usage logging writes a `used_in` entry
into the data, two dictionaries built from the same files compare unequal once
different parameters have been read from them.
"""
function Base.:(==)(pd1::ParamDict{FT1}, pd2::ParamDict{FT2}) where {FT1, FT2}
    return FT1 == FT2 &&
           pd1.data == pd2.data &&
           pd1.override_dict == pd2.override_dict
end

"""
    get_tagged_parameter_names(pd::ParamDict, tag)

Return the names of all parameters carrying the given `tag`, or any of the given
`tags`.

Tag matching is case-insensitive and ignores punctuation and whitespace; see
[`fuzzy_match`](@ref).

# Arguments
- `tag::Union{AbstractString, Vector{<:AbstractString}}`: The tag, or vector of tags, to search for.

# Returns
`Vector{String}`: the names of the parameters carrying the tag(s), in
unspecified order. Empty if no parameter carries the tag.

!!! note "The default file is untagged"
    No parameter in the bundled `parameters.toml` currently carries a `tag`, so
    these functions only return entries supplied through an override file. See
    the [Parameter tags](@ref) section of the TOML file interface.
"""
function get_tagged_parameter_names(pd::ParamDict, tag::AbstractString)
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
    pd::ParamDict,
    tags::Vector{S},
) where {S <: AbstractString} =
    vcat(map(x -> get_tagged_parameter_names(pd, x), tags)...)

"""
    fuzzy_match(s1::AbstractString, s2::AbstractString)

Compare two strings for equality, ignoring case and select punctuation.

The characters `[' ', '_', '*', '.', ',', '-', '(', ')']` are stripped from both strings before comparison.
"""
function fuzzy_match(s1::AbstractString, s2::AbstractString)
    strip_chars(x) = replace(x, [' ', '_', '*', '.', ',', '-', '(', ')'] => "")
    return lowercase(strip_chars(s1)) == lowercase(strip_chars(s2))
end

"""
    get_tagged_parameter_values(pd::ParamDict, tag)

Return the values of all parameters carrying the given `tag`, or any of the given
`tags`.

# Arguments
- `tag::Union{AbstractString, Vector{<:AbstractString}}`: The tag, or vector of tags, to search for.

# Returns
A `NamedTuple` keyed by parameter name. Empty if no parameter carries the tag.

# Examples

```julia
toml_dict = CP.create_toml_dict(Float64; override_file = "tagged_parameters.toml")
CP.get_tagged_parameter_values(toml_dict, "SurfaceFluxes")
```

See also [`get_tagged_parameter_names`](@ref).
"""
get_tagged_parameter_values(pd::ParamDict, tag::AbstractString) =
    get_parameter_values(pd, get_tagged_parameter_names(pd, tag))

get_tagged_parameter_values(
    pd::ParamDict,
    tags::Vector{S},
) where {S <: AbstractString} =
    merge(map(x -> get_tagged_parameter_values(pd, x), tags)...)

end # module
