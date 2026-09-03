```@meta
CurrentModule = ClimaParams
```

# The TOML Parameter File Interface

Parameters for CliMA models are defined in `.toml` files. ClimaParams.jl works with two sources of parameters, which are merged:

1.  **A default parameter file**: bundled with ClimaParams.jl, containing the values for the entire CliMA ecosystem. See the [Parameter List](@ref).
2.  **A user-defined override file**: provided for a specific experiment. It only needs to contain the parameters that deviate from the defaults.

## Parameter Format

Each parameter is defined by its unique name as a TOML table header (e.g., `[my_parameter_name]`). It can have the following attributes:

| Attribute        | Required | Meaning                                                                      |
|:-----------------|:---------|:------------------------------------------------------------------------------|
| `value`          | yes      | The value of the parameter; a scalar or an array.                             |
| `type`           | yes      | The data type. See [Parameter Types](@ref).                                   |
| `description`    | strongly recommended | Prose explaining the parameter, its units, and its source.        |
| `tag`            | no       | An array of strings grouping related parameters. See [Parameter tags](@ref).  |
| `prior`          | no       | A prior distribution for calibration. See [Calibration Metadata](@ref).       |
| `constraint`     | no       | The transformation to unconstrained space. See [Calibration Metadata](@ref).  |
| `L1`, `L2`       | no       | A regularization coefficient for calibration.                                 |

ClimaParams.jl itself reads only `value`, `type`, `tag`, and the bookkeeping
field `used_in`. The remaining attributes are carried through untouched for
[EnsembleKalmanProcesses.jl](https://github.com/CliMA/EnsembleKalmanProcesses.jl)
to read from the same file.

!!! warning "On array types"
    Array values use the same `type` declaration as their scalar counterparts. For example, a vector of floats is specified with `type = "float"`.

### Basic Parameter Definition

At a minimum, a parameter requires a `value` and a `type`.

```TOML
[molar_mass_dry_air]
value = 0.02897
type = "float"
```

Include a `description` with units and, for anything that is not a defined
constant, the source it was taken from. CliMA uses SI units.

```TOML
[molar_mass_dry_air]
value = 0.02897
type = "float"
description = "Molar mass of dry air (kg mol⁻¹)."
```

See [Adding and Changing Parameters](@ref) for the full conventions on names,
descriptions, and units.

### Parameter tags

Tags group related parameters so that a whole group can be retrieved in one
call. They do not create namespaces, and all parameter names must remain
globally unique. To add tags, provide a list of strings to the `tag` field.

A recommended convention is to tag parameters with the model component(s) where they are used.

```TOML
[prandtl_number_0_grachev]
value = 0.98
type = "float"
description = "The turbulent Prandtl number in neutral conditions ($Pr_0$) for the Grachev universal functions (unitless). Source: Grachev et al. (2007), DOI: 10.1007/s10546-007-9177-6."
tag = ["SurfaceFluxes"]
```

Parameters with a specific tag can then be retrieved in Julia. Tag matching is case-insensitive and ignores punctuation. For more information, see the API for [`fuzzy_match`](@ref).

```julia
# Retrieves every parameter tagged with "SurfaceFluxes"
sf_params = get_tagged_parameter_values(toml_dict, "surfacefluxes")
```

!!! note "The bundled default file is untagged"
    No parameter in the default `parameters.toml` currently carries a `tag`, so
    [`get_tagged_parameter_values`](@ref) returns an empty `NamedTuple` unless
    the tags come from an override file. The default file instead groups related
    parameters with section comments, which the [Parameter List](@ref) reflects.
    Tagging the default file is tracked as future work; until then, retrieve
    default parameters by name.

## Override Files

When an override file is provided, its values for any given parameter **take precedence** over the default values. Other attributes from the default file (like `description` or `tag`) are merged if they are not present in the override file.

### Override mechanism

For example, if the user's override file contains:
```TOML
[molar_mass_dry_air]
value = 0.03
type = "float"
```
The final, merged parameter used in the simulation will be:
```TOML
[molar_mass_dry_air]
value = 0.03  # <-- Overwritten by the user's value
type = "float"
description = "Molar mass of dry air (kg mol⁻¹)." # <-- Merged from the default file
```

An override file may also introduce parameters that are absent from the default
file, which is how a downstream package adds parameters that are specific to it.

## Interacting with Parameters in Julia

### 1. Loading parameters

The main entry point is [`create_toml_dict`](@ref), which loads, merges, and types the parameters.

```julia
create_toml_dict(FT; override_file = nothing, default_file = ...)
```

The first argument, `FT`, must be a float type (e.g., `Float64` or `Float32`) and determines the precision of all floating-point parameters.

A typical use case involves providing the path to a local override file:
```julia
import ClimaParams

FT = Float64
local_experiment_file = joinpath(@__DIR__, "local_exp_parameters.toml")
toml_dict = ClimaParams.create_toml_dict(FT; override_file = local_experiment_file)
```

If `override_file` is omitted, only the default parameters are loaded. A Julia
`Dict` can be passed instead of a file path.

To combine more than two files, pass the paths as additional positional
arguments; they are merged in the order given, and the merged result then
overrides the defaults.

```julia
toml_dict = ClimaParams.create_toml_dict(FT, "site.toml", "local_exp_parameters.toml")
```

Alternatively, merge the files yourself with [`merge_toml_files`](@ref) and pass
the resulting `Dict` as `override_file`.

### 2. Using and logging parameters

The returned `toml_dict` is then used to construct parameter structs for different model components.

```julia
# Retrieve values and construct the component-specific parameter struct
thermo_params = Thermodynamics.ThermodynamicsParameters(toml_dict)

# ... build the rest of the model components ...

# After all components are built, log the used parameters before running
log_file = joinpath(@__DIR__, "parameter_log.toml")
ClimaParams.log_parameter_information(toml_dict, log_file)

# ... run_model(...) ...
```

The function [`log_parameter_information`](@ref) performs two tasks:
1.  **Writes a log file**: it saves a complete record of every parameter *actually used* in the simulation to `log_file`.
2.  **Performs sanity checks**: it verifies that all parameters in your override file were used.

The log file includes a `used_in` field, which lists every component that requested the parameter. Continuing the example, the log file would contain:

```TOML
[molar_mass_dry_air]
value = 0.03
type = "float"
description = "Molar mass of dry air (kg mol⁻¹)."
used_in = ["Thermodynamics"]
```

!!! note "Reproducibility"
    The generated log file is a valid TOML parameter file and can be used as an `override_file` to exactly reproduce an experiment.

!!! warning "Unused parameter checks"
    By default, [`log_parameter_information`](@ref) issues a warning if any parameter in your override file was not requested by any component. This usually means the name is misspelled. To treat it as a fatal error, pass `strict = true`.
