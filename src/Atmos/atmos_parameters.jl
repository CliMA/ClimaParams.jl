# SubgridScale parameters
const AtmosSGS = CLIMAParameters.Atmos.SubgridScale

AtmosSGS.C_smag(::AEPS)            = 0.21
AtmosSGS.C_drag(::AEPS)            = 0.0011
AtmosSGS.inv_Pr_turb(::AEPS)       = 3
AtmosSGS.Prandtl_air(::AEPS)       = 71/100
AtmosSGS.c_a_KASM(::AEPS)          = 0.10
AtmosSGS.c_e1_KASM(::AEPS)         = 0.19
AtmosSGS.c_e2_KASM(::AEPS)         = 0.51
AtmosSGS.c_1_KASM(ps::AEPS)        = AtmosSGS.c_a_KASM(ps)*0.76^2
AtmosSGS.c_2_KASM(ps::AEPS)        = AtmosSGS.c_e2_KASM(ps)+2*AtmosSGS.c_1_KASM(ps)
AtmosSGS.c_3_KASM(ps::AEPS)        = AtmosSGS.c_a_KASM(ps)^(3/2)

# EDMF parameters
const EDMF = CLIMAParameters.Atmos.EDMF

# Entrainment - detrainment model
EDMF.c_λ(::AEPS)            = 0.3
EDMF.c_ε(::AEPS)            = 0.13
EDMF.c_δ(::AEPS)            = 0.52
EDMF.c_t(::AEPS)            = 0.1
EDMF.β(::AEPS)              = 2
EDMF.μ_0(::AEPS)            = 4e-4
EDMF.χ(::AEPS)              = 0.25
EDMF.w_min(::AEPS)          = 0.1
EDMF.lim_ϵ(::AEPS)          = 1e-4
EDMF.lim_amp(::AEPS)        = 10

# Subdomain model
EDMF.a_min(::AEPS)          = 0.001

# Surface model
EDMF.a_surf(::AEPS)         = 0.1
EDMF.κ_star²(::AEPS)        = 3.75
EDMF.ψϕ_stab(::AEPS)        = 8.3

# Pressure model
EDMF.α_d(::AEPS)            = 10.0
EDMF.α_a(::AEPS)            = 0.1
EDMF.α_b(::AEPS)            = 0.12
EDMF.H_up_min(::AEPS)       = 500

# Mixing length model
EDMF.c_d(::AEPS)            = 0.22
EDMF.c_m(::AEPS)            = 0.14
EDMF.c_b(::AEPS)            = 0.63
EDMF.a1(::AEPS)             = 0.2
EDMF.a2(::AEPS)             = 100
EDMF.ω_pr(::AEPS)           = 53.0 / 13.0
EDMF.Pr_n(::AEPS)           = 0.74
EDMF.Ri_c(::AEPS)           = 0.25
EDMF.smin_ub(::AEPS)           = 0.1
EDMF.smin_rm(::AEPS)           = 1.5

# 0-moment microphysics parameters
const Microphysics_0M = CLIMAParameters.Atmos.Microphysics_0M

Microphysics_0M.τ_precip(::AEPS) = 1000
Microphysics_0M.qc_0(::AEPS)     = 5e-3
Microphysics_0M.S_0(::AEPS)      = 0.02

# 1-moment microphysics parameters
const Microphysics = CLIMAParameters.Atmos.Microphysics

# general
Microphysics.C_drag(::AEPS)  = 0.55
Microphysics.K_therm(::AEPS) = 2.4e-2
Microphysics.D_vapor(::AEPS) = 2.26e-5
Microphysics.ν_air(::AEPS)   = 1.6e-5
Microphysics.N_Sc(ps::AEPS)  = Microphysics.ν_air(ps)/Microphysics.D_vapor(ps)

# cloud water
Microphysics.τ_cond_evap(::AEPS) = 10

