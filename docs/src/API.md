# API

```@meta
CurrentModule = CLIMAParameters
using CLIMAParameters
```

## Parameter struct

```@docs
CLIMAParameters.ParamDict
```

## file parsing and parameter logging

```@docs
CLIMAParameters.parse_toml_file
CLIMAParameters.get_parametric_type
CLIMAParameters.iterate_alias
CLIMAParameters.log_component!(param_set::ParamDict,names,component) 
CLIMAParameters.get_values(param_set::ParamDict, names) 
CLIMAParameters.get_parameter_values!
CLIMAParameters.get_parameter_values
CLIMAParameters.check_override_parameter_usage
CLIMAParameters.write_log_file
CLIMAParameters.log_parameter_information
CLIMAParameters.merge_override_default_values
CLIMAParameters.create_parameter_struct(path_to_override, path_to_default)
CLIMAParameters.create_parameter_struct(path_to_override)
CLIMAParameters.create_parameter_struct()
```

## Types

```@docs
AbstractParameterSet
AbstractEarthParameterSet
```

## Universal Constants

```@docs
gas_constant
light_speed
h_Planck
k_Boltzmann
Stefan
astro_unit
avogad
```

## Planet

```@docs
Planet
Planet.molmass_dryair
Planet.R_d
Planet.kappa_d
Planet.cp_d
Planet.cv_d
Planet.ρ_cloud_liq
Planet.ρ_cloud_ice
Planet.molmass_water
Planet.molmass_ratio
Planet.R_v
Planet.cp_v
Planet.cp_l
Planet.cp_i
Planet.cv_v
Planet.cv_l
Planet.cv_i
Planet.T_freeze
Planet.T_min
Planet.T_max
Planet.T_icenuc
Planet.T_triple
Planet.T_0
Planet.LH_v0
Planet.LH_s0
Planet.LH_f0
Planet.e_int_v0
Planet.e_int_i0
Planet.press_triple
Planet.surface_tension_coeff
Planet.entropy_water_vapor
Planet.entropy_dry_air
Planet.entropy_reference_temperature
Planet.ρ_ocean
Planet.cp_ocean
Planet.planet_radius
Planet.day
Planet.Omega
Planet.grav
Planet.year_anom
Planet.orbit_semimaj
Planet.tot_solar_irrad
Planet.epoch
Planet.mean_anom_epoch
Planet.obliq_epoch
Planet.lon_perihelion_epoch
Planet.eccentricity_epoch
Planet.lon_perihelion
Planet.MSLP
Planet.T_surf_ref
Planet.T_min_ref
```

## Common

### Sub-grid scale

```@docs
SubgridScale
SubgridScale.von_karman_const
```

### Surface fluxes and universal functions

```@docs
SurfaceFluxes
SurfaceFluxes.UniversalFunctions
SurfaceFluxes.UniversalFunctions.Pr_0_Businger
SurfaceFluxes.UniversalFunctions.a_m_Businger
SurfaceFluxes.UniversalFunctions.a_h_Businger
SurfaceFluxes.UniversalFunctions.Pr_0_Gryanik
SurfaceFluxes.UniversalFunctions.a_m_Gryanik
SurfaceFluxes.UniversalFunctions.a_h_Gryanik
SurfaceFluxes.UniversalFunctions.b_m_Gryanik
SurfaceFluxes.UniversalFunctions.b_h_Gryanik
SurfaceFluxes.UniversalFunctions.Pr_0_Grachev
SurfaceFluxes.UniversalFunctions.a_m_Grachev
SurfaceFluxes.UniversalFunctions.a_h_Grachev
SurfaceFluxes.UniversalFunctions.b_m_Grachev
SurfaceFluxes.UniversalFunctions.b_h_Grachev
SurfaceFluxes.UniversalFunctions.c_h_Grachev
```

## Atmos

```@docs
Atmos
```

### Sub-grid scale

```@docs
Atmos.SubgridScale.C_smag
Atmos.SubgridScale.C_drag
Atmos.SubgridScale.inv_Pr_turb
Atmos.SubgridScale.Prandtl_air
Atmos.SubgridScale.c_a_KASM
Atmos.SubgridScale.c_e1_KASM
Atmos.SubgridScale.c_e2_KASM
Atmos.SubgridScale.c_1_KASM
Atmos.SubgridScale.c_2_KASM
Atmos.SubgridScale.c_3_KASM
```

