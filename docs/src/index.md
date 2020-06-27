# CLIMAParameters.jl

This package contains all of the parameters use across the [CliMA](https://github.com/CliMA) organization. Some parameters are simply global constants (e.g., speed of light), while others are parameters that may be tuned in a machine-learning layer that sits on-top of [ClimateMachine.jl](https://github.com/CliMa/ClimateMachine.jl).

## What parameters are good candidates for CLIMAParameters?

CLIMAParameters serve several functionalities and require certain attributes. A parameter is a good candidate for CLIMAParameters if it has _all_ of the following attributes:

 - The parameter does not vary in space
 - The parameter does not vary in time (per climate simulation)
 - The parameter is a function of only constants other CLIMAParameters and or constants

In addition, CLIMAParameters have the flexibility of two important behaviors:

### Behavior 1) Compile-time constants

This behavior is used for parameters that **will not** be tuned in the machine-learning layer. Therefore, these parameters can be constant-propagated[^1] and constant-folded[^2] at compile time. This is behavior is achieved by leveraging Julia's type system, and only relying on singleton types[^3]:

```@example
using CLIMAParameters:AbstractEarthParameterSet
using InteractiveUtils
import CLIMAParameters.Planet: grav # imported for illustrative purposes

struct EarthParameterSet <: AbstractEarthParameterSet end
const param_set = EarthParameterSet()
grav(::EarthParameterSet) = 5.0 # Defined for illustrative purposes
@code_typed grav(param_set)
```

### Behavior 2) Run-time constants

This behavior is used for parameters that **will** be tuned in the machine-learning layer. In this case, it makes sense to create a single binary image that can be reused for several different sets of CLIMAParameters as they are updated in the machine-learning layer. This is behavior is achieved by using composite types[^4] with fields to store/access data:

```@example
using CLIMAParameters:AbstractEarthParameterSet
using InteractiveUtils
import CLIMAParameters # imported for illustrative purposes
using CLIMAParameters.Planet: grav

struct EarthParameterSet{G} <: AbstractEarthParameterSet
  _grav::G
end
const param_set = EarthParameterSet(5.0)
CLIMAParameters.Planet.grav(ps::EarthParameterSet) = ps._grav
@code_typed grav(param_set)
```

## Implementation notes

To maximize the flexibility of use, CLIMAParameters consists of only abstract types[^5]. Concrete types are to be defined and implemented in the application/drivers.

!!! warn
    It is important to include parameter sets in drivers (e.g., `test/`, `examples/` etc.) and **not** `src/` code, as they are intended to be globally consistent and including them in `src/` allows for multiple, and different, parameter sets to be used, resulting in inconsistencies.


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

# References

[^1]: [Constant Propagation](https://en.wikipedia.org/wiki/Constant_folding#Constant_propagation)
[^2]: [Constant Folding](https://en.wikipedia.org/wiki/Constant_folding)
[^3]: [Singleton Types](https://docs.julialang.org/en/v1/manual/types/#man-singleton-types-1)
[^4]: [Composite Types](https://docs.julialang.org/en/v1/base/base/#struct)
[^5]: [Abstract Types](https://docs.julialang.org/en/v1/manual/types/#man-abstract-types-1)

