module Atmos

module SubgridScale

export C_smag,
       C_drag,
       inv_Pr_turb,
       Prandtl_air,
       c_a_KASM,
       c_e1_KASM,
       c_e2_KASM,
       c_1_KASM,
       c_2_KASM,
       c_3_KASM

""" Smagorinsky Coefficient [dimensionless] """
function C_smag end

""" Drag coefficient """
function C_drag end

"""Turbulent Prandtl Number"""
function inv_Pr_turb end

"""Molecular Prandtl Number, dry air"""
function Prandtl_air end

"""cₐ KASM (2006)"""
function c_a_KASM end

"""cₑ₁ KASM (2006)"""
function c_e1_KASM end

"""cₑ₂ KASM (2006)"""
function c_e2_KASM end

"""c₁  KASM (2006)"""
function c_1_KASM end

"""c₂ KASM (2006)"""
function c_2_KASM end

"""c₃ KASM (2006)"""
function c_3_KASM end

end # module SubgridScale

module Microphysics

export MP_n_0,
       C_drag,
       τ_cond_evap,
       q_liq_threshold,
       τ_acnv,
       E_col,
       a_vent,
       b_vent,
       K_therm,
       D_vapor,
       ν_air,
       N_Sc

"""Marshall-Palmer distribution n_0 coeff [1/m4]"""
function MP_n_0 end

"""drag coefficient for rain drops [-]"""
function C_drag end

"""condensation/evaporation timescale [s]"""
function τ_cond_evap end

"""sublimation/resublimation timescale [s]"""
function τ_sub_resub end

"""autoconversion threshold [-]  ∈(0.5, 1) * 1e-3 """
function q_liq_threshold end

"""autoconversion timescale [s]  ∈(1e3, 1e4) """
function τ_acnv end

"""collision efficiency [-]"""
function E_col end

"""ventilation factor coefficient [-]"""
function a_vent end

"""ventilation factor coefficient [-]"""
function b_vent end

"""thermal conductivity of air [J/m/s/K] """
function K_therm end

"""diffusivity of water vapor [m2/s]"""
function D_vapor end

"""kinematic viscosity of air [m2/s]"""
function ν_air end

"""Schmidt number [-]"""
function N_Sc end

end

end # module Atmos
