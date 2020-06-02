"""
    struct EmpiricalWaterProperties{FT}

An empirical parameter set that stores constants for computing surface tension and viscosity of water.

# Fields
$(DocStringExtensions.FIELDS)
"""
@Base.kwdef struct EmpiricalWaterProperties{FT} <: AbstractEmpiricalParameterSet
    "Surface tension multiplier `[N/m]`"
    ST_k     ::FT = FT(0.2358)
    "Surface tension critical temperature `[K]`"
    ST_T_crit::FT = FT(647.096)
    "Surface tension exponent correction factor"
    ST_exp   ::FT = FT(1.256)
    "Surface tension multiplier correction factor"
    ST_corr  ::FT = FT(0.625)
    "Surface tension at reference temperature 298.15 K `[N/m]`"
    ST_ref   ::FT = FT(0.07197220523)
    "Viscosity at ``T_0`` `[Pa s]`"
    VIS_0    ::FT = FT(1.856e-14)
    "Viscosity exponent correction parameters `[K]`"
    VIS_e1   ::FT = FT(4209.0)
    "Viscosity exponent correction parameters [K⁻¹]"
    VIS_e2   ::FT = FT(0.04527)
    "Viscosity exponent correction parameters [K⁻²]"
    VIS_e3   ::FT = FT(-3.376e-5)
end
