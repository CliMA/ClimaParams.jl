const SLH_A0 = 2.5008e6    # J kg⁻¹     | Used for specific latent heat
const SLH_A1 = -2.36e3     # J kg⁻¹ K⁻¹ | Used for specific latent heat
const SLH_A2 = 1.6         # J kg⁻¹ K⁻² | Used for specific latent heat
const SLH_A3 = -0.06       # J kg⁻¹ K⁻³ | Used for specific latent heat
const SLH_I0 = 2.8341e6    # J kg⁻¹     | Used for specific latent heat
const SLH_I1 = -290.0      # J kg⁻¹ K⁻¹ | Used for specific latent heat
const SLH_I2 = -4.0        # J kg⁻¹ K⁻² | Used for specific latent heat




"""
    LH_v_ice(tem::FT)

Specific latent heat, given
- `tem` Water temperature in `[K]`

Equation used is ``λ = (2834.1 - 0.29 \\cdot T - 0.004 \\cdot T^2)`` in `KJ kg⁻¹` when tem in -40 to 0 degree C
See Polynomial curve fits to Table 2.1. R. R. Rogers; M. K. Yau (1989).
A Short Course in Cloud Physics (3rd ed.). Pergamon Press. p. 16. ISBN 0-7506-3215-1.

"""
function LH_v_ice(tem::FT) where {FT}
    temc = tem - FT(273.15)
    return FT(SLH_I0) + FT(SLH_I1)*temc + FT(SLH_I2)*temc^2
end




"""
    LH_v_liq(tem::FT)

Specific latent heat, given
- `tem` Water temperature in `[K]`

Equation used is ``λ = (2500.8 - 2.36 \\cdot T + 0.0016 \\cdot T^2 - 0.00006 \\cdot T^3)`` in `KJ kg⁻¹` when tem in -25 to 40 degree C
See Polynomial curve fits to Table 2.1. R. R. Rogers; M. K. Yau (1989).
A Short Course in Cloud Physics (3rd ed.). Pergamon Press. p. 16. ISBN 0-7506-3215-1.

"""
function LH_v_liq(tem::FT) where {FT}
    temc = tem - FT(273.15)
    return FT(SLH_A0) + FT(SLH_A1)*temc + FT(SLH_A2)*temc^2 + FT(SLH_A3)*temc^3
end
