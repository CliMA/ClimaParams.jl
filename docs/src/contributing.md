```@meta
CurrentModule = ClimaParams
```

# Adding and Changing Parameters

Most contributions to ClimaParams.jl add a parameter to `src/parameters.toml`
or correct one that is already there. That file is shared by every CliMA model,
so a small change can reach a long way. This page collects the conventions the
file already follows, and the checklist for a parameter pull request.

For the general CliMA conventions on code, comments, and review, see the
[CliMA developer guides](https://github.com/CliMA/DeveloperGuides).

## Does the parameter belong here?

Add a parameter to `src/parameters.toml` when it satisfies all of:

- it does not vary in space,
- it does not vary in time within a simulation, and
- it is a function only of constants and other ClimaParams parameters.

A quantity that varies by column, by time step, or by configuration is model
state or model configuration, not a parameter. A quantity used by exactly one
downstream package, and never shared, can live in that package's own TOML file
and be merged in as an override.

## Naming

- **Names are globally unique.** The file has no namespaces; tags do not create
  them either. A name collision between two components is a bug in one of them.
- **Use `snake_case`, spelled out.** Prefer `molar_mass_dry_air` to `molmass_dryair`,
  and `temperature_triple_point` to `T_triple`. The short symbol belongs in the
  model code, reached through a name map; see [Name Maps](@ref).
- **Prefix a family with its scheme.** Parameters belonging to one
  parameterization share a prefix, e.g. `nogw_beres_*` for the Beres
  non-orographic gravity wave source, `ssa_*` for sea salt aerosol,
  `*_grachev` for the Grachev universal functions.
- **Never rename or delete a parameter casually.** Downstream packages look
  parameters up by name, so a rename is a breaking change for them. If you must,
  coordinate the change across the repos that read it.

## Descriptions

Every parameter carries a `description`. For most readers it is the only
documentation the parameter will ever have, so it should say what the quantity
is, in what units, and where the value came from.

The conventions the file follows:

- **One or more complete sentences, ending in a period.**
- **Units in parentheses at the end of the first clause**, in SI, e.g. `(m s⁻²)`,
  `(kg mol⁻¹)`, `(J kg⁻¹ K⁻¹)`. Use spaces and Unicode superscripts rather than
  slashes and carets: `m s⁻¹`, not `m/s`.
- **Dimensionless quantities are marked `(unitless)`.**
- **Symbols in LaTeX math**, delimited by `$`, e.g. `($\kappa_d$)`. Backslashes
  must be escaped in TOML basic strings: write `"$\\kappa_d$"`.
- **A source for any empirical value**, in the form
  `Source: Author et al. (year), DOI: 10.xxxx/yyyy.` Defined constants
  (the speed of light, the triple point of water) do not need one; fitted or
  tuned values always do.

```TOML
[prandtl_number_0_grachev]
value = 0.98
type = "float"
description = "The turbulent Prandtl number in neutral conditions ($Pr_0$) for the Grachev universal functions (unitless). Source: Grachev et al. (2007), DOI: 10.1007/s10546-007-9177-6."
```

If a value is derived from other entries, say so, and say how:

```TOML
[length_orbit_semi_major]
value = 149597870700
type = "float"
description = "Semi-major axis of the planetary orbit (m). Derived as 1 * `astronomical_unit`."
```

## Placement in the file

`src/parameters.toml` is grouped by comment headers: `##` marks a top-level
group (`## Microphysics`, `## Aerosols`, ...) and `#` a subsection within it
(`## Microphysics` / `# 1-Moment Scheme`). The [Parameter List](@ref) page is
built from those headers, so the file order is the page order. The file opens
with the universal constants and planetary parameters, then works through the
parameterizations, and ends with the land model, diagnostics, and idealized
benchmarks.

Put a new parameter in the subsection it belongs to rather than appending it to
the end of the file, and open a new subsection, with its own comment, when
adding a family that does not fit an existing one.

A heading is set off by a blank line. A comment written directly above a
parameter, with no blank line between them, is a note about that parameter and
does not start a new section:

```TOML
# Snow

# Measured on fresh powder; revisit for firn.
[snow_density]
value = 200.0
```

## Values

- **Give the value in SI units**, matching the description.
- **Conversion is by construction**, so a value that cannot be represented in
  the declared type is an error, not a silent truncation. An `"integer"`
  parameter written as `2.5` throws an `InexactError` at runtime.

## Priors and constraints

Do not add `prior` or `constraint` to the default file. They belong in the
override file for a calibration campaign; see [Calibration Metadata](@ref).

## Pull request checklist

1. **Add the entry** to the right section of `src/parameters.toml`, with `value`,
   `type`, and a `description` that follows the conventions above.
2. **Add a `NEWS.md` bullet** under the `main` heading, naming the parameters you
   added or changed.
3. **Run the tests**:
   ```
   julia --project=. -e 'using Pkg; Pkg.test()'
   ```
   `test/toml_format.jl` checks the structural conventions on this page; the rest
   of the suite checks that the file still loads, merges, and logs correctly.
4. **Run the formatter** if you touched any Julia code:
   ```
   julia -e 'using JuliaFormatter; format(".")'
   ```
5. **Build the docs** if you touched `docs/`:
   ```
   julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
   julia --project=docs docs/make.jl
   ```
6. **Say who will use it.** Name the downstream PR or package that reads the new
   parameter, so a reviewer can check the name against its call site.

## Changing an existing value

Changing a default value changes results for every model that reads it, so treat
it as a behavioral change:

- State the old value, the new value, and the source for the new one in the PR
  description and in `NEWS.md`.
- Correct the `description` at the same time if it recorded the old provenance.
- Expect downstream reproducibility tests to move; flag that in the PR rather
  than letting a downstream repo discover it.

The v1.1.3 release notes, which corrected Earth's orbital parameters at the
J2000 epoch, are a worked example of the level of detail expected.

## Releasing

ClimaParams.jl is post-1.0 and follows Julia's modified SemVer. Adding a
parameter is additive, so it is a patch bump of `version` in `Project.toml`.
Renaming or removing a parameter, or changing a documented function signature,
is breaking. See the CliMA guide on
[changelogs and versions](https://github.com/CliMA/DeveloperGuides/blob/main/code-quality/changelogs_and_versions.md).
