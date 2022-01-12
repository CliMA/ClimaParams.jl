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
       c_γ,
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
function c_γ end

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

export C_drag,
       K_therm,
       D_vapor,
       ν_air,
       N_Sc,
       τ_cond_evap,
       τ_sub_dep,
       r_ice_snow,
       n0_ice,
       r0_ice,
       me_ice,
       m0_ice,
       χm_ice,
       Δm_ice,
       q_liq_threshold,
       τ_acnv_rai,
       a_vent_rai,
       b_vent_rai,
       n0_rai,
       r0_rai,
       me_rai,
       ae_rai,
       ve_rai,
       m0_rai,
       a0_rai,
       χm_rai,
       Δm_rai,
       χa_rai,
       Δa_rai,
       χv_rai,
       Δv_rai,
       q_ice_threshold,
       τ_acnv_sno,
       a_vent_sno,
       b_vent_sno,
       μ_sno,
       ν_sno,
       r0_sno,
       me_sno,
       ae_sno,
       ve_sno,
       m0_sno,
       a0_sno,
       v0_sno,
       χm_sno,
       Δm_sno,
       χa_sno,
       Δa_sno,
       χv_sno,
       Δv_sno,
       E_liq_rai,
       E_liq_sno,
       E_ice_rai,
       E_ice_sno,
       E_rai_sno

""" Marshall-Palmer distribution `n_0` coeff for rain or snow (1/m``^4``) """
function n0_ice end
""" Marshall-Palmer distribution `n_0` coeff for rain or snow (1/m``^4``) """
function n0_rai end

""" coefficient to compute Marshall-Palmer distribution coefficient `n_0(ρq_snow/ρ0)` for snow (1/m``^4``) """
function μ_sno end

""" coefficient to compute Marshall-Palmer distribution coefficient `n_0(ρq_snow/ρ0)` for snow (-) """
function ν_sno end

""" assumed length scale for water drop or ice crystal (m) """
function r0_rai end
""" assumed length scale for water drop or ice crystal (m) """
function r0_ice end
""" assumed length scale for water drop or ice crystal (m) """
function r0_sno end

""" coefficient in mass, `radius/r0`, (kg) """
function m0_ice end
""" coefficient in mass, `radius/r0`, (kg) """
function m0_rai end
""" coefficient in mass, `radius/r0`, (kg) """
function m0_sno end

""" coefficient in mass, `radius/r0`, (-) """
function χm_ice end
""" coefficient in mass, `radius/r0`, (-) """
function χm_rai end
""" coefficient in mass, `radius/r0`, (-) """
function χm_sno end

""" exponent in mass, `radius/r0`, (-) """
function me_sno end
""" exponent in mass, `radius/r0`, (-) """
function me_ice end
""" exponent in mass, `radius/r0`, (-) """
function me_rai end

""" exponent in mass, `radius/r0`, (-) """
function Δm_ice end
""" exponent in mass, `radius/r0`, (-) """
function Δm_rai end
""" exponent in mass, `radius/r0`, (-) """
function Δm_sno end

""" coefficient in area, `radius/r0`, relation (m``^2``) """
function a0_rai end
""" coefficient in area, `radius/r0`, relation (m``^2``) """
function a0_sno end

""" coefficient in area, `radius/r0`, (-) """
function χa_rai end
""" coefficient in area, `radius/r0`, (-) """
function χa_sno end

""" exponent in area, `radius/r0`, relation """
function ae_rai end
""" exponent in area, `radius/r0`, relation """
function ae_sno end

""" exponent in area, `radius/r0`, (-) """
function Δa_rai end
""" exponent in area, `radius/r0`, (-) """
function Δa_sno end

""" coefficient in velocity, `radius/r0`, (m/s) """
function v0_sno end

""" coefficient in velocity, `radius/r0`, (-) """
function χv_rai end
""" coefficient in velocity, `radius/r0`, (-) """
function χv_sno end

""" exponent in velocity, `radius/r0`, """
function ve_rai end
""" exponent in velocity, `radius/r0`, """
function ve_sno end

""" exponent in velocity, `radius/r0`, (-) """
function Δv_rai end
""" exponent in velocity, `radius/r0`, (-) """
function Δv_sno end

""" drag coefficient for rain drops (-) """
function C_drag end

""" condensation/evaporation timescale (s) """
function τ_cond_evap end

""" sublimation/deposition timescale (s) """
function τ_sub_dep end

""" rain autoconversion threshold `∈(0.5, 1) * 1e-3` (-) """
function q_liq_threshold end

""" rain autoconversion timescale `∈(1e3, 1e4)` (s) """
function τ_acnv_rai end

""" snow autoconversion threshold (-) """
function q_ice_threshold end

""" snow autoconversion timescale (s) """
function τ_acnv_sno end

""" threshold between ice and snow (m) """
function r_ice_snow end

""" collision efficiency (-) """
function E_liq_rai end
""" collision efficiency (-) """
function E_liq_sno end
""" collision efficiency (-) """
function E_ice_rai end
""" collision efficiency (-) """
function E_ice_sno end
""" collision efficiency (-) """
function E_rai_sno end

""" ventilation factor coefficient for rain or snow (-) """
function a_vent_rai end
""" ventilation factor coefficient for rain or snow (-) """
function a_vent_sno end

""" ventilation factor coefficient for rain or snow (-) """
function b_vent_rai end
""" ventilation factor coefficient for rain or snow (-) """
function b_vent_sno end

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