### EDMF

```@docs
Atmos.EDMF.c_λ
Atmos.EDMF.c_ε
Atmos.EDMF.c_δ
Atmos.EDMF.c_γ
Atmos.EDMF.β
Atmos.EDMF.μ_0
Atmos.EDMF.χ
Atmos.EDMF.w_min
Atmos.EDMF.lim_ϵ
Atmos.EDMF.lim_amp
Atmos.EDMF.a_min
Atmos.EDMF.a_surf
Atmos.EDMF.κ_star²
Atmos.EDMF.ψϕ_stab
Atmos.EDMF.α_d
Atmos.EDMF.α_a
Atmos.EDMF.α_b
Atmos.EDMF.H_up_min
Atmos.EDMF.c_d
Atmos.EDMF.c_m
Atmos.EDMF.c_b
Atmos.EDMF.a1
Atmos.EDMF.a2
Atmos.EDMF.ω_pr
Atmos.EDMF.Pr_n
Atmos.EDMF.Ri_c
Atmos.EDMF.smin_ub
Atmos.EDMF.smin_rm
```

### Microphysics_0M

```@docs
Atmos.Microphysics_0M.τ_precip
Atmos.Microphysics_0M.qc_0
Atmos.Microphysics_0M.S_0
```

### Microphysics

Please see the microphysics [documentation](https://clima.github.io/ClimateMachine.jl/latest/Theory/Atmos/Microphysics/) for an explanation of the default values.

```@docs
Atmos.Microphysics.C_drag
Atmos.Microphysics.K_therm
Atmos.Microphysics.D_vapor
Atmos.Microphysics.ν_air
Atmos.Microphysics.N_Sc
Atmos.Microphysics.τ_cond_evap
Atmos.Microphysics.τ_sub_dep
Atmos.Microphysics.r_ice_snow
Atmos.Microphysics.n0_ice
Atmos.Microphysics.r0_ice
Atmos.Microphysics.me_ice
Atmos.Microphysics.m0_ice
Atmos.Microphysics.χm_ice
Atmos.Microphysics.Δm_ice
Atmos.Microphysics.q_liq_threshold
Atmos.Microphysics.τ_acnv_rai
Atmos.Microphysics.a_vent_rai
Atmos.Microphysics.b_vent_rai
Atmos.Microphysics.n0_rai
Atmos.Microphysics.r0_rai
Atmos.Microphysics.me_rai
Atmos.Microphysics.ae_rai
Atmos.Microphysics.ve_rai
Atmos.Microphysics.m0_rai
Atmos.Microphysics.a0_rai
Atmos.Microphysics.χm_rai
Atmos.Microphysics.Δm_rai
Atmos.Microphysics.χa_rai
Atmos.Microphysics.Δa_rai
Atmos.Microphysics.χv_rai
Atmos.Microphysics.Δv_rai
Atmos.Microphysics.q_ice_threshold
Atmos.Microphysics.τ_acnv_sno
Atmos.Microphysics.a_vent_sno
Atmos.Microphysics.b_vent_sno
Atmos.Microphysics.μ_sno
Atmos.Microphysics.ν_sno
Atmos.Microphysics.r0_sno
Atmos.Microphysics.me_sno
Atmos.Microphysics.ae_sno
Atmos.Microphysics.ve_sno
Atmos.Microphysics.m0_sno
Atmos.Microphysics.a0_sno
Atmos.Microphysics.v0_sno
Atmos.Microphysics.χm_sno
Atmos.Microphysics.Δm_sno
Atmos.Microphysics.χa_sno
Atmos.Microphysics.Δa_sno
Atmos.Microphysics.χv_sno
Atmos.Microphysics.Δv_sno
Atmos.Microphysics.E_liq_rai
Atmos.Microphysics.E_liq_sno
Atmos.Microphysics.E_ice_rai
Atmos.Microphysics.E_ice_sno
Atmos.Microphysics.E_rai_sno
```
