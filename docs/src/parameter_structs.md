# Parameter Structures

Parameters are stored in objects that reflect the model component construction. Definitions should be inserted into the model component source code

## An example from `Thermodynamics.jl` 

### In the user-facing driver file
```julia
import CLIMAParameters
import Thermodynamics
parameter_struct = CLIMAParameters.create_parameter_struct(dict_type="alias") 
thermo_params = Thermodynamics.ThermodynamicsParameters(parameter_struct)
```

### In the source code for `Thermodynamics.jl`

```julia
struct ThermodynamicsParameters{FT}
    ...
    R_d::FT
    gas_constant::FT
    molmass_dryair::FT
end
```
- The struct is parameterized by `{FT}` which is a user-determined float precision
- Only relevant parameters used in `Thermodynamics` are stored here.

The constructor is as follows
```julia
function ThermodynamicsParameters(parameter_struct)

    # Used in thermodynamics, from parameter file
    aliases = [ ..., "gas_constant", "molmass_dryair"]

    (gas_constant, molmass_dryair,) = CLIMAParameters.get_parameter_values!(
        param_struct,
        aliases,
        "Thermodynamics",
    )

    # derived parameters from parameter file
    R_d = gas_constant / molmass_dryair

    return ThermodynamicsParameters{
        CLIMAParameters.get_parametric_type(param_struct)}(...,R_d, gas_constant, molmass_dryair)
end
```

- The constructor takes in a `parameter_struct` produced from reading the TOML file
- We list the aliases of parameters required by `Thermodynamics.jl` 
- We obtain parameters by calling the function `CLIMAParameters.get_parameter_values!(parameter_struct,aliases,component_name)` The `component_name` is a string used for the parameter log.
- We then create any `derived parameters` e.g. commonly used simple functions of parameters that are treated as parameters. here we create the dry air gas constant `R_d`
- We end by returning creating the `ThermodynamicsParameters{FT}`.


## An example with modular components from `CloudMicrophysics.jl`

### In the user-facing driver file

Here we build a `CloudMicrophysics` parameter set. In this case, the user wishes to use a
0-moment microphysics parameterization scheme.
```julia
import CLIMAParameters
import Thermodynamics
import CloudMicrophysics

#load defaults
parameter_struct = CLIMAParameters.create_parameter_struct(dict_type="alias")

#build the low level parameter set
param_therm = Thermodynamics.ThermodynamicsParameters(parameter_struct)
param_0M = CloudMicrophysics.Microphysics_0M_Parameters(parameter_struct)

#build the hierarchical parameter set
parameter_set = CloudMicrophysics.CloudMicrophysicsParameters(
    parameter_struct,
    param_0M,
    param_therm
)
```
!!! note
    The exact APIs here are subject to change
    
### In the source code for `CloudMicrophysics.jl`

Build the different options for a Microphysics parameterizations
```julia
abstract type AbstractMicrophysicsParameters end
struct NoMicrophysicsParameters <: AbstractMicrophysicsParameters end 
struct Microphysics_0M_Parameters{FT} <: AbstractMicrophysicsParameters
    τ_precip::FT
    qc_0::FT
    S_0::FT
end
struct Microphysics_1M_Parameters{FT} <: AbstractMicrophysicsParameters
    ...
end
```
We omit their constructors (see above). The `CloudMicrophysics` parameter set is built likewise

```julia
struct CloudMicrophysicsParameters{FT, AMPS <: AbstractMicrophysicsParameters}
    K_therm::FT
    ...
    MPS::AMPS
    TPS::ThermodynamicsParameters{FT}
end


function CloudMicrophysicsParameters(
    param_set,
    MPS::AMPS,
    TPS::ThermodynamicsParameters{FT},
) where {FT, AMPS <: AbstractMicrophysicsParameters}

    aliases = [ "K_therm", ... ]

    ( K_therm,... ) = CLIMAParameters.get_parameter_values!(
        param_set,
        aliases,
        "CloudMicrophysics",
    )

    #derived parameters 
    ...
    
    return CloudMicrophysicsParameters{
        CLIMAParameters.get_parametric_type(param_set), AMPS}(
            K_therm,
            ...     
            MPS,
            TPS,
        )
end
```

## Calling parameters from `src`


When building the model components, parameters are extracted by calling `param_set.name` or `param_set.alias` (currently)
```julia
function example_cloudmicrophysics_func(param_set::CloudMicrophysicsParameters,...)
    K_therm = param_set.K_therm
    ...
end
```
When calling functions from dependent packages, simply pass the relevant lower_level parameter struct
```julia
function example_cloudmicrophysics_func(param_set::CloudMicrophysicsParameters,...)
    thermo_output = Thermodynamics.thermo_function(param_set.TPS,...)
    cm0_output = Microphysics_0m.microphys_function(param_set.MPS,...)
    ...
end
```
These functions should be written with this in mind (dispatching)
```julia
microphys_function(param_set::Microphysics_0M_parameters,...)
   qc_0 = param_set.qc_0
   ...
end
```


