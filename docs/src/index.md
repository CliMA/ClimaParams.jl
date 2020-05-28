# CLIMAParameters.jl

This package contains all of the parameters use across the [CliMA](https://github.com/CliMA) organization.

## Usage

### Using default values

```@example
using CLIMAParameters:AbstractEarthParameterSet
using CLIMAParameters.Planet: grav

struct EarthParameterSet <: AbstractEarthParameterSet end
const param_set = EarthParameterSet()
_grav = Float32(grav(param_set))
```

### Overriding defaults

```@example
using CLIMAParameters
import CLIMAParameters.Planet: grav

struct EarthParameterSet <: AbstractEarthParameterSet end
const param_set = EarthParameterSet()
CLIMAParameters.Planet.grav(::EarthParameterSet) = 2.0
_grav = Float32(grav(param_set))
```
