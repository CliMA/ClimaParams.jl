```@meta
CurrentModule = ClimaParams
```

# Parameter Retrieval

ClimaParams.jl provides a centralized system for managing climate model parameters. The core workflow is to create a parameter dictionary and then retrieve parameters from it.

## Core Functions

Two functions cover most use:
- [`create_toml_dict`](@ref) constructs a parameter dictionary from TOML files
- [`get_parameter_values`](@ref) retrieves parameters from the dictionary

## Creating Parameter Dictionaries

To construct a parameter dictionary, pass in the desired floating point type.
This sources parameter values from the global default list stored in `src/parameters.toml`.

```@example retrieval
import ClimaParams as CP
toml_dict = CP.create_toml_dict(Float64)
```

The float type determines the precision of every `"float"` parameter, and is
recoverable from the dictionary with [`float_type`](@ref):

```@example retrieval
CP.float_type(toml_dict)
```

You can also specify custom override and default files:

```julia
# One override file
toml_dict = CP.create_toml_dict(
    Float64;
    override_file = "my_parameters.toml",
    default_file = "default_parameters.toml",
)

# Several override files, merged left to right, then applied to the defaults
toml_dict = CP.create_toml_dict(Float64, "site.toml", "my_experiment.toml")
```

See [Override Files](@ref) for how merging and precedence work.

## Retrieving Parameters

To retrieve parameters, pass in the TOML dictionary and the parameter names that match those in the TOML file.

```@example retrieval
params = CP.get_parameter_values(
    toml_dict,
    ["universal_gas_constant", "gravitational_acceleration"],
)
params.gravitational_acceleration
```

You can also use direct indexing to obtain values from the parameter dictionary:

```@example retrieval
toml_dict["gravitational_acceleration"]
```

## Name Maps

Name maps map global parameter names to local variable names. This is useful
when you want the short, conventional symbols of a parameterization in your code
without shortening the globally unique name in the TOML file.

### Using NamedTuples

```@example retrieval
name_map = (;
    :gravitational_acceleration => :g,
    :angular_velocity_planet_rotation => :omega,
)
params = CP.get_parameter_values(toml_dict, name_map)
params.g
```

### Using Dictionaries

```@example retrieval
name_map = Dict(
    "gravitational_acceleration" => "g",
    "angular_velocity_planet_rotation" => "omega",
)
params = CP.get_parameter_values(toml_dict, name_map)
params.omega
```

### Using Varargs

```@example retrieval
params = CP.get_parameter_values(
    toml_dict,
    :gravitational_acceleration => :g,
    :angular_velocity_planet_rotation => :omega,
)
```

!!! warning "Field order is not the order you wrote"
    A name map is converted to a `Dict` internally, so the fields of the
    returned `NamedTuple` come out in the `Dict`'s iteration order, not the
    order of the pairs you supplied. Access the fields by name, or splat the
    result into keyword arguments as [`create_parameter_struct`](@ref) does.
    Never splat it into positional arguments.

## Component Logging

Pass a component name when retrieving parameters. This records which parameters
are read by which model component, which [`write_log_file`](@ref) then writes
out for reproducibility, and which [`check_override_parameter_usage`](@ref) uses
to catch misspelled override entries.

```@example retrieval
params = CP.get_parameter_values(toml_dict, ["gravitational_acceleration"], "Ocean")
```

!!! note "`component` is a keyword in the varargs method"
    In every method above, `component` is the third positional argument. In the
    varargs method it must be passed as a keyword, because the positional slots
    are taken by the pairs:

    ```julia
    CP.get_parameter_values(
        toml_dict,
        :gravitational_acceleration => :g;
        component = "Ocean",
    )
    ```

## Tagged Parameters

Parameters can carry a `tag` so that a whole group can be retrieved at once. See
[Parameter tags](@ref) for the file syntax and for the caveat that the bundled
default file is currently untagged.

```@example retrieval
overrides = Dict(
    "my_diffusivity" => Dict(
        "value" => 1.0,
        "type" => "float",
        "description" => "Example horizontal diffusivity (m² s⁻¹).",
        "tag" => ["MyComponent"],
    ),
    "my_damping_timescale" => Dict(
        "value" => 3600.0,
        "type" => "float",
        "description" => "Example damping timescale (s).",
        "tag" => ["MyComponent", "Turbulence"],
    ),
)
tagged_dict = CP.create_toml_dict(Float64; override_file = overrides)

CP.get_tagged_parameter_values(tagged_dict, "mycomponent")
```

