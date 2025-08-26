# Basic Parameter Retrieval

ClimaParams.jl provides a centralized system for managing climate model parameters. The core workflow involves creating a parameter dictionary and then retrieving specific parameters from it.

## Core Functions

There are three key functions for parameter retrieval:
- [`create_toml_dict`](@ref) constructs a parameter dictionary from TOML files
- [`get_parameter_values`](@ref) retrieves parameters from the dictionary

## Creating Parameter Dictionaries

To construct a parameter dictionary, pass in the desired floating point type. 
This will source parameter values from the global default list stored in `src/parameters.toml`

```@example howto
import ClimaParams as CP
toml_dict = CP.create_toml_dict(Float64)
nothing # hide
```

You can also specify custom override and default files:

```julia
# With custom files
toml_dict = CP.create_toml_dict(
    Float64,
    override_file = "my_parameters.toml",
    default_file = "default_parameters.toml"
)
```

## Retrieving Parameters

To retrieve parameters, pass in the TOML dictionary and the parameter names that match those in the TOML file.

```@example howto
params = CP.get_parameter_values(toml_dict, ["universal_gas_constant", "gravitational_acceleration"])
params.universal_gas_constant
params.gravitational_acceleration
nothing #hide
```

You can also use direct indexing to obtain values from the parameter dictionary:
```@example howto
toml_dict["gravitational_acceleration"]
```

## Name Maps

Name maps allow you to map global parameter names to local variable names for
convenience. This is especially useful when you want shorter, more intuitive
variable names in your code.

### Using NamedTuples

```@example howto
name_map = (;
    :gravitational_acceleration => :g,
    :angular_velocity_planet_rotation => :omega
)
params = CP.get_parameter_values(toml_dict, name_map)
params.g  # gives value field of gravitational_acceleration
params.omega
```

### Using Dictionaries

```@example howto
name_map = Dict("gravitational_acceleration" => "g", "angular_velocity_planet_rotation" => "omega")
params = CP.get_parameter_values(toml_dict, name_map)
nothing # hide
```

### Using Varargs

```@example howto
params = CP.get_parameter_values(toml_dict, 
    :gravitational_acceleration => :g,
    :angular_velocity_planet_rotation => :omega
)
nothing # hide
```

## Component Logging

You can specify a component name when retrieving parameters. This logs which parameters are used by which model component, which is useful for reproducibility:

```@example howto
params = CP.get_parameter_values(toml_dict, ["gravitational_acceleration"], "Ocean")
nothing # hide
```

## Tagged Parameters

ClimaParams supports parameter tagging for easy filtering. You can retrieve all parameters with a specific tag:

```@example howto
# Get all atmospheric parameters
atmospheric_params = CP.get_tagged_parameter_values(toml_dict, "atmosphere")

# Get parameters with multiple tags
physics_params = CP.get_tagged_parameter_values(toml_dict, ["atmosphere", "turbulence"])
nothing # hide
```

## Example Usage

### Simple Parameter Retrieval

Here's a basic example showing how to retrieve parameters for use in a simulation:

```julia
import ClimaParams as CP

# Create parameter dictionary
toml_dict = CP.create_toml_dict(Float64)

# Retrieve specific parameters
params = CP.get_parameter_values(toml_dict, [
    "gravitational_acceleration",
    "universal_gas_constant", 
    "planet_radius"
])

# Use parameters in your code
g = params.gravitational_acceleration
R = params.universal_gas_constant

# Alternatively, you can index directly into the parameter dict
toml_dict["gravitational_acceleration"]

```

## Parameter Structs

For more complex applications, you can build parameter structs that encapsulate
related parameters. Here's a complete example from the CliMA ecosystem:

### Building Parameter Structs

```julia
Base.@kwdef struct ThermodynamicsParameters{FT}
    universal_gas_constant::FT
    molmass_dryair::FT
    # derived parameters
    R_d::FT = universal_gas_constant / molmass_dryair
end

# Float-type constructor
ThermodynamicsParameters(::Type{FT}) = ThermodynamicsParameters(CP.create_toml_dict(FT))

# TOML dictionary constructor
function ThermodynamicsParameters(toml_dict)
    name_map = [
        :temperature_triple_point => :T_triple,
        :adiabatic_exponent_dry_air => :kappa_d,
        :pressure_triple_point => :press_triple,
        :thermodynamics_temperature_reference => :T_0,
        :temperature_water_freeze => :T_freeze,
        :isobaric_specific_heat_ice => :cp_i,
    ]

    parameters = CP.get_parameter_values(
        toml_dict,
        name_map,
        "Thermodynamics",  # Component name for logging
    )

    FT = CP.float_type(toml_dict)
    return ThermodynamicsParameters{FT}(parameters...)
end
nothing # hide
```

### Hierarchical Parameter Sets

For complex models with multiple components, you can build hierarchical
parameter sets that maintain parameter relationships:

