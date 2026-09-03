```@meta
CurrentModule = ClimaParams
```

# ClimaParams.jl

A centralized parameter management system for climate modeling, ClimaParams.jl supports physical constants, planetary properties, and tunable parameters designed for calibration with data assimilation and machine learning tools.

## Overview

ClimaParams.jl provides a single source of truth for the parameters used in the [Climate Modeling Alliance (CliMA)](https://github.com/CliMA) ecosystem. By centralizing parameters across all model components (atmosphere, ocean, land, etc.), it enables joint calibration of interconnected climate processes through data assimilation and machine learning pipelines. This unified approach ensures that parameters shared between components remain consistent and can be optimized together, leading to more physically coherent model calibration.

The package manages two fundamental types of values:
- Physical and planetary *constants* (e.g., speed of light or planet radius)
- Tunable model *parameters* that can be calibrated individually or jointly across components

Alongside a value, a parameter entry carries the metadata a calibration needs: a
prior distribution and the constraint that transforms it to the unconstrained
space in which [EnsembleKalmanProcesses.jl](https://github.com/CliMA/EnsembleKalmanProcesses.jl)
works. See [Calibration Metadata](@ref).

## What parameters are good candidates for ClimaParams?

A parameter is a good candidate for ClimaParams if it has _all_ of the following attributes:

 - The parameter does not vary in space
 - The parameter does not vary in time (per climate simulation)
 - The parameter is a function of only constants and other ClimaParams

## Installation

```julia
julia> ]
pkg> add ClimaParams
```

## Getting Started

The basic flow is as follows:
1. Create the parameter dictionary with your desired floating point type
2. Retrieve parameters

```@example quickstart
import ClimaParams as CP

# Create parameter dictionary with default values
param_dict = CP.create_toml_dict(Float64)

# Retrieve physical constants
constants = CP.get_parameter_values(
    param_dict,
    ["gravitational_acceleration", "planet_radius", "light_speed"],
)
```

```@example quickstart
# Retrieve parameters with custom names
params = CP.get_parameter_values(
    param_dict,
    Dict("universal_gas_constant" => "R", "gravitational_acceleration" => "g"),
)
params.R
```

To customize values for an experiment, write an override file and pass it to
[`create_toml_dict`](@ref); see [Override Files](@ref).

## Best Practices

1. **Give parameters descriptive, globally unique names.** Names are the interface; the TOML file has no namespaces.
2. **Write a `description` with units and a literature source.** For most readers this is the only documentation a parameter will ever have.
3. **Use name maps** to keep short, conventional variable names in your code without shortening the global name.
4. **Pass a component name** when retrieving parameters, so the run's parameter log records who read what.
5. **Build parameter structs** rather than reading the dictionary inside model code, so a component's parameter surface is explicit and type-stable.
6. **Log the parameters at the end of setup** with [`log_parameter_information`](@ref), which also catches typos in override files.

## Documentation Overview

### Core Usage

- **[Parameter retrieval](param_retrieval.md)**: Retrieve parameters from dictionaries, use name maps, and build parameter structs.

### Configuration and File Format

- **[TOML file interface](toml.md)**: Define parameters in TOML files, including value types, descriptions, tags, override files, and run logging.
- **[Calibration metadata](calibration.md)**: Attach prior distributions and constraints for use with EnsembleKalmanProcesses.jl.

### Reference

- **[Parameter list](parameters.md)**: Every parameter in the bundled default file, with its value, type, and description.
- **[API](API.md)**: Reference documentation for the functions and types in ClimaParams.jl.

### Contributing

- **[Adding and changing parameters](contributing.md)**: Conventions for names, descriptions, units, and sources, and the checklist for a parameter pull request.