Tag matching is case-insensitive and ignores punctuation; see [`fuzzy_match`](@ref).
Passing a vector of tags returns the union:

```@example retrieval
CP.get_tagged_parameter_values(tagged_dict, ["MyComponent", "Turbulence"])
```

## Parameter Structs

Model components should not read the parameter dictionary in their inner code.
Instead, build an immutable struct once at setup, and pass it down. This keeps
the component's parameter surface explicit and the struct `isbits`, so it can be
moved to a GPU.

The constructor takes the `ParamDict` and a name map from global TOML names to
struct field names:

```@example structs
import ClimaParams as CP

Base.@kwdef struct ThermodynamicsParameters{FT}
    universal_gas_constant::FT
    molar_mass_dry_air::FT
    temperature_triple_point::FT
    # Derived parameters
    R_d::FT = universal_gas_constant / molar_mass_dry_air
end

# TOML dictionary constructor
function ThermodynamicsParameters(toml_dict::CP.ParamDict)
    name_map = Dict(
        "universal_gas_constant" => "universal_gas_constant",
        "molar_mass_dry_air" => "molar_mass_dry_air",
        "temperature_triple_point" => "temperature_triple_point",
    )
    parameters = CP.get_parameter_values(toml_dict, name_map, "Thermodynamics")
    FT = CP.float_type(toml_dict)
    return ThermodynamicsParameters{FT}(; parameters...)
end

# Float-type constructor, for convenience
ThermodynamicsParameters(::Type{FT}) where {FT <: AbstractFloat} =
    ThermodynamicsParameters(CP.create_toml_dict(FT))

thermo_params = ThermodynamicsParameters(Float64)
thermo_params.R_d
```

[`create_parameter_struct`](@ref) does the same job in one call, and also
accepts already-constructed nested structs:

```@example structs
name_map = Dict(
    "universal_gas_constant" => "universal_gas_constant",
    "molar_mass_dry_air" => "molar_mass_dry_air",
    "temperature_triple_point" => "temperature_triple_point",
)
toml_dict = CP.create_toml_dict(Float64)
CP.create_parameter_struct(ThermodynamicsParameters, toml_dict, name_map)
```

### Hierarchical Parameter Sets

Models with several components nest the component structs inside a model-level
struct, so that a single object can be passed to every part of the model:

```julia
thermodynamics_params = Thermodynamics.ThermodynamicsParameters(toml_dict)
microphysics_params = CloudMicrophysics.Parameters.CloudMicrophysicsParameters(
    toml_dict,
    thermodynamics_params,
)

parameter_set = ClimaAtmosParameters(
    toml_dict,
    thermodynamics_params,
    microphysics_params,
)
```

!!! warning "Extract the sub-struct before broadcasting"
    Capturing a whole nested parameter set inside a GPU broadcast pushes a large
    struct into kernel parameter memory. Pull out the piece you need first, e.g.
    `thp = p.params.thermodynamics_params`, then broadcast over `thp`.

### Parameters-as-functions

Parameters can be accessed through functions for added flexibility:

```julia
K_therm(param_set) = param_set.K_therm
```

This is useful for derived parameters:

```julia
derived_param(param_set) = param_set.param1 * param_set.param2
```

Or to forward parameters from nested parameter structs:

```julia
forwarded_param(ps::ParamSet) = ps.nested_params.forwarded_param
```

Such functions can be autogenerated using `@eval`:

```julia
for fn in fieldnames(ParamSet)
    @eval $(fn)(ps::ParamSet) = ps.$(fn)
end
```

## Parameter Types

The `type` field of a parameter selects the Julia type its value is converted to:

| `type`       | Julia type                                    |
|:-------------|:----------------------------------------------|
| `"float"`    | the `FT` given to [`create_toml_dict`](@ref)  |
| `"integer"`  | `Int`                                          |
| `"string"`   | `String`                                       |
| `"bool"`     | `Bool`                                         |
| `"datetime"` | `Dates.DateTime`                               |

Conversion is by construction, so a value that cannot be represented in the
declared type raises an error rather than being silently truncated: an
`"integer"` parameter written as `2.5` throws an `InexactError`.

Array-valued parameters use the same `type` as their scalar counterparts and
return a `Vector` of that type.

```toml
[gravitational_acceleration]
value = 9.81
type = "float"
description = "Gravitational acceleration on the planet (m s⁻²)."

[epoch_time]
value = 2000-01-01T11:58:55.816
type = "datetime"
description = "J2000 epoch (Jan 1, 2000 11:58:55.816 UTC) as a DateTime"
```
