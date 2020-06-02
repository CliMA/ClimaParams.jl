"""
    p_sat_water_ice(tem::FT)

Saturated vapor pressure above plance surface of ice in `[Pa]`, given
- `tem` Water temperature `[K]`

Saturated vapor pressure is computed using ``A \\cdot \\exp \\left( \\frac{BT}{T+C} \\right) = 611.21 \\cdot \\exp \\left( \\frac{ 22.587 \\cdot temc }{ temc + 273.86 } \\right)``. Note that ``T`` here is in Celcius.

See Alduchov and Eskridge (1996) "Improved Magnus form approximation of saturation vapor pressure."

"""
function p_sat_water_ice(tem::FT) where {FT}
    temc = tem - FT(273.15)
    return FT(611.21) * exp( FT(22.587) * temc / (temc + FT(273.86)) )
end




"""
    p_sat_water_ice_slope(tem::FT)

Saturated vapor pressure above plance surface of ice in `[Pa]` and 1st order derivative, given
- `tem` Water temperature `[K]`

Saturated vapor pressure is computed using ``A \\cdot \\exp \\left( \\frac{BT}{T+C} \\right) = 611.21 \\cdot \\exp \\left( \\frac{ 22.587 \\cdot temc }{ temc + 273.86 } \\right)``. The 1st order partial derivative is computed using ``A \\cdot \\exp \\left( \\frac{BT}{T+C} \\right) \\cdot \\frac{BC}{(T+C)^2}``. Note that ``T`` here is in Celcius.

See Alduchov and Eskridge (1996) "Improved Magnus form approximation of saturation vapor pressure."

"""
function p_sat_water_ice_slope(tem::FT) where {FT}
    temc = tem - FT(273.15)
    psat = FT(611.21) * exp( FT(22.587) * temc / (temc + FT(273.86)) )
    slop = psat * FT(22.587) * FT(273.86) / (temc + FT(273.86))^2
    return psat,slop
end




"""
    p_sat_water_liq(tem::FT)

Saturated vapor pressure above plane surface of water in `[Pa]`, given
- `tem` Water temperature `[K]`

Saturated vapor pressure is computed using ``A \\cdot \\exp \\left( \\frac{BT}{T+C} \\right) = 610.94 \\cdot \\exp \\left( \\frac{ 17.625 \\cdot temc }{ temc + 243.04 } \\right)``. Note that ``T`` here is in Celcius.

See Alduchov and Eskridge (1996) "Improved Magnus form approximation of saturation vapor pressure."

"""
function p_sat_water_liq(tem::FT) where {FT}
    temc = tem - FT(273.15)
    return FT(610.94) * exp( FT(17.625) * temc / (temc + FT(243.04)) )
end




"""
    p_sat_water_liq_slope(tem::FT)

Saturated vapor pressure above plane surface of water in `[Pa]` and 1st order derivative, given
- `tem` Water temperature `[K]`

Saturated vapor pressure is computed using ``A \\cdot \\exp \\left( \\frac{BT}{T+C} \\right) = 610.94 \\cdot \\exp \\left( \\frac{ 17.625 \\cdot temc }{ temc + 243.04 } \\right)``. The 1st order partial derivative is computed using ``A \\cdot \\exp \\left( \\frac{BT}{T+C} \\right) \\cdot \\frac{BC}{(T+C)^2}``. Note that ``T`` here is in Celcius.

See Alduchov and Eskridge (1996) "Improved Magnus form approximation of saturation vapor pressure."

"""
function p_sat_water_liq_slope(tem::FT) where {FT}
    temc = tem - FT(273.15)
    psat = FT(610.94) * exp( FT(17.625) * temc / (temc + FT(243.04)) )
    slop = psat * FT(17.625) * FT(243.04) / (temc + FT(243.04))^2
    return psat,slop
end




"""
    p_sat_water(tem::FT)

Saturated vapor pressure in `[Pa]`, given
- `tem` Water temperature `[K]`.

If tem > 273.15 K, use that of water; otherwise, use that of ice.

"""
function p_sat_water(tem::FT) where {FT}
    if tem>=273.15
        return p_sat_water_liq(tem)
    else
        return p_sat_water_ice(tem)
    end
end




"""
    p_sat_water(tem::FT, p_w::FT)

Saturated vapor pressure in `[Pa]`, given
- `tem` Water temperature `[K]`
- `p_c` Water pressure `[MPa]` (possitive: convex air-water interface; negative: concave interface)

Saturated vapor pressure is computed using ``p_{sat}^{*} \\cdot \\exp \\left( \\frac{V_m P_{water}}{RT} \\right)``, according to the Kelvin equation, and ``p_{sat}^{*}`` is that above plane water/ice.

"""
function p_sat_water(tem::FT, p_w::FT) where {FT}
    #factor = exp( FT(1e6) * p_w * FT(1.8e-5) / (FT(8.31446261815324) * tem) )
    factor = exp( p_w * FT(18.0) / (FT(8.31446261815324) * tem) )
    return factor * p_sat_water(tem)
end




"""
    p_sat_water_slope(tem::FT)

Saturated vapor pressure in `[Pa]` and 1st order partial derivative, given
- `tem` Water temperature `[K]`.

If tem > 273.15 K, use that of water; otherwise, use that of ice.

"""
function p_sat_water_slope(tem::FT) where {FT}
    if tem>=273.15
        return p_sat_water_liq_slope(tem)
    else
        return p_sat_water_ice_slope(tem)
    end
end




"""
    p_sat_water_slope(tem::FT, p_w::FT)

Saturated vapor pressure in `[Pa]`, given
- `tem` Water temperature `[K]`
- `p_c` Water pressure `[MPa]` (possitive: convex air-water interface; negative: concave interface)

Saturated vapor pressure is computed using ``p_{sat}^{*} \\cdot \\exp \\left( \\frac{V_m P_{water}}{RT} \\right)``, according to the Kelvin equation, and ``p_{sat}^{*}`` is that above plane water/ice.

Note that the function does not apply to the case of ice!

"""
function p_sat_water_slope(tem::FT, p_w::FT) where {FT}
    #factor = exp( FT(1e6) * p_w * FT(1.8e-5) / (FT(8.31446261815324) * tem) )
    factor     = exp( p_w * FT(18.0) / (FT(8.31446261815324) * tem) )
    return p_sat_water_slope(tem) .* factor
end
