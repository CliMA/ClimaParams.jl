
const LandVanGenuchten = CLIMAParameters.Land.Soil.Water.VanGenuchten

LandVanGenuchten.n(::AbstractLandParameterSet) = 1.43
LandVanGenuchten.α(::AbstractLandParameterSet) = 2.6
LandVanGenuchten.m(ps::AbstractLandParameterSet) = 1-1/LandVanGenuchten.n(ps)

const LandBrooksCorey = CLIMAParameters.Land.Soil.Water.BrooksCorey

LandBrooksCorey.ψb(::AbstractLandParameterSet) = 0.1656
LandBrooksCorey.m(::AbstractLandParameterSet) = 0.5

const LandHaverkamp = CLIMAParameters.Land.Soil.Water.Haverkamp

LandHaverkamp.k(::AbstractLandParameterSet) = 1.77
LandHaverkamp.A(ps::AbstractLandParameterSet) = 124.6/100.0^LandHaverkamp.k(ps)
LandHaverkamp.B(ps::AbstractLandParameterSet) = 124.6/100.0^LandHaverkamp.k(ps)
