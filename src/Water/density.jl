# these constant for used to computed density of air-free water
const WD_A0 = 999.83952
const WD_A1 = 16.945176
const WD_A2 = -7.9870401e-3
const WD_A3 = -4.6170461e-5
const WD_A4 =  1.0556302e-7
const WD_A5 = -2.8054253e-10
const WD_AC =  0.016897850
const WD_B0 = 999.85308
const WD_B1 =  6.32693e-2
const WD_B2 = -8.523829e-3
const WD_B3 =  6.943248e-5
const WD_B4 = -3.821216e-7




"""
    ρ_water_liq(tem::FT)

Density of air-free pure water `[kg m⁻³]`, given
- `tem` Water temperature `[K]`

The equation for computing water density (0 to 150 Celcius) is
```math
ρ = \\frac{ 999.83952 + 16.945176 \\cdot t - 7.9870401e-3 \\cdot t^2 - 4.6170461e-5 \\cdot t^3 + 1.0556302e-7 \\cdot t^4 - 2.8054253e-10 \\cdot t^5 }{ 1 + 1.6897850e-2 \\cdot t }
```
See Kell, George S (1975) Density, thermal expansivity, and compressibility of liquid water from 0 deg. to 150. deg.. Correlations and tables for atmospheric pressure and saturation reviewed and expressed on 1968 temperature scale.

The equation for computing water density (5 to 40 Celcius) is
```math
ρ = 999.85308 + 6.32693e-2 \\cdot t - 8.523829e-3 \\cdot t^2 + 6.943248e-5 \\cdot t^3 - 3.821216e-7 \\cdot t^4
```
See https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4909168/#b2-jresv97n3p335_a1b

"""
function ρ_water_liq(tem::FT) where {FT}
    temc  = tem - FT(273.15)
    if temc >= 5 && temc <= 40
        ρ_H₂O = FT(WD_B0) + FT(WD_B1)*temc + FT(WD_B2)*temc^2 + FT(WD_B3)*temc^3 + FT(WD_B4)*temc^4
    else
        ρ_H₂O = (FT(WD_A0) + FT(WD_A1)*temc + FT(WD_A2)*temc^2 + FT(WD_A3)*temc^3 + FT(WD_A4)*temc^4 + FT(WD_A5)*temc^5) / (1 + FT(WD_AC)*temc)
    end
    return ρ_H₂O
end
