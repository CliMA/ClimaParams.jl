# Parameter Dictionaries

Parameters are stored in objects that reflect the model component construction. Definitions should be inserted into the model component source code.

## An example from `Thermodynamics.jl`

### In the user-facing driver file
```julia
import CLIMAParameters
import Thermodynamics

toml_dict = CLIMAParameters.create_toml_dict(;dict_type="alias")
thermo_params = Thermodynamics.ThermodynamicsParameters(toml_dict)
```

### In the source code for `Thermodynamics.jl`

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
- A keyword based `struct` so we do not rely on parameter order.

The constructor is as follows
```julia
function ThermodynamicsParameters(toml_dict)

    # Used in thermodynamics, from parameter file
    aliases = [ ..., "gas_constant", "molmass_dryair"]

    param_pairs = CLIMAParameters.get_parameter_values!(
        toml_dict,
        aliases,
        "Thermodynamics",
    )
    nt = (; param_pairs...)

    FT = CP.float_type(toml_dict)
    return ThermodynamicsParameters{FT}(; nt...)
end
```

- The constructor takes in a `toml_dict` produced from reading the TOML file.
- We list the aliases of parameters required by `Thermodynamics.jl`.
- We obtain parameters (in the form of a list of (alias,value) Pairs) from `get_parameter_values!(toml_dict,aliases,component_name)` The `component_name` is a string used for the parameter log.
- We convert to namedtuple for ease of extraction.
- We create any `derived parameters` i.e. commonly used simple functions of parameters that are treated as parameters. Here we create the dry air gas constant `R_d`.
- We return the `ThermodynamicsParameters{FT}`, where FT is an enforced float type (e.g. single or double precision).


## An example with modular components from `CloudMicrophysics.jl`

### In the user-facing driver file

Here we build a `CloudMicrophysics` parameter set. In this case, the user wishes to use a
0-moment microphysics parameterization scheme.
```julia
import CLIMAParameters
import Thermodynamics
import CloudMicrophysics

#load defaults
toml_dict = CLIMAParameters.create_toml_dict(; dict_type="alias")

#build the low level parameter set
param_therm = Thermodynamics.ThermodynamicsParameters(toml_dict)
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

### In the source code for `CloudMicrophysics.jl`

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

    aliases = [ "K_therm", ... ]

    param_pairs  = CLIMAParameters.get_parameter_values!(
        toml_dict,
        aliases,
        "CloudMicrophysics",
    )

    nt = (; param_pairs...)
    #derived parameters
    ...
    FT = CP.float_type(toml_dict)

    return CloudMicrophysicsParameters{FT, AMPS}(;
            nt...,
            ...
            MPS,
            TPS,
        )
end
```

## Calling parameters from `src`

!!! note
    The exact APIs here are subject to change.

When building the model components, parameters are extracted by calling `param_set.name` or `param_set.alias` (currently)
```julia
function example_cloudmicrophysics_func(param_set::CloudMicrophysicsParameters,...)
    K_therm = param_set.K_therm
    ...
end
```
When calling functions from dependent packages, simply pass the relevant lower_level parameter dict
```julia
function example_cloudmicrophysics_func(param_set::CloudMicrophysicsParameters,...)
    thermo_output = Thermodynamics.thermo_function(param_set.TPS,...)
    cm0_output = Microphysics_0m.microphys_function(param_set.MPS,...)
    ...
end
```
These functions should be written with this in mind (dispatching)
```julia
function microphys_function(param_set::Microphysics_0M_parameters,...)
   qc_0 = param_set.qc_0
   ...
end
```


