module Soil

module Water

module VanGenuchten

export n,
       α,
       m

""" n - exponent; that then determines the exponent m used in the model () """
function n end

""" inverse of this carries units in the expression for matric potential (inverse meters) """
function α end

""" Exponent parameter () """
function m end

end # module VanGenuchten


module BrooksCorey

export ψb, m

""" ψb - units. Slightly fudged m to better match Haverkamp and VG at α=2.0 and n = 2.1. (meters) """
function ψb end

""" m - exponent """
function m end

end # module BrooksCorey

module Haverkamp

export k, A, B

"""exponent for Yolo light clay"""
function k end

"""constant A cm^k. Our sim is in meters - convert"""
function A end

"""constant B cm^k. Our sim is in meters - convert."""
function B end

end # module Haverkamp

end # module Water

end # module Soil
