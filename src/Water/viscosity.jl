const VIS_A =  1.856e-14    # Pa s | Used for viscosity
const VIS_B =  4209.0       # K    | Used for viscosity
const VIS_C =  0.04527      # K⁻¹  | Used for viscosity
const VIS_D = -3.376e-5     # K⁻²  | Used for viscosity




"""
    ν_water_liq(tem::FT)

Viscosity of water `[Pa s]`, given
- `tem` Water temperature in `[K]`

Equations used are
```math
υ = A \\cdot \\exp \\left( \\frac{B}{T} + C \\cdot T + D \\cdot T^2 \\right)
```
fitting parameters are from Reid, Prausnitz, & Poling (1987), valid through 273-643 K
```
A = 1.856E-14 # Pa s
B = 4209      # K
C = 0.04527   # K⁻¹
D = -3.376E-5 # K⁻²
```
"""
function ν_water_liq(tem::FT) where {FT}
    return FT(VIS_A) * exp(FT(VIS_B)/tem + FT(VIS_C)*tem + FT(VIS_D)*tem^2)
end




"""
    ν_water_liq_relative(tem::FT)

Viscosity relative to 25 degree C (298.15 K), given
- `tem` Water temperature in `[K]`

Equations used are
```math
\\frac{υ}{υ_{25}} = \\exp \\left( \\frac{B}{T} + C \\cdot T + D \\cdot T^2 - \\frac{B}{T_{25}} - C \\cdot T_{25} - D \\cdot T_{25}^2 \\right)
```
fitting parameters are from Reid, Prausnitz, & Poling (1987), valid through 273-643 K
```
B = 4209      # K
C = 0.04527   # K⁻¹
D = -3.376E-5 # K⁻²
```
"""
function ν_water_liq_relative(tem::FT) where {FT}
    return exp( FT(VIS_B) * ( 1/tem - 1/FT(298.15)) + FT(VIS_C) * (tem - FT(298.15)) + FT(VIS_D) * (tem^2 - FT(298.15)^2) )
end
