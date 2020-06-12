module Soil

module Water

export Ω,
       T1,
       T2

""" Impedance parameter to model reduced hydraulic conductivities in frozen soils (unitless) """
function Ω end

""" Parameter in expression for the temperature dependence of the hydraulic conductivity (K) """
function T1 end

""" Parameter in expression for the temperature dependence of the hydraulic conductivity (K) """
function T2 end

end # module Water

end # module Soil
