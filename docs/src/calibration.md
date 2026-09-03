```@meta
CurrentModule = ClimaParams
```

# Calibration Metadata

A parameter file is not just a list of values. Alongside `value` and `type`, an
entry can carry the statistical metadata a calibration needs:

- a **prior distribution**, `prior`, describing the plausible range of the parameter before any data is assimilated, and
- a **constraint**, `constraint`, giving the transformation between the physical (constrained) space the model uses and the unconstrained space in which the calibration algorithm works.

[EnsembleKalmanProcesses.jl](https://github.com/CliMA/EnsembleKalmanProcesses.jl)
(EKP) reads these fields from the same TOML files that ClimaParams.jl reads, so
one file defines both what a model runs with and what a calibration is allowed
to change. ClimaParams.jl carries the fields through untouched: it neither
parses nor validates them.

## A calibratable parameter

```TOML
[entr_coeff]
value = 0.3
type = "float"
description = "Entrainment coefficient for the EDMF updraft (unitless)."
prior = "Parameterized(Normal(-1.2, 0.4))"
constraint = "bounded_below(0.0)"
```

The prior is specified in the *unconstrained* space, and the constraint maps it
back to the physical space. Here, a normal prior on the unconstrained variable
combined with `bounded_below(0.0)` gives a log-normal prior on `entr_coeff`
itself, which keeps every ensemble member positive.

Loading this file with ClimaParams.jl yields the value, as always:

```@example calib
import ClimaParams as CP

entry = Dict(
    "entr_coeff" => Dict(
        "value" => 0.3,
        "type" => "float",
        "description" => "Entrainment coefficient for the EDMF updraft (unitless).",
        "prior" => "Parameterized(Normal(-1.2, 0.4))",
        "constraint" => "bounded_below(0.0)",
    ),
)
toml_dict = CP.create_toml_dict(Float64; override_file = entry)
toml_dict["entr_coeff"]
```

while EKP reads the same entry to build the prior:

```julia
import EnsembleKalmanProcesses.TOMLInterface as TI

param_dict = TI.get_parameter_values(TI.toml_dict, ["entr_coeff"])
prior = TI.get_parameter_distribution(param_dict, "entr_coeff")
```

## The `prior` field

`prior` is a string holding a Julia expression, parsed by EKP. Four forms are
accepted, plus one sentinel:

| Form                                                            | Use                                                                                   |
|:----------------------------------------------------------------|:---------------------------------------------------------------------------------------|
| `"Parameterized(Normal(0.0, 1.0))"`                             | A named [Distributions.jl](https://juliastats.org/Distributions.jl/) distribution over the unconstrained variable. |
| `"constrained_gaussian(name, mean, std, lower, upper)"`         | A Gaussian specified directly in physical space, with bounds. No separate `constraint` is needed. |
| `"Samples([...])"`                                              | An empirical prior given as a matrix of samples.                                       |
| `"VectorOfParameterized(repeat([Normal(0, 1)], 5))"`            | A vector-valued parameter, one distribution per component.                             |
| `"fixed"`                                                       | Marks the parameter as not calibratable; EKP skips it.                                 |

`constrained_gaussian` is usually the most convenient form, because the
mean and standard deviation are stated in the units the parameter actually has:

```TOML
[entr_coeff]
value = 0.3
type = "float"
description = "Entrainment coefficient for the EDMF updraft (unitless)."
prior = "constrained_gaussian(entr_coeff, 0.3, 0.15, 0.0, Inf)"
```

## The `constraint` field

A constraint is a bijection between the bounded physical range of a parameter
and the whole real line, which is what lets an ensemble Kalman update — which
assumes Gaussian, unbounded variables — respect a physical bound. EKP applies it
with `transform_unconstrained_to_constrained` before each forward run and
`transform_constrained_to_unconstrained` after.

| `constraint`             | Physical range   | Transformation                        |
|:-------------------------|:-----------------|:----------------------------------------|
| `"no_constraint()"`      | ``(-∞, ∞)``      | identity                               |
| `"bounded_below(lb)"`    | ``(lb, ∞)``      | shifted logarithm                      |
| `"bounded_above(ub)"`    | ``(-∞, ub)``     | shifted, reflected logarithm           |
| `"bounded(lb, ub)"`      | ``(lb, ub)``     | logit                                  |

For a vector-valued parameter, `"repeat(bounded_below(0.0), 5)"` applies the
same constraint to each component.

A `constraint` is required whenever the prior is given as `Parameterized`,
`Samples`, or `VectorOfParameterized`. It is not needed with
`constrained_gaussian`, which already carries its bounds.

## Regularization

A parameter may carry a single `L1` or `L2` entry, giving the coefficient of the
corresponding regularization term in the calibration objective. Setting both is
an error.

```TOML
[entr_coeff]
value = 0.3
type = "float"
description = "Entrainment coefficient for the EDMF updraft (unitless)."
prior = "constrained_gaussian(entr_coeff, 0.3, 0.15, 0.0, Inf)"
L2 = 1.0
```

## Where calibration metadata belongs

Calibration metadata is experiment-specific: which parameters are free, and how
free they are, is a property of a calibration campaign rather than of the
parameter itself. Put `prior`, `constraint`, and `L1`/`L2` in the **override
file for the calibration**, not in the bundled default file, and let the default
file carry the value, type, and description.

An ensemble member's parameter file is then the default file plus a small
override, which is exactly the file EKP writes back out for each member.
Because the log file written by [`log_parameter_information`](@ref) is itself a
valid parameter file, the whole cycle stays reproducible.
