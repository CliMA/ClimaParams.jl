module Water

export ST_k,
    ST_T_crit,
    ST_exp,
    ST_corr,
    ST_ref,
    VIS_0,
    VIS_e1,
    VIS_e2,
    VIS_e3

"Surface tension multiplier `[N/m]`"
function ST_k end
"Surface tension critical temperature `[K]`"
function ST_T_crit end
"Surface tension exponent correction factor"
function ST_exp end
"Surface tension multiplier correction factor"
function ST_corr end
"Surface tension at reference temperature 298.15 K `[N/m]`"
function ST_ref end
"Viscosity at ``T_0`` `[Pa s]`"
function VIS_0 end
"Viscosity exponent correction parameters `[K]`"
function VIS_e1 end
"Viscosity exponent correction parameters [K⁻¹]"
function VIS_e2 end
"Viscosity exponent correction parameters [K⁻²]"
function VIS_e3 end

end