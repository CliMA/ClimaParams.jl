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

module EDMF

export c_λ,
       c_ε,
       c_δ,
       c_t,
       β,
       μ_0,
       χ,
       w_min,
       lim_ϵ,
       lim_amp,
       a_min,
       a_surf,
       κ_star²,
       ψϕ_stab,
       α_d,
       α_a,
       α_b,
       H_up_min,
       c_d,
       c_m,
       c_b,
       a1,
       a2,
       ω_pr,
       Pr_n,
       Ri_c,
       smin_ub,
       smin_rm

""" Entrainment TKE scale (dimensionless) """
function c_λ end

""" Entrainment factor (dimensionless) """
function c_ε end

""" Detrainment factor (dimensionless) """
function c_δ end

""" Turbulent Entrainment factor (dimensionless) """
function c_t end

""" Detrainment RH power (dimensionless) """
function β end

""" Logistic function scale (s``^{-1}``) """
function μ_0 end

""" Updraft mixing fraction (dimensionless) """
function χ end

""" Minimum updraft velocity (m/s) """
function w_min end

""" Exponential area limiter scale (dimensionless) """
function lim_ϵ end

""" Exponential area limiter amplitude(dimensionless) """
function lim_amp end

""" Minimum area fraction for any subdomain (dimensionless) """
function a_min end

""" Updraft surface area fraction (dimensionless) """
function a_surf end

""" Square ratio of rms turbulent velocity to friction velocity (dimensionless) """
function κ_star² end

""" Surface covariance stability coefficient (dimensionless) """
function ψϕ_stab end

""" Pressure drag factor (dimensionless) """
function α_d end

""" Advective pressure factor (dimensionless """
function α_a end

""" Buoyancy pressure factor (dimensionless) """
function α_b end

""" Minimum updraft height for closures (m) """
function H_up_min end

""" Environmental dissipation factor (dimensionless) """
function c_d end

""" Eddy viscosity factor (dimensionless) """
function c_m end

""" Static stability factor (dimensionless) """
function c_b end

""" Empirical stability function coefficient (dimensionless) """
function a1 end

""" Empirical stability function coefficient (dimensionless) """
function a2 end

""" Prandtl number empirical coefficient (dimensionless) """
function ω_pr end

""" Neutral Prandtl number (dimensionless) """
function Pr_n end

""" Critical Richardson number (dimensionless) """
function Ri_c end

""" Smooth minimum's fractional upper bound (dimensionless) """
function smin_ub end

""" Smooth minimum's regularization length minimum (m) """
function smin_rm end

end # module EDMF

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
