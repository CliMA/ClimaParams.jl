"""
    Atmos

Atmospheric parameters.
"""
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

""" Smagorinsky Coefficient (dimensionless) """
function C_smag end

""" Drag coefficient (dimensionless) """
function C_drag end

""" Turbulent Prandtl Number (dimensionless) """
function inv_Pr_turb end

""" Molecular Prandtl Number, dry air (dimensionless) """
function Prandtl_air end

""" ``c_{a}`` KASM, 2006 (dimensionless) """
function c_a_KASM end

""" ``c_{e1}`` KASM, 2006 (dimensionless) """
function c_e1_KASM end

""" ``c_{e2}`` KASM, 2006 (dimensionless) """
function c_e2_KASM end

""" ``c_{1}``  KASM, 2006 (dimensionless) """
function c_1_KASM end

""" ``c_{2}`` KASM, 2006 (dimensionless) """
function c_2_KASM end

""" ``c_{3}`` KASM, 2006 (dimensionless) """
function c_3_KASM end

end # module SubgridScale

module Microphysics_0M

export τ_precip,
       qc_0,
       S_0

""" precipitation removal timescale (s) """
function τ_precip end

""" precipitation removal threshold expressed in condensate specific humidity (kg/kg) """
function qc_0 end

""" precipitation removal threshold expressed in supersaturation (dimensionless) """
function S_0 end

end # module Microphysics_0M

module Microphysics

export n0,
       μ_sno,
       ν_sno,
       r0,
       m0,
       me,
       χm,
       Δm,
       a0,
       ae,
       χa,
       Δa,
       v0,
       ve,
       χv,
       Δv,
       C_drag,
       τ_cond_evap,
       τ_sub_dep,
       q_liq_threshold,
       τ_acnv,
       E,
       r_ice_snow,
       a_vent,
       b_vent,
       K_therm,
       D_vapor,
       ν_air,
       N_Sc

""" Marshall-Palmer distribution `n_0` coeff for rain or snow (1/m``^4``) """
function n0 end

""" coefficient to compute Marshall-Palmer distribution coefficient `n_0(ρq_snow/ρ0)` for snow (1/m``^4``) """
function μ_sno end

""" coefficient to compute Marshall-Palmer distribution coefficient `n_0(ρq_snow/ρ0)` for snow (-) """
function ν_sno end

""" assumed length scale for water drop or ice crystal (m) """
function r0 end

""" coefficient in mass, `radius/r0`, (kg) """
function m0 end

""" coefficient in mass, `radius/r0`, (-) """
function χm end

""" exponent in mass, `radius/r0`, (-) """
function me end

""" exponent in mass, `radius/r0`, (-) """
function Δm end

""" coefficient in area, `radius/r0`, relation (m``^2``) """
function a0 end

""" coefficient in area, `radius/r0`, (-) """
function χa end

""" exponent in area, `radius/r0`, relation """
function ae end

""" exponent in area, `radius/r0`, (-) """
function Δa end

""" coefficient in velocity, `radius/r0`, (m/s) """
function v0 end

""" coefficient in velocity, `radius/r0`, (-) """
function χv end

""" exponent in velocity, `radius/r0`, """
function ve end

""" exponent in velocity, `radius/r0`, (-) """
function Δv end

""" drag coefficient for rain drops (-) """
function C_drag end

""" condensation/evaporation timescale (s) """
function τ_cond_evap end

""" sublimation/deposition timescale (s) """
function τ_sub_dep end

""" autoconversion threshold `∈(0.5, 1) * 1e-3` (-) """
function q_liq_threshold end

""" autoconversion timescale `∈(1e3, 1e4)` (s) """
function τ_acnv end

""" threshold between ice and snow (m) """
function r_ice_snow end

""" collision efficiency (-) """
function E end

""" ventilation factor coefficient for rain or snow (-) """
function a_vent end

""" ventilation factor coefficient for rain or snow (-) """
function b_vent end

""" thermal conductivity of air (J/m/s/K) """
function K_therm end

""" diffusivity of water vapor (m``^2``/s) """
function D_vapor end

""" kinematic viscosity of air (m``^2``/s) """
function ν_air end

""" Schmidt number (-) """
function N_Sc end

end

end # module Atmos
