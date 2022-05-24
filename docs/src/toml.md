# The TOML parameter file interface

The complete user interface consists of two files in `TOML` format
1. A user-defined experiment file - in the local experiment directory
2. A defaults file - in `src/` directory of `CLIMAParameters.jl`

## Parameter style-guide

A parameter is determined by its unique name. It has possible attributes
1. `alias`
2. `value`
3. `type`
4. `description`
5. `prior`
6. `transformation`

!!! warn
    Currently we only support `float` and `array{float}` types. (option-type flags and string switches are not considered CLIMAParameters.)

### Minimal parameter requirement to run in CliMA

```TOML
[molar_mass_dry_air]
value = 0.03
type = "float"
```

### A more informative parameter (e.g. found in the defaults file)

```TOML
[molar_mass_dry_air]
alias = "molmass_dryair"
value = 0.02897
type = "float"
description = "Molecular weight dry air (kg/mol)"
```

### A more complex parameter for calibration

```TOML
[neural_net_entrainment]
alias = "c_gen"
value = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
type = "array"
description = "NN weights to represent the non-dimensional entrainment function"
prior = "MvNormal(0,I)"
```

### Interaction of the files

On read an experiment file, the default file is also read and any duplicate parameter attributes are overwritten
e.g. If the minimal example above was loaded from an experiment file, and the informative example above was in the defaults file, then the loaded parameter would look as follows:
``` TOML
[molar_mass_dry_air]
alias = "molmass_dryair"
value = 0.03
type = "float"
description = "Molecular weight dry air (kg/mol)"
```
Here, the `value` field has been overwritten by the experiment value.

## File and parameter interaction on with CliMA

`CLIMAParameters.jl` provides several methods to parse, merge, and log parameter information.


### Loading from file
We provide the following methods to load parameters from file
```julia
create_toml_dict(Float64;override_filepath, default_filepath, dict_type="alias")
create_toml_dict(Float64;override_filepath ; dict_type="alias")
create_toml_dict(Float64; dict_type="name")
```
- The `dict_type = "name"` or `"alias"` determines the method of lookup of parameters (by `name` or by `alias` attributes).
- The `Float64` (or `Float32`) defines the requested precision of the returned parameters.

Typical usage involves passing the local parameter file
```julia
import CLIMAParameters
local_exp_file = joinpath(@__DIR__,"local_exp_parameters.toml")
toml_dict = CLIMAParameters.create_toml_dict(;local_exp_file)
```
If no file is passed it will use only the defaults from `CLIMAParameters.jl` (causing errors if required parameters are not within this list).

!!! note
    Currently we search by the `alias` field (`dict_type="alias"` by default), so all parameters need an `alias` field, if in doubt, set alias and name to match the current code name convention.

The parameter dict is then used to build the codebase (see relevant Docs page).

### Logging parameters

Once the CliMA components are built, it is important to log the parameters. We provide the following methodd
```julia
log_parameter_information(toml_dict, filepath; strict=false)
```

Typical usage will be after building components and before running
```julia
import Thermodynamics
therm_params = Thermodynamics.ThermodynamicsParameters(toml_dict)
#... build(thermodynamics model,therm_params)

log_file = joinpath(@__DIR__,"parameter_log.toml")
CLIMAParameters.log_parameter_information(toml_dict,log_file)

# ... run(thermodynamics_model)
```

This function performs two tasks
1. It writes a parameter log file to `log_file`.
2. It performs parameter sanity checks.

Continuing our previous example, imagine `molar_mass_dry_air` was extracted in `ThermodynamicsParameters`. Then the log file will contain:
``` TOML
[molar_mass_dry_air]
alias = "molmass_dryair"
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
