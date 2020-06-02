# API

```@meta
CurrentModule = CLIMAParameters
```

## Types

```@docs
AbstractParameterSet
AbstractEarthParameterSet
AbstractMicrophysicsParameterSet
AbstractCloudParameterSet
AbstractPrecipParameterSet
AbstractLiquidParameterSet
AbstractIceParameterSet
AbstractRainParameterSet
AbstractSnowParameterSet
AbstractEmpiricalParameterSet
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
Planet.ρ_ocean
Planet.cp_ocean
Planet.planet_radius
Planet.day
Planet.Omega
Planet.grav
Planet.year_anom
Planet.orbit_semimaj
Planet.TSI
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

### Microphysics

Please see the microphysics [documentation](https://clima.github.io/ClimateMachine.jl/latest/Theory/Atmos/Microphysics/) for an explanation of the default values.

```@docs
Atmos.Microphysics.n0
Atmos.Microphysics.μ_sno
Atmos.Microphysics.ν_sno
Atmos.Microphysics.r0
Atmos.Microphysics.m0
Atmos.Microphysics.χm
Atmos.Microphysics.me
Atmos.Microphysics.Δm
Atmos.Microphysics.a0
Atmos.Microphysics.χa
Atmos.Microphysics.ae
Atmos.Microphysics.Δa
Atmos.Microphysics.v0
Atmos.Microphysics.χv
Atmos.Microphysics.ve
Atmos.Microphysics.Δv
Atmos.Microphysics.C_drag
Atmos.Microphysics.τ_cond_evap
Atmos.Microphysics.τ_sub_dep
Atmos.Microphysics.q_liq_threshold
Atmos.Microphysics.τ_acnv
Atmos.Microphysics.r_ice_snow
Atmos.Microphysics.E
Atmos.Microphysics.a_vent
Atmos.Microphysics.b_vent
Atmos.Microphysics.K_therm
Atmos.Microphysics.D_vapor
Atmos.Microphysics.ν_air
Atmos.Microphysics.N_Sc
```

### Water

```@docs
Water.VIS_0
Water.ST_exp
Water.ST_T_crit
Water.ST_ref
Water.VIS_e1
Water.VIS_e3
Water.VIS_e2
Water.ST_k
Water.ST_corr
```
