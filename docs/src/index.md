# CLIMAParameters.jl

This package contains all of the parameters used across the [CliMA](https://github.com/CliMA) organization. Some parameters are simply global constants (e.g., speed of light), while others are parameters that may be tuned in a machine-learning layer that sits on-top of the climate model.

## What parameters are good candidates for CLIMAParameters?

CLIMAParameters serve several functionalities and require certain attributes. A parameter is a good candidate for CLIMAParameters if it has _all_ of the following attributes:

 - The parameter does not vary in space
 - The parameter does not vary in time (per climate simulation)
 - The parameter is a function of only constants other CLIMAParameters and or constants

In addition, CLIMAParameters have the flexibility of two important behaviors:

## Usage

See the [The TOML parameter file interface](@ref) and [Parameter Dictionaries](@ref) for usage examples.

