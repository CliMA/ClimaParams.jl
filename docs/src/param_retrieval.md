## Basic Parameter Retrieval

There are two keys functions for parameter retrieval:
- `create_toml_dict` constructs a TOML dictionary which stores parameters,
- `get_parameter_values` retrieves parameters from the TOML dictionary.

To construct a TOML dictionary, pass in the desired floating point type. 
This will source parameter values from the global default list stored in `src/parameters.toml`
```julia
import ClimaParams as CP
toml_dict = CP.create_toml_dict(Float64)
```
To retrieve parameters, pass in the TOML dictionary and the names that match the default parameters.
```julia
params = CP.get_parameter_values(toml_dict, ["gravitational_acceleration", "gas_constant"])
params.gravitational_acceleration
params.gas_constant
```
You can also pass in a single parameter name:
```julia
params = CP.get_parameter_values(toml_dict, "gravitational_acceleration")
params.gravitational_acceleration
```

## Name Maps
Name maps are a way to map global descriptive parameter names (indexing the toml_dict) 
to local user-defined names. One can define a name with a NamedTuple as follows...
It will return a NamedTuple of the parameters with your given variable names.
```julia
name_map = (;
    :gravitational_acceleration => :g,
    :angular_velocity_planet_rotation => :omega
)
params = CP.get_parameter_values(toml_dict, name_map)
params.g  # gives value field of gravitational_acceleration
params.omega
```
A name map does not strictly need to be a NamedTuple. It can be a Dict, Vector, Tuple, or Varargs of Pairs.
The entries in the name map can also be Strings instead of Symbols.

```julia
name_map = Dict("gravitational_acceleration" => "g", "angular_velocity_planet_rotation" => "omega")
params = CP.get_parameter_values(toml_dict, name_map)

params = CP.get_parameter_values(toml_dict, :gravitational_acceleration => :g,
                                            :angular_velocity_planet_rotation => :omega)
```

## Example Usage

### An example from `Thermodynamics.jl`

#### In the user-facing driver file
```julia
import ClimaParams
using Thermodynamics

thermo_params = ThermodynamicsParameters(Float64)
```

#### In the source code for `Thermodynamics.jl`

```julia
Base.@kwdef struct ThermodynamicsParameters{FT}
    gas_constant::FT
    molmass_dryair::FT
    ...
    # derived parameters
    R_d::FT = gas_constant / molmass_dryair
end
```
- The struct is parameterized by `{FT}` which is a user-determined float precision.
- Only relevant parameters used in `Thermodynamics` are stored here.
- A keyword based constructor is provided so we do not rely on parameter order.

The constructor is as follows
```julia
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
        ...
    ]

    parameters = ClimaParams.get_parameter_values(
        toml_dict,
        name_map,
        "Thermodynamics",
    )

    FT = CP.float_type(toml_dict)
    return ThermodynamicsParameters{FT}(parameters...)
end
```

- The constructor takes in a `toml_dict` produced from reading the TOML file.
- The name map maps from the globally-defined parameter names to the user-defined names. 
- We obtain the NamedTuple parameters from `get_parameter_values(toml_dict, name_map, component_name)` The `component_name` is a string used for the parameter log.
- We return the `ThermodynamicsParameters{FT}`, where FT is an enforced float type (e.g. single or double precision).


### An example with modular components from `CloudMicrophysics.jl`

#### In the user-facing driver file

Here we build a `CloudMicrophysics` parameter set. In this case, the user wishes to use a
0-moment microphysics parameterization scheme.
```julia
import ClimaParams
import Thermodynamics
import CloudMicrophysics

#load defaults
toml_dict = ClimaParams.create_toml_dict(Float64)

#build the low level parameter set
param_therm = Thermodynamics.Parameters.ThermodynamicsParameters(toml_dict)
param_0M = CloudMicrophysics.Microphysics_0M_Parameters(toml_dict)

#build the hierarchical parameter set
parameter_set = CloudMicrophysics.CloudMicrophysicsParameters(
    toml_dict,
    param_0M,
    param_therm
)
```
!!! note
    The exact APIs here are subject to change.

#### In the source code for `CloudMicrophysics.jl`

Build the different options for a Microphysics parameterizations
```julia
abstract type AbstractMicrophysicsParameters end
struct NoMicrophysicsParameters <: AbstractMicrophysicsParameters end
Base.@kwdef struct Microphysics_0M_Parameters{FT} <: AbstractMicrophysicsParameters
    τ_precip::FT
    qc_0::FT
    S_0::FT
end
Base.@kwdef struct Microphysics_1M_Parameters{FT} <: AbstractMicrophysicsParameters
    ...
end
```
We omit their constructors (see above). The `CloudMicrophysics` parameter set is built likewise

```julia
Base.@kwdef struct CloudMicrophysicsParameters{FT, AMPS <: AbstractMicrophysicsParameters}
    K_therm::FT
    ...
    MPS::AMPS
    TPS::ThermodynamicsParameters{FT}
end


function CloudMicrophysicsParameters(
    toml_dict,
    MPS::AMPS,
    TPS::ThermodynamicsParameters{FT},
) where {FT, AMPS <: AbstractMicrophysicsParameters}

    parameter_names = [ "K_therm", ... ]

    parameters  = ClimaParams.get_parameter_values(
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

!!! note
    The exact APIs here are subject to change.

When building the model components, parameters are extracted by calling `param_set.name`
```julia
function example_cloudmicrophysics_func(param_set::CloudMicrophysicsParameters,...)
    K_therm = param_set.K_therm
    ...
end
```
These parameters can be made into functions for added flexibility.
```julia
K_therm(param_set) = param_set.K_therm
```
This can be useful for derived parameters,
```julia
derived_param(param_set) = param_set.param1 * param_set.param2
```
or to forward parameters from nested parameter structs:
```julia
forwarded_param(ps::ParamSet) = ps.nested_params.forwarded_param
```

Functions can be autogenerated using `@eval`:
```julia
for fn in fieldnames(ParamSet)
    @eval $(fn)(ps::ParamSet) = ps.$(fn)
end
```
