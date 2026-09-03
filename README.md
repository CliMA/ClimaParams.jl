<div align="center">
  <img src="docs/src/assets/logo.svg" alt="ClimaParams.jl Logo" width="128" height="128">
</div>

# ClimaParams.jl

A centralized parameter management system for climate modeling.

ClimaParams.jl is the single source of truth for the physical constants, planetary properties, and tunable parameters used across the [Climate Modeling Alliance (CliMA)](https://github.com/CliMA) ecosystem. Parameters are declared in TOML files and returned as typed Julia values, with the metadata a calibration needs carried in the same file. It is built on `TOML` from the Julia standard library and has no CliMA dependencies.

|||
|------------------:|:------------------------------------------------------------|
| **Documentation** | [![stable][docs-stable-img]][docs-stable-url] [![dev][docs-dev-img]][docs-dev-url] |
| **Version**       | [![version][version-img]][version-url]                      |
| **License**       | [![license][license-img]][license-url]                      |
| **Tests**         | [![gha ci][gha-ci-img]][gha-ci-url]                         |
| **Code Coverage** | [![codecov][codecov-img]][codecov-url]                      |
| **Downloads**     | [![Downloads][dlt-img]][dlt-url]                            |

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://CliMA.github.io/ClimaParams.jl/stable/

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://CliMA.github.io/ClimaParams.jl/dev/

[version-img]: https://juliahub.com/docs/General/ClimaParams/stable/version.svg
[version-url]: https://juliahub.com/ui/Packages/General/ClimaParams

[license-img]: https://img.shields.io/badge/license-Apache%202.0-blue.svg
[license-url]: https://github.com/CliMA/ClimaParams.jl/blob/main/LICENSE

[gha-ci-img]: https://github.com/CliMA/ClimaParams.jl/actions/workflows/ci.yml/badge.svg?branch=main
[gha-ci-url]: https://github.com/CliMA/ClimaParams.jl/actions/workflows/ci.yml?query=branch%3Amain

[codecov-img]: https://codecov.io/gh/CliMA/ClimaParams.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/CliMA/ClimaParams.jl

[dlt-img]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Ftotal_downloads%2FClimaParams&query=total_requests&label=Downloads
[dlt-url]: https://juliapkgstats.com/pkg/ClimaParams

## Overview

Centralizing parameters across all model components (atmosphere, ocean, land, etc.) keeps values that are shared between components consistent, and lets interconnected processes be calibrated jointly rather than one component at a time.

The package manages two categories of values:

- **Constants**: physical values that are not calibrated, including universal constants (e.g. the speed of light) and planet-specific properties (e.g. gravitational acceleration or planetary radius).
- **Model parameters**: tunable values subject to calibration by data assimilation or machine learning, spanning atmospheric physics, land surface, turbulence closures, and biogeochemistry.

## Features

- **Centralized management**: one authoritative file of constants and parameters for the whole ecosystem, so shared values cannot drift between components.
- **Typed retrieval**: each parameter declares its type, and values are converted to `Float32`/`Float64`, `Int`, `String`, `Bool`, or `DateTime` on read, with a float type chosen per simulation.
- **Calibration metadata**: a parameter entry can carry a `prior` distribution and a `constraint` — the transformation between the physical range and the unconstrained space an ensemble Kalman update works in — which [EnsembleKalmanProcesses.jl](https://github.com/CliMA/EnsembleKalmanProcesses.jl) reads from the same TOML file.
- **Override system**: layer experiment-specific files over the defaults, with well-defined precedence and per-attribute merging.
- **Parameter tagging**: group values by model component for bulk retrieval.
- **Reproducibility**: every read is logged, so a run can write out the exact parameter set it used — itself a valid parameter file that reproduces the run.
- **Multi-planet capable**: planetary properties are named generically and defaulted to Earth, so another body is an override file away.

## Installation

```julia
julia> ]
pkg> add ClimaParams
```

## Quick Example

```julia
using ClimaParams

# Floating-point type for parameters
FT = Float64

# Create a dictionary containing all default parameters, cast to the chosen float type
param_dict = create_toml_dict(FT)

# Retrieve a struct of physical constants by name
constants = get_parameter_values(
    param_dict,
    ["gravitational_acceleration", "planet_radius", "light_speed"],
)
constants.gravitational_acceleration  # 9.81

# Retrieve parameters and assign them custom names for convenience
params = get_parameter_values(
    param_dict,
    Dict("universal_gas_constant" => "R", "gravitational_acceleration" => "g"),
)
params.R  # 8.3144598

# Index directly into the dictionary for a single value
param_dict["planet_radius"]  # 6.371e6
```

## Calibration Metadata

A parameter entry is not just a value. Alongside `value` and `type`, it can carry
a prior distribution and the constraint that transforms it to the unconstrained
space in which an ensemble Kalman update operates:

```toml
[entr_coeff]
value = 0.3
type = "float"
description = "Entrainment coefficient for the EDMF updraft (unitless)."
prior = "Parameterized(Normal(-1.2, 0.4))"
constraint = "bounded_below(0.0)"
```

Here the prior is a Gaussian over the *unconstrained* variable, and
`bounded_below(0.0)` maps it back to the physical range, so every ensemble
member stays positive.

`constrained_gaussian` says the same thing in one line, in the units the
parameter actually has. Give it a name, a mean, a standard deviation, and the
lower and upper bounds — in that order — and it fits a distribution whose
samples respect the bounds. No separate `constraint` is needed, because the
bounds are already part of the prior:

```toml
[entr_coeff]
value = 0.3
type = "float"
description = "Entrainment coefficient for the EDMF updraft (unitless)."
prior = "constrained_gaussian(entr_coeff, 0.3, 0.15, 0.0, Inf)"
```

ClimaParams.jl carries these fields through untouched;
[EnsembleKalmanProcesses.jl](https://github.com/CliMA/EnsembleKalmanProcesses.jl)
reads them from the same file to build the prior. One file therefore defines both
what a model runs with and what a calibration is allowed to change. See the
[calibration metadata documentation](https://CliMA.github.io/ClimaParams.jl/dev/calibration/).

## Documentation

- [Stable documentation](https://CliMA.github.io/ClimaParams.jl/stable/) · [dev documentation](https://CliMA.github.io/ClimaParams.jl/dev/)
- [Parameter retrieval](https://CliMA.github.io/ClimaParams.jl/dev/param_retrieval/): name maps, component logging, and parameter structs
- [TOML file interface](https://CliMA.github.io/ClimaParams.jl/dev/toml/): file format, override files, and run logging
- [Calibration metadata](https://CliMA.github.io/ClimaParams.jl/dev/calibration/): priors and constraints for EnsembleKalmanProcesses.jl
- [Parameter list](https://CliMA.github.io/ClimaParams.jl/dev/parameters/): every parameter in the default file, with value, type, and description

## Integration with CliMA Models

Every CliMA package reads its constants from a `ClimaParams` dictionary rather than hard-coding them:

```text
src/parameters.toml
        │  create_toml_dict(FT)
        ▼
toml_dict :: ParamDict
        │  ThermodynamicsParameters(toml_dict), CloudMicrophysicsParameters(toml_dict), ...
        ▼
Library-specific parameter structs
        │  bundled by the model
        ▼
ClimaAtmosParameters / ClimaLandParameters / ...
```

Downstream users include [Thermodynamics.jl](https://github.com/CliMA/Thermodynamics.jl), [CloudMicrophysics.jl](https://github.com/CliMA/CloudMicrophysics.jl), [SurfaceFluxes.jl](https://github.com/CliMA/SurfaceFluxes.jl), [ClimaAtmos.jl](https://github.com/CliMA/ClimaAtmos.jl), [ClimaLand.jl](https://github.com/CliMA/ClimaLand.jl), and [ClimaCoupler.jl](https://github.com/CliMA/ClimaCoupler.jl). Calibration workflows are built on [EnsembleKalmanProcesses.jl](https://github.com/CliMA/EnsembleKalmanProcesses.jl) and [ClimaCalibrate.jl](https://github.com/CliMA/ClimaCalibrate.jl).

## Contributing

Most contributions add or correct a parameter in `src/parameters.toml`. See
[Adding and changing parameters](https://CliMA.github.io/ClimaParams.jl/dev/contributing/)
for the naming, description, and unit conventions, and for the pull request
checklist. Broader CliMA conventions live in the
[CliMA developer guides](https://github.com/CliMA/DeveloperGuides).
