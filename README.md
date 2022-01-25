# CLIMAParameters.jl

Contains all universal constants and physical parameters in the [CliMA ecosystem](https://github.com/CliMA).

|||
|---------------------:|:----------------------------------------------|
| **Docs Build**       | [![docs build][docs-bld-img]][docs-bld-url]   |
| **Documentation**    | [![dev][docs-dev-img]][docs-dev-url]          |
| **GHA CI**           | [![gha ci][gha-ci-img]][gha-ci-url]           |
| **Code Coverage**    | [![codecov][codecov-img]][codecov-url]        |
| **Bors enabled**     | [![bors][bors-img]][bors-url]                 |

[docs-bld-img]: https://github.com/CliMA/CLIMAParameters.jl/actions/workflows/Docs.yml/badge.svg
[docs-bld-url]: https://github.com/CliMA/CLIMAParameters.jl/actions/workflows/Docs.yml

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://CliMA.github.io/CLIMAParameters.jl/dev/

[gha-ci-img]: https://github.com/CliMA/CLIMAParameters.jl/actions/workflows/ci.yml/badge.svg
[gha-ci-url]: https://github.com/CliMA/CLIMAParameters.jl/actions/workflows/ci.yml

[codecov-img]: https://codecov.io/gh/CliMA/CLIMAParameters.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/CliMA/CLIMAParameters.jl

[bors-img]: https://bors.tech/images/badge_small.svg
[bors-url]: https://app.bors.tech/repositories/24020


# Style Guide for CliMAParameters


# Style Guide for Clima Parameters

## Recipe of a parameter 

A parameter contains several pieces of information
1. Name. 
2. Value
3. Type
4. Prior
5. Transformation
6. Description

The information is split in 3 ways

- Clima reads 1. 2. 3.
- Calibration tools read 1. 2. 4. 5. and overwrite 1.
- Users are interested in 1. 2. 4. 6.

### Parameter name

We distinguish between
- a local parameter symbol. This is used within the source code of a specific model component or repository, when the parameter value is used, it's context is the function scope at definition. Very flexible, usually a letter, or shorthand, perhaps coincident with notation in a referenced work. 
- a high-level desciptive parameter name. Used at the top level in parameter files, user facing, the context is external to any climate model component. Requires a rigid definition. It should be unique, descriptive, understandable (aided by accompanying `description` ) to any climate model user.

Examples of local parameter symbols:
```
α, Γ⁰, x, ens_mult_factor, cv_l, grav
```

Examples of bad parameter names:
```
α, Γ⁰, x, ens_mult_factor, cv_l, grav  # short hands and letters, no context
atmos_alpha_parameter                  # verbose but not descriptive, a model component specified in name
gravitational_acceleration             # descriptive, but still too general for use
```

Examples of good parameter names:
```
gravitational_acceleration_at_sealevel 
dry_air_thermal_conductivity
```

### Parameter value & type
The value of the parameter, the type should be loose but interpretable by code. (Exact list of allowable types are to be defined) but use e.g. `float,integer,string` for now. Type should be unspecific regarding precision of single/double.

### Parameter description
A high-level user readable description of the parameter written in a string. This should include the units of the parameter.

### Parameter prior and transformation
These are used in the calibration process. They should be parsable into a corresponding prior distribution and transformation object by the calibration tools. 

## Parameter file system
We use the TOML interface. Here parameters are listed by name i.e  `[name]`, followed `key = value`  with `key` lower case

Conceptually we have (essentially) two file types `default` and `override`. When we run the code, these are merged, with the `override` fields replacing `defaults` fields where there is a match in `[name]`.

### Defaults file example
Exists in `ClimaParameters.jl`.

An example of a complete parameter default
```
[zero_point_seven]
value = 0.7
type = float
description = "The constant value 0.7, [dimensionless]"
```

### Overrides file example
Exists in a run directory 

For overwriting a default, one requires only the `name` and `value`, though one should include consistent descriptions / types etc if these change

```
[zero_point_seven]
value = 0.699
description = "The constant value 0.699, [dimensionless]"
```

For defining a new parameter (not yet in defaults) we require the same fields as the default.
```
[zero_point_six_nine]
value = 0.69
type = float
description = "The constant value 0.69, [dimensionless]"
```

For calibration one requires the `prior`, `transform` fields. 



