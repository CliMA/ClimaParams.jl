AtmosSGS = CLIMAParameters.Atmos.SubgridScale

# SubgridScale parameters
AtmosSGS.C_smag(::AbstractEarthParameterSet)            = 0.21
AtmosSGS.C_drag(::AbstractEarthParameterSet)            = 0.0011
AtmosSGS.inv_Pr_turb(::AbstractEarthParameterSet)       = 3
AtmosSGS.Prandtl_air(::AbstractEarthParameterSet)       = 71//100
AtmosSGS.c_a_KASM(::AbstractEarthParameterSet)          = 0.10
AtmosSGS.c_e1_KASM(::AbstractEarthParameterSet)         = 0.19
AtmosSGS.c_e2_KASM(::AbstractEarthParameterSet)         = 0.51
AtmosSGS.c_1_KASM(ps::AbstractEarthParameterSet)        = AtmosSGS.c_a_KASM(ps)*0.76^2
AtmosSGS.c_2_KASM(ps::AbstractEarthParameterSet)        = AtmosSGS.c_e2_KASM(ps)+2*AtmosSGS.c_1_KASM(ps)
AtmosSGS.c_3_KASM(ps::AbstractEarthParameterSet)        = AtmosSGS.c_a_KASM(ps)^(3/2)

Microphysics = CLIMAParameters.Atmos.Microphysics
# Microphysics parameters
Microphysics.MP_n_0(::AbstractEarthParameterSet)          = 8e6 * 2
Microphysics.C_drag(::AbstractEarthParameterSet)          = 0.55
Microphysics.τ_cond_evap(::AbstractEarthParameterSet)     = 10
Microphysics.τ_sub_resub(::AbstractEarthParameterSet)     = 10
Microphysics.q_liq_threshold(::AbstractEarthParameterSet) = 5e-4
Microphysics.τ_acnv(::AbstractEarthParameterSet)          = 1e3
Microphysics.E_col(::AbstractEarthParameterSet)           = 0.8
Microphysics.a_vent(::AbstractEarthParameterSet)          = 1.5
Microphysics.b_vent(::AbstractEarthParameterSet)          = 0.53
Microphysics.K_therm(::AbstractEarthParameterSet)         = 2.4e-2
Microphysics.D_vapor(::AbstractEarthParameterSet)         = 2.26e-5
Microphysics.ν_air(::AbstractEarthParameterSet)           = 1.6e-5
Microphysics.N_Sc(ps::AbstractEarthParameterSet)          = Microphysics.ν_air(ps)/Microphysics.D_vapor(ps)
