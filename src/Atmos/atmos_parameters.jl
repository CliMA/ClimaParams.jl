# SubgridScale parameters
const AtmosSGS = CLIMAParameters.Atmos.SubgridScale

AtmosSGS.C_smag(::AbstractEarthParameterSet)            = 0.21
AtmosSGS.C_drag(::AbstractEarthParameterSet)            = 0.0011
AtmosSGS.inv_Pr_turb(::AbstractEarthParameterSet)       = 3
AtmosSGS.Prandtl_air(::AbstractEarthParameterSet)       = 71/100
AtmosSGS.c_a_KASM(::AbstractEarthParameterSet)          = 0.10
AtmosSGS.c_e1_KASM(::AbstractEarthParameterSet)         = 0.19
AtmosSGS.c_e2_KASM(::AbstractEarthParameterSet)         = 0.51
AtmosSGS.c_1_KASM(ps::AbstractEarthParameterSet)        = AtmosSGS.c_a_KASM(ps)*0.76^2
AtmosSGS.c_2_KASM(ps::AbstractEarthParameterSet)        = AtmosSGS.c_e2_KASM(ps)+2*AtmosSGS.c_1_KASM(ps)
AtmosSGS.c_3_KASM(ps::AbstractEarthParameterSet)        = AtmosSGS.c_a_KASM(ps)^(3/2)

# EDMF parameters
const EDMF = CLIMAParameters.Atmos.EDMF

# Entrainment - detrainment model
EDMF.c_λ(::AbstractEarthParameterSet)            = 0.3
EDMF.c_ε(::AbstractEarthParameterSet)            = 0.13
EDMF.c_δ(::AbstractEarthParameterSet)            = 0.52
EDMF.c_t(::AbstractEarthParameterSet)            = 0.1
EDMF.β(::AbstractEarthParameterSet)              = 2
EDMF.μ_0(::AbstractEarthParameterSet)            = 4e-4
EDMF.χ(::AbstractEarthParameterSet)              = 0.25
EDMF.w_min(::AbstractEarthParameterSet)          = 0.1
EDMF.lim_ϵ(::AbstractEarthParameterSet)          = 1e-4
EDMF.lim_amp(::AbstractEarthParameterSet)        = 10

# Subdomain model
EDMF.a_min(::AbstractEarthParameterSet)          = 0.001

# Surface model
EDMF.a_surf(::AbstractEarthParameterSet)         = 0.1
EDMF.κ_star²(::AbstractEarthParameterSet)        = 3.75
EDMF.ψϕ_stab(::AbstractEarthParameterSet)        = 8.3

# Pressure model
EDMF.α_d(::AbstractEarthParameterSet)            = 10.0
EDMF.α_a(::AbstractEarthParameterSet)            = 0.1
EDMF.α_b(::AbstractEarthParameterSet)            = 0.12
EDMF.H_up_min(::AbstractEarthParameterSet)       = 500

# Mixing length model
EDMF.c_d(::AbstractEarthParameterSet)            = 0.22
EDMF.c_m(::AbstractEarthParameterSet)            = 0.14
EDMF.c_b(::AbstractEarthParameterSet)            = 0.63
EDMF.a1(::AbstractEarthParameterSet)             = 0.2
EDMF.a2(::AbstractEarthParameterSet)             = 100
EDMF.ω_pr(::AbstractEarthParameterSet)           = 53.0 / 13.0
EDMF.Pr_n(::AbstractEarthParameterSet)           = 0.74
EDMF.Ri_c(::AbstractEarthParameterSet)           = 0.25
EDMF.smin_ub(::AbstractEarthParameterSet)           = 0.1
EDMF.smin_rm(::AbstractEarthParameterSet)           = 1.5

# 0-moment microphysics parameters
const Microphysics_0M = CLIMAParameters.Atmos.Microphysics_0M

Microphysics_0M.τ_precip(::AbstractEarthParameterSet) = 1000
Microphysics_0M.qc_0(::AbstractEarthParameterSet)     = 5e-3
Microphysics_0M.S_0(::AbstractEarthParameterSet)      = 0.02

# 1-moment microphysics parameters
const Microphysics = CLIMAParameters.Atmos.Microphysics

# general
Microphysics.C_drag(::AbstractEarthParameterSet)  = 0.55
Microphysics.K_therm(::AbstractEarthParameterSet) = 2.4e-2
Microphysics.D_vapor(::AbstractEarthParameterSet) = 2.26e-5
Microphysics.ν_air(::AbstractEarthParameterSet)   = 1.6e-5
Microphysics.N_Sc(ps::AbstractEarthParameterSet)  =
    Microphysics.ν_air(ps)/Microphysics.D_vapor(ps)

# cloud water
Microphysics.τ_cond_evap(::AbstractLiquidParameterSet) = 10

