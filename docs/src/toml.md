# The TOML parameter file interface

The complete user interface consists of two files in `TOML` format
1. A user-defined experiment file - in the local experiment directory
2. A defaults file - in `src/` directory of `ClimaParameters.jl`

## Parameter style-guide

A parameter is determined by its unique name. It has possible attributes
1. `value`
2. `type`
3. `description`
4. `prior`
5. `tag`
6. `transformation`

!!! warn
    Currently we support types: `float`, `integer`, `string` and `bool`.
    Array types are designated by the same `type` as singleton types.

### Minimal parameter requirement to run in CliMA

```TOML
[molar_mass_dry_air]
value = 0.03
type = "float"
```

### A more informative parameter (e.g. found in the defaults file)

```TOML
[molar_mass_dry_air]
value = 0.02897
type = "float"
description = "Molecular weight dry air (kg/mol)"
```

### Properly tagged parameter
To add a tag to a parameter, set the `tag` field with a list of tags.
Tags are an optional convenience and do not create a namespace. All parameter names must be unique.

As an initial convention, parameters will be tagged with the component(s) in which they are used.
This convention will be changed as we see how packages use tags.

```TOML
[prandtl_number_0_grachev]
value = 0.98
type = "float"
description = "Pr_0 for Grachev universal functions. From Grachev et al, 2007. DOI: 10.1007/s10546-007-9177-6"
tag = ["SurfaceFluxes"]
```
If this convention is followed, to obtain the parameters used to build tagged by "surfacefluxes", one could call for example:
```julia
surfacefluxes_params = get_tagged_parameter_values(toml_dict, "surfacefluxes")
```

To match tags, punctuation and capitalization is removed. For more information, see [`fuzzy_match`](@ref Main.fuzzy_match).

### A more complex parameter for calibration

```TOML
[neural_net_entrainment]
value = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
type = "float"
description = "NN weights to represent the non-dimensional entrainment function"
prior = "MvNormal(0,I)"
```

### Interaction of the files

On read an experiment file, the default file is also read and any duplicate parameter attributes are overwritten
e.g. If the minimal example above was loaded from an experiment file, and the informative example above was in the defaults file, then the loaded parameter would look as follows:
``` TOML
[molar_mass_dry_air]
value = 0.03
type = "float"
description = "Molecular weight dry air (kg/mol)"
```
Here, the `value` field has been overwritten by the experiment value.

## File and parameter interaction with CliMA

`ClimaParameters.jl` provides several methods to parse, merge, and log parameter information.

### Loading from file
We provide the following methods to load parameters from file
```julia
create_toml_dict(Float64; override_filepath, default_filepath)
create_toml_dict(Float64; override_filepath)
```
The `Float64` (or `Float32`) defines the requested precision of the returned parameters.

Typical usage involves passing the local parameter file
```julia
import ClimaParameters
local_experiment_file = joinpath(@__DIR__,"local_exp_parameters.toml")
toml_dict = ClimaParameters.create_toml_dict(; override_file = local_experiment_file)
```
If no file is passed it will use only the defaults from `ClimaParameters.jl` (causing errors if required parameters are not within this list).

You can also pass Julia `Dicts` directly to `override_filepath` and `default_filepath`.

If you want to use more than two TOML files, you can merge them with [`merge_toml_files(filepaths...)`](@ref Main.merge_toml_files). By default, duplicate TOML entries are not allowed, but this can be changed by setting `override = true`.

The parameter dict is then used to build the codebase (see Parameter Retrieval for usage and examples).

### Logging parameters

Once the CliMA components are built, it is important to log the parameters. We provide the following method
```julia
log_parameter_information(toml_dict, filepath; strict=false)
```

Typical usage will be after building components and before running
```julia
import Thermodynamics
therm_params = Thermodynamics.ThermodynamicsParameters(toml_dict)
#... build(thermodynamics model,therm_params)

log_file = joinpath(@__DIR__,"parameter_log.toml")
ClimaParameters.log_parameter_information(toml_dict,log_file)

# ... run(thermodynamics_model)
```

This function performs two tasks
1. It writes a parameter log file to `log_file`.
2. It performs parameter sanity checks.

Continuing our previous example, imagine `molar_mass_dry_air` was extracted in `ThermodynamicsParameters`. Then the log file will contain:
``` TOML
[molar_mass_dry_air]
value = 0.03
type = "float"
description = "Molecular weight dry air (kg/mol)"
used_in = ["Thermodynamics"]
```
The additional attribute `used_in` displays every CliMA component that used this parameter.

!!! note
    Log files are written in TOML format, and can be read back into the model.

!!! warn
    It is assumed that all parameters in the local experiment file should be used, if not a warning is displayed when calling `log_parameter_information`. This is upgraded to an error exception by changing `strict`.