```julia
# Build individual component parameter sets
param_therm = ThermodynamicsParameters(toml_dict)
param_0M = CloudMicrophysics.Microphysics_0M_Parameters(toml_dict)

# Combine into a hierarchical parameter set
parameter_set = CloudMicrophysics.CloudMicrophysicsParameters(
    toml_dict,
    param_0M,
    param_therm
)
```

## Advanced Examples from CliMA

### Thermodynamics.jl Example

Here's how [`Thermodynamics.jl`](https://github.com/CliMA/Thermodynamics.jl)
uses ClimaParams in practice:

#### User-facing driver file
```julia
import ClimaParams as CP
using Thermodynamics

thermo_params = ThermodynamicsParameters(Float64)
```

#### Source code implementation
```julia
Base.@kwdef struct ThermodynamicsParameters{FT}
    LH_v0::FT
    LH_s0::FT
    # ... other parameters
    # derived parameters
    LH_f0 = LH_s0 - LH_v0
end

# Float-type constructor
ThermodynamicsParameters(::Type{FT}) = ThermodynamicsParameters(CP.create_toml_dict(FT))

# TOML dictionary constructor
function ThermodynamicsParameters(toml_dict)
    name_map = [
        :temperature_triple_point => :T_triple,
        :adiabatic_exponent_dry_air => :kappa_d,
        :pressure_triple_point => :press_triple,
        :thermodynamics_temperature_reference => :T_0,
        :temperature_water_freeze => :T_freeze,
        :isobaric_specific_heat_ice => :cp_i,
        # ... more mappings
    ]

    parameters = CP.get_parameter_values(
        toml_dict,
        name_map,
        "Thermodynamics",
    )
    
    # Create the parameter struct, preserving parameter relationships
    FT = CP.float_type(toml_dict)
    return ThermodynamicsParameters{FT}(parameters...)
end
```

### CloudMicrophysics.jl Example

Here's how [`CloudMicrophysics.jl`](https://github.com/CliMA/CloudMicrophysics.jl) builds hierarchical parameter sets:

#### User-facing driver file
```julia
import ClimaParams as CP
import Thermodynamics
import CloudMicrophysics

# Load defaults
toml_dict = CP.create_toml_dict(Float64)

# Build the low level parameter sets
param_therm = Thermodynamics.Parameters.ThermodynamicsParameters(toml_dict)
param_0M = CloudMicrophysics.Microphysics_0M_Parameters(toml_dict)

# Build the hierarchical parameter set
parameter_set = CloudMicrophysics.CloudMicrophysicsParameters(
    toml_dict,
    param_0M,
    param_therm
)
```

#### Source code implementation
```julia
abstract type AbstractMicrophysicsParameters end
struct NoMicrophysicsParameters <: AbstractMicrophysicsParameters end

Base.@kwdef struct Microphysics_0M_Parameters{FT} <: AbstractMicrophysicsParameters
    τ_precip::FT
    qc_0::FT
    S_0::FT
end

Base.@kwdef struct CloudMicrophysicsParameters{FT, AMPS <: AbstractMicrophysicsParameters}
    K_therm::FT
    # ... other parameters
    MPS::AMPS
    TPS::ThermodynamicsParameters{FT}
end

function CloudMicrophysicsParameters(
    toml_dict,
    MPS::AMPS,
    TPS::ThermodynamicsParameters{FT},
) where {FT, AMPS <: AbstractMicrophysicsParameters}

    parameter_names = ["K_therm", "other_param", ...]

    parameters = CP.get_parameter_values(
        toml_dict,
        parameter_names,
        "CloudMicrophysics",
    )

    return CloudMicrophysicsParameters{FT, AMPS}(;
        parameters...,
        MPS,  # Nested parameter struct
        TPS,  # Nested parameter struct
    )
end
```

### Parameters-as-functions

When building model components, parameters are extracted by calling `param_set.name`:

```julia
function example_cloudmicrophysics_func(param_set::CloudMicrophysicsParameters, ...)
    K_therm = param_set.K_therm
    # ... use parameters
end
```

These parameters can be made into functions for added flexibility:

```julia
K_therm(param_set) = param_set.K_therm
```

This can be useful for derived parameters:

```julia
derived_param(param_set) = param_set.param1 * param_set.param2
```

Or to forward parameters from nested parameter structs:

```julia
forwarded_param(ps::ParamSet) = ps.nested_params.forwarded_param
```

Functions can be autogenerated using `@eval`:

```julia
for fn in fieldnames(ParamSet)
    @eval $(fn)(ps::ParamSet) = ps.$(fn)
end
```

## Parameter Types

ClimaParams supports several parameter types:

- **float**: Numeric values (default)
- **integer**: Whole numbers
- **string**: Text values
- **bool**: Boolean values
- **datetime**: DateTime - an RFC 3339 formatted date-time with the offset omitted or an offset of `z`

The type is specified in the TOML file:

```toml
[gravitational_acceleration]
value = 9.81
type = "float"
description = "Gravitational acceleration on the planet (m s⁻²)."

[epoch_time]
value = 1970-01-01T00:00:00.0
type = "datetime"
description = "Unix epoch"
```
