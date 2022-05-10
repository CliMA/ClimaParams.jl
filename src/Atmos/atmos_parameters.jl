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
EDMF.c_γ(::AEPS)            = 0.075
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
EDMF.c_b(::AEPS)            = 0.4
EDMF.a1(::AEPS)             = 0.2
EDMF.a2(::AEPS)             = 100
EDMF.ω_pr(::AEPS)           = 53.0 / 13.0
EDMF.Pr_n(::AEPS)           = 0.74
EDMF.Ri_c(::AEPS)           = 0.25
EDMF.smin_ub(::AEPS)           = 0.1
EDMF.smin_rm(::AEPS)           = 1.5

# non-equilibrium cloud condensate microphysics parameters
const Microphysics_ne = CLIMAParameters.Atmos.Microphysics_ne

# cloud water
Microphysics_ne.τ_cond_evap(::AEPS) = 10
Microphysics_ne.τ_sub_dep(::AEPS)  = 10

# 0-moment microphysics parameters
const Microphysics_0M = CLIMAParameters.Atmos.Microphysics_0M

Microphysics_0M.τ_precip(::AEPS) = 1000
Microphysics_0M.qc_0(::AEPS)     = 5e-3
Microphysics_0M.S_0(::AEPS)      = 0.02

# 1-moment microphysics parameters
const Microphysics_1M = CLIMAParameters.Atmos.Microphysics_1M

# general
Microphysics_1M.C_drag(::AEPS)  = 0.55
Microphysics_1M.K_therm(::AEPS) = 2.4e-2
Microphysics_1M.D_vapor(::AEPS) = 2.26e-5
Microphysics_1M.ν_air(::AEPS)   = 1.6e-5
Microphysics_1M.N_Sc(ps::AEPS)  = Microphysics_1M.ν_air(ps)/Microphysics_1M.D_vapor(ps)

# cloud ice
Microphysics_1M.r_ice_snow(::AEPS) = 62.5 * 1e-6
Microphysics_1M.n0_ice(::AEPS)         = 1e7 * 2
Microphysics_1M.r0_ice(::AEPS)         = 1e-5
Microphysics_1M.me_ice(::AEPS)         = 3
Microphysics_1M.m0_ice(ps::AEPS) = 4/3 * π *
    CLIMAParameters.Planet.ρ_cloud_ice(ps) *
    Microphysics_1M.r0_ice(ps)^Microphysics_1M.me_ice(ps)
Microphysics_1M.χm_ice(::AEPS)         = 1
Microphysics_1M.Δm_ice(::AEPS)         = 0

# rain
Microphysics_1M.q_liq_threshold(::AEPS) = 5e-4
Microphysics_1M.τ_acnv_rai(::AEPS)      = 1e3
Microphysics_1M.a_vent_rai(::AEPS)          = 1.5
Microphysics_1M.b_vent_rai(::AEPS)          = 0.53
Microphysics_1M.n0_rai(::AEPS)              = 8e6 * 2
Microphysics_1M.r0_rai(::AEPS)              = 1e-3
Microphysics_1M.me_rai(::AEPS)              = 3
Microphysics_1M.ae_rai(::AEPS)              = 2
Microphysics_1M.ve_rai(::AEPS)              = 0.5
Microphysics_1M.m0_rai(ps::AEPS) = 4/3 * π *
    CLIMAParameters.Planet.ρ_cloud_liq(ps) *
    Microphysics_1M.r0_rai(ps)^Microphysics_1M.me_rai(ps)
Microphysics_1M.a0_rai(ps::AEPS) = π * Microphysics_1M.r0_rai(ps)^Microphysics_1M.ae_rai(ps)
Microphysics_1M.χm_rai(::AEPS)              = 1
Microphysics_1M.Δm_rai(::AEPS)              = 0
Microphysics_1M.χa_rai(::AEPS)              = 1
Microphysics_1M.Δa_rai(::AEPS)              = 0
Microphysics_1M.χv_rai(::AEPS)              = 1
Microphysics_1M.Δv_rai(::AEPS)              = 0

# snow
Microphysics_1M.q_ice_threshold(::AEPS) = 1e-6
Microphysics_1M.τ_acnv_sno(::AEPS)      = 1e2
Microphysics_1M.a_vent_sno(::AEPS) = 0.65
Microphysics_1M.b_vent_sno(::AEPS) = 0.44
# n0_sno = μ_sno (ρ q_sno / ρ_0)^ν_sno;  ρ_0 = 1kg/m3
Microphysics_1M.μ_sno(::AEPS)  = 4.36 * 1e9
Microphysics_1M.ν_sno(::AEPS)  = 0.63
Microphysics_1M.r0_sno(::AEPS)     = 1e-3
Microphysics_1M.me_sno(::AEPS)     = 2
Microphysics_1M.ae_sno(::AEPS)     = 2
Microphysics_1M.ve_sno(::AEPS)     = 0.25
Microphysics_1M.m0_sno(ps::AEPS)   = 1e-1 * Microphysics_1M.r0_sno(ps)^Microphysics_1M.me_sno(ps)
Microphysics_1M.a0_sno(ps::AEPS)   = 0.3 * π * Microphysics_1M.r0_sno(ps)^Microphysics_1M.ae_sno(ps)
Microphysics_1M.v0_sno(ps::AEPS)   = 2^(9/4) * Microphysics_1M.r0_sno(ps)^Microphysics_1M.ve_sno(ps)
Microphysics_1M.χm_sno(::AEPS)     = 1
Microphysics_1M.Δm_sno(::AEPS)     = 0
Microphysics_1M.χa_sno(::AEPS)     = 1
Microphysics_1M.Δa_sno(::AEPS)     = 0
Microphysics_1M.χv_sno(::AEPS)     = 1
Microphysics_1M.Δv_sno(::AEPS)     = 0

Microphysics_1M.microph_scaling(::AEPS) = 1.0
Microphysics_1M.microph_scaling_dep_sub(::AEPS) = 1.0
Microphysics_1M.microph_scaling_melt(::AEPS) = 1.0

# interactions
Microphysics_1M.E_liq_rai(ps::AEPS) = 0.8
Microphysics_1M.E_liq_sno(ps::AEPS) = 0.1
Microphysics_1M.E_ice_rai(ps::AEPS) = 1
Microphysics_1M.E_ice_sno(ps::AEPS) = 0.1
Microphysics_1M.E_rai_sno(ps::AEPS) = 1
