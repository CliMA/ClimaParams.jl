"""
    γ_water_air(tem::FT)

Surface tension `[N m⁻¹]` of water against air, given
- `tem` Water temperature

The equations used are
```math
γ = 0.2358 \\cdot \\left( 1 - \\frac{T}{647.096} \\right)^{1.256} \\cdot \\left[ 1 - 0.625 \\cdot \\left( 1 - \\frac{T}{647.096} \\right)  \\right]
```
See http://www.iapws.org/relguide/Surf-H2O.html

"""
function γ_water_air(tem::FT) where {FT}
    st_t = 1 - tem/FT(647.096)
    return FT(0.2358) * st_t^FT(1.256) * (1 - FT(0.625)*st_t)
end




"""
    γ_water_air_relative(tem::FT)

Surface tension of water against air relative to 25 degree C (298.15 K), given
- `tem` Water temperature

The equations (re-arranged) used is
```math
γ = \\left( \\frac{647.096 - T}{647.096 - 298.15} \\right)^{1.256} \\cdot \\left( \\frac{0.6 \\cdot 647.096 + T}{0.6 \\cdot 647.096 + 298.15}  \\right)
```
See http://www.iapws.org/relguide/Surf-H2O.html

"""
function γ_water_air_relative(tem::FT) where {FT}
    return ((FT(647.096) - tem) / FT(348.946))^FT(1.256) * (FT(388.2576)+tem) / FT(686.4076)
end