# cloud ice
Microphysics.τ_sub_dep(::AEPS)  = 10
Microphysics.r_ice_snow(::AEPS) = 62.5 * 1e-6
Microphysics.n0_ice(::AEPS)         = 1e7 * 2
Microphysics.r0_ice(::AEPS)         = 1e-5
Microphysics.me_ice(::AEPS)         = 3
Microphysics.m0_ice(ps::AEPS) = 4/3 * π *
    CLIMAParameters.Planet.ρ_cloud_ice(ps) *
    Microphysics.r0_ice(ps)^Microphysics.me_ice(ps)
Microphysics.χm_ice(::AEPS)         = 1
Microphysics.Δm_ice(::AEPS)         = 0

# rain
Microphysics.q_liq_threshold(::AEPS) = 5e-4
Microphysics.τ_acnv_rai(::AEPS)      = 1e3
Microphysics.a_vent_rai(::AEPS)          = 1.5
Microphysics.b_vent_rai(::AEPS)          = 0.53
Microphysics.n0_rai(::AEPS)              = 8e6 * 2
Microphysics.r0_rai(::AEPS)              = 1e-3
Microphysics.me_rai(::AEPS)              = 3
Microphysics.ae_rai(::AEPS)              = 2
Microphysics.ve_rai(::AEPS)              = 0.5
Microphysics.m0_rai(ps::AEPS) = 4/3 * π *
    CLIMAParameters.Planet.ρ_cloud_liq(ps) *
    Microphysics.r0_rai(ps)^Microphysics.me_rai(ps)
Microphysics.a0_rai(ps::AEPS) = π * Microphysics.r0_rai(ps)^Microphysics.ae_rai(ps)
Microphysics.χm_rai(::AEPS)              = 1
Microphysics.Δm_rai(::AEPS)              = 0
Microphysics.χa_rai(::AEPS)              = 1
Microphysics.Δa_rai(::AEPS)              = 0
Microphysics.χv_rai(::AEPS)              = 1
Microphysics.Δv_rai(::AEPS)              = 0

# snow
Microphysics.q_ice_threshold(::AEPS) = 1e-6
Microphysics.τ_acnv_sno(::AEPS)      = 1e2
Microphysics.a_vent_sno(::AEPS) = 0.65
Microphysics.b_vent_sno(::AEPS) = 0.44
# n0_sno = μ_sno (ρ q_sno / ρ_0)^ν_sno;  ρ_0 = 1kg/m3
Microphysics.μ_sno(::AEPS)  = 4.36 * 1e9
Microphysics.ν_sno(::AEPS)  = 0.63
Microphysics.r0_sno(::AEPS)     = 1e-3
Microphysics.me_sno(::AEPS)     = 2
Microphysics.ae_sno(::AEPS)     = 2
Microphysics.ve_sno(::AEPS)     = 0.25
Microphysics.m0_sno(ps::AEPS)   = 1e-1 * Microphysics.r0_sno(ps)^Microphysics.me_sno(ps)
Microphysics.a0_sno(ps::AEPS)   = 0.3 * π * Microphysics.r0_sno(ps)^Microphysics.ae_sno(ps)
Microphysics.v0_sno(ps::AEPS)   = 2^(9/4) * Microphysics.r0_sno(ps)^Microphysics.ve_sno(ps)
Microphysics.χm_sno(::AEPS)     = 1
Microphysics.Δm_sno(::AEPS)     = 0
Microphysics.χa_sno(::AEPS)     = 1
Microphysics.Δa_sno(::AEPS)     = 0
Microphysics.χv_sno(::AEPS)     = 1
Microphysics.Δv_sno(::AEPS)     = 0

# interactions
Microphysics.E_liq_rai(ps::AEPS) = 0.8
Microphysics.E_liq_sno(ps::AEPS) = 0.1
Microphysics.E_ice_rai(ps::AEPS) = 1
Microphysics.E_ice_sno(ps::AEPS) = 0.1
Microphysics.E_rai_sno(ps::AEPS) = 1
