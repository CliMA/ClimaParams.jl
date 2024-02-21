# ClimaParameters.jl

This package contains all of the parameters used across the [CliMA](https://github.com/CliMA) organization. Some parameters are simply global constants (e.g., speed of light), while others are parameters that may be tuned in a machine-learning layer that sits on-top of the climate model.

## What parameters are good candidates for ClimaParameters?

ClimaParameters serve several functionalities and require certain attributes. A parameter is a good candidate for ClimaParameters if it has _all_ of the following attributes:

 - The parameter does not vary in space
 - The parameter does not vary in time (per climate simulation)
 - The parameter is a function of only constants other ClimaParameters and or constants

## Getting Started

The basic flow is as follows:
1. Create the parameter dictionary with your desired floating point type
2. Retrieve parameters
```julia
import ClimaParameters as CP
param_dict = CP.create_toml_dict(Float64)
params = CP.get_parameter_values(param_dict, ["gravitational_acceleration", "planet_radius"])
```

See the [The TOML parameter file interface](@ref) and [Basic Parameter Retrieval](@ref) for detailed usage examples and integration into your code.