# cloud ice
Microphysics.τ_sub_dep(::AbstractIceParameterSet)  = 10
Microphysics.r_ice_snow(::AbstractIceParameterSet) = 62.5 * 1e-6
Microphysics.n0(::AbstractIceParameterSet)         = 1e7 * 2
Microphysics.r0(::AbstractIceParameterSet)         = 1e-5
Microphysics.me(::AbstractIceParameterSet)         = 3
Microphysics.m0(
    ps::AbstractEarthParameterSet, ps_ice::AbstractIceParameterSet
) = 4/3 * π * CLIMAParameters.Planet.ρ_cloud_ice(ps) *
    Microphysics.r0(ps_ice)^Microphysics.me(ps_ice)
Microphysics.χm(::AbstractIceParameterSet)         = 1
Microphysics.Δm(::AbstractIceParameterSet)         = 0

# rain
Microphysics.q_liq_threshold(::AbstractRainParameterSet) = 5e-4
Microphysics.τ_acnv(::AbstractRainParameterSet)          = 1e3
Microphysics.a_vent(::AbstractRainParameterSet)          = 1.5
Microphysics.b_vent(::AbstractRainParameterSet)          = 0.53
Microphysics.n0(::AbstractRainParameterSet)              = 8e6 * 2
Microphysics.r0(::AbstractRainParameterSet)              = 1e-3
Microphysics.me(::AbstractRainParameterSet)              = 3
Microphysics.ae(::AbstractRainParameterSet)              = 2
Microphysics.ve(::AbstractRainParameterSet)              = 0.5
Microphysics.m0(
    ps::AbstractEarthParameterSet, ps_rain::AbstractRainParameterSet
) = 4/3 * π * CLIMAParameters.Planet.ρ_cloud_liq(ps) *
    Microphysics.r0(ps_rain)^Microphysics.me(ps_rain)
Microphysics.a0(ps_rain::AbstractRainParameterSet) =
    π * Microphysics.r0(ps_rain)^Microphysics.ae(ps_rain)
Microphysics.χm(::AbstractRainParameterSet)              = 1
Microphysics.Δm(::AbstractRainParameterSet)              = 0
Microphysics.χa(::AbstractRainParameterSet)              = 1
Microphysics.Δa(::AbstractRainParameterSet)              = 0
Microphysics.χv(::AbstractRainParameterSet)              = 1
Microphysics.Δv(::AbstractRainParameterSet)              = 0

# snow
Microphysics.a_vent(::AbstractSnowParameterSet) = 0.65
Microphysics.b_vent(::AbstractSnowParameterSet) = 0.44
# n0_sno = μ_sno (ρ q_sno / ρ_0)^ν_sno;  ρ_0 = 1kg/m3
Microphysics.μ_sno(::AbstractSnowParameterSet)  = 4.36 * 1e9
Microphysics.ν_sno(::AbstractSnowParameterSet)  = 0.63
Microphysics.r0(::AbstractSnowParameterSet)     = 1e-3
Microphysics.me(::AbstractSnowParameterSet)     = 2
Microphysics.ae(::AbstractSnowParameterSet)     = 2
Microphysics.ve(::AbstractSnowParameterSet)     = 0.25
Microphysics.m0(
    ps_snow::AbstractSnowParameterSet
) = 1e-1 * Microphysics.r0(ps_snow)^Microphysics.me(ps_snow)
Microphysics.a0(
    ps_snow::AbstractSnowParameterSet
) = 0.3 * π * Microphysics.r0(ps_snow)^Microphysics.ae(ps_snow)
Microphysics.v0(
    ps_snow::AbstractSnowParameterSet
) = 2^(9/4) * Microphysics.r0(ps_snow)^Microphysics.ve(ps_snow)
Microphysics.χm(::AbstractSnowParameterSet)     = 1
Microphysics.Δm(::AbstractSnowParameterSet)     = 0
Microphysics.χa(::AbstractSnowParameterSet)     = 1
Microphysics.Δa(::AbstractSnowParameterSet)     = 0
Microphysics.χv(::AbstractSnowParameterSet)     = 1
Microphysics.Δv(::AbstractSnowParameterSet)     = 0

# interactions
Microphysics.E(::AbstractLiquidParameterSet, ::AbstractRainParameterSet) = 0.8
Microphysics.E(::AbstractLiquidParameterSet, ::AbstractSnowParameterSet) = 0.1
Microphysics.E(::AbstractIceParameterSet,   ::AbstractRainParameterSet)  = 1
Microphysics.E(::AbstractIceParameterSet,   ::AbstractSnowParameterSet)  = 0.1
Microphysics.E(::AbstractRainParameterSet,  ::AbstractSnowParameterSet)  = 1
Microphysics.E(
    ps_snow::AbstractSnowParameterSet,  ps_rain::AbstractRainParameterSet
) = Microphysics.E(ps_rain,  ps_snow)
