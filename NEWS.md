ClimaParams.jl Release Notes
========================

v0.10.14
------
- Remove all dependencies ([#208](https://github.com/CliMA/ClimaParams.jl/pull/208))

v0.10.13
------
- Remove mol co2 to kg C factor AutotrophicResp, add kg C to mol CO2 factor Heterotrophic Resp ([#205](https://github.com/CliMA/ClimaParams.jl/pull/205))

v0.10.12
------
- Add diagnostic covariance coeff, change turbulent entrainment parameter vec default  ([#204](https://github.com/CliMA/ClimaParams.jl/pull/204))

v0.10.11
------
- Add data-driven entrainment parameter vector ([#202](https://github.com/CliMA/ClimaParams.jl/pull/202))
- Add data-driven turbulent entrainment parameter vector ([#203](https://github.com/CliMA/ClimaParams.jl/pull/203))

v0.10.10
------
- Add parameters for surface wind gustiness ([#201](https://github.com/CliMA/ClimaParams.jl/pull/201))
- Update default values for edmf parameters ([#200](https://github.com/CliMA/ClimaParams.jl/pull/200))

v0.10.9
------
- Add parameters for RCEMIP surface temperature distribution ([#199](https://github.com/CliMA/ClimaParams.jl/pull/199))

v0.10.8
------
- Add parameters for minimum and maximum temperature for the radiation lookup table ([#198](https://github.com/CliMA/ClimaParams.jl/pull/198))
- Add example of Oceananigans single column model using ClimaParams ([#151](https://github.com/CliMA/ClimaParams.jl/pull/151))

v0.10.7
------
- Add CloudMicrophysics P3 parameters for sink terms ([#192](https://github.com/CliMA/ClimaParams.jl/pull/192))

v0.10.6
------
- Add 2-moment parameters for CloudMicrophysics ([#191](https://github.com/CliMA/ClimaParams.jl/pull/191))

v0.10.5
------
- Add linear fit parameters for homogeneous ice nucleation ([#366](https://github.com/CliMA/CloudMicrophysics.jl/pull/366))

v0.10.4
------
- Add albedo parameters ([#188](https://github.com/CliMA/ClimaParams.jl/pull/188))

v0.10.3
------
- Add Chen Terminal Velocity Table B5 coefficients ([#186](https://github.com/CliMA/ClimaParams.jl/pull/186))
- Add a detrainment parameter ([#187](https://github.com/CliMA/ClimaParams.jl/pull/187))

v0.10.2
-------
- Add parameters for Snow, MedlynConductance, and BeerLambert ([#164](https://github.com/CliMA/ClimaParams.jl/pull/164))
- Add SoilCO2Model Land parameters ([#179](https://github.com/CliMA/ClimaParams.jl/pull/179))

v0.10.1
-------
- Added Bucket model parameters ([#183](https://github.com/CliMA/ClimaParams.jl/pull/183))
- Added Energy Hydrology parameters ([#180](https://github.com/CliMA/ClimaParams.jl/pull/180))

v0.10.0
-------
- Renamed to ClimaParams ([#184](https://github.com/CliMA/ClimaParams.jl/pull/184))

v0.9.0
-------
- Started changelog
- Allow NamedTuples to be used as name maps ([#158](https://github.com/CliMA/ClimaParams.jl/pull/158))
- Update default value for `alpha_rayleigh_uh` ([#160](https://github.com/CliMA/ClimaParams.jl/pull/160))
- Add parameters for water based deposition nucleation for kaolinite, feldspar, and ferrihydrate ([#161](https://github.com/CliMA/ClimaParams.jl/pull/161))
- Fix typos in deposition nucleation parameters ([#162](https://github.com/CliMA/ClimaParams.jl/pull/162))
- Add parameters for the P3 scheme ([#163](https://github.com/CliMA/ClimaParams.jl/pull/163))
- Add autotrophic respiration parameters ([#165](https://github.com/CliMA/ClimaParams.jl/pull/165))
- Remove default type for TOML parsing ([#166](https://github.com/CliMA/ClimaParams.jl/pull/166))
- Replace and add additional ARG2000 parameters ([#130](https://github.com/CliMA/ClimaParams.jl/pull/130))
- Add `T_init_min` for thermodynamics saturation adjustment, changes T_min to 1 Kelvin 🧊 ([#171](https://github.com/CliMA/ClimaParams.jl/pull/171))
- Fix typos and group some parameters together ([#168](https://github.com/CliMA/ClimaParams.jl/pull/168))
- Add Frostenberg et al (2023) parameters ([#174](https://github.com/CliMA/ClimaParams.jl/pull/174))
