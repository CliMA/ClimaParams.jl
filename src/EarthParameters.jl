
# Properties of dry air
CLIMAParameters.Planet.molmass_dryair(ps::EarthParameterSet) = 28.97e-3
CLIMAParameters.Planet.R_d(ps::EarthParameterSet)            = gas_constant() / molmass_dryair(ps)
CLIMAParameters.Planet.kappa_d(ps::EarthParameterSet)        = 2 / 7
CLIMAParameters.Planet.cp_d(ps::EarthParameterSet)           = R_d(ps) / kappa_d(ps)
CLIMAParameters.Planet.cv_d(ps::EarthParameterSet)           = cp_d(ps) - R_d(ps)

# Properties of water
CLIMAParameters.Planet.ρ_cloud_liq(ps::EarthParameterSet)    = 1e3
CLIMAParameters.Planet.ρ_cloud_ice(ps::EarthParameterSet)    = 916.7
CLIMAParameters.Planet.molmass_water(ps::EarthParameterSet)  = 18.01528e-3
CLIMAParameters.Planet.molmass_ratio(ps::EarthParameterSet)  = molmass_dryair(ps) / molmass_water(ps)
CLIMAParameters.Planet.R_v(ps::EarthParameterSet)            = gas_constant() / molmass_water(ps)
CLIMAParameters.Planet.cp_v(ps::EarthParameterSet)           = 1859
CLIMAParameters.Planet.cp_l(ps::EarthParameterSet)           = 4181
CLIMAParameters.Planet.cp_i(ps::EarthParameterSet)           = 2100
CLIMAParameters.Planet.cv_v(ps::EarthParameterSet)           = cp_v(ps) - R_v(ps)
CLIMAParameters.Planet.cv_l(ps::EarthParameterSet)           = cp_l(ps)
CLIMAParameters.Planet.cv_i(ps::EarthParameterSet)           = cp_i(ps)
CLIMAParameters.Planet.T_freeze(ps::EarthParameterSet)       = 273.15
CLIMAParameters.Planet.T_min(ps::EarthParameterSet)          = 150.0
CLIMAParameters.Planet.T_max(ps::EarthParameterSet)          = 1000.0
CLIMAParameters.Planet.T_icenuc(ps::EarthParameterSet)       = 233.00
CLIMAParameters.Planet.T_triple(ps::EarthParameterSet)       = 273.16
CLIMAParameters.Planet.T_0(ps::EarthParameterSet)            = T_triple(ps)
CLIMAParameters.Planet.LH_v0(ps::EarthParameterSet)          = 2.5008e6
CLIMAParameters.Planet.LH_s0(ps::EarthParameterSet)          = 2.8344e6
CLIMAParameters.Planet.LH_f0(ps::EarthParameterSet)          = LH_s0(ps) - LH_v0(ps)
CLIMAParameters.Planet.e_int_v0(ps::EarthParameterSet)       = LH_v0(ps) - R_v(ps) * T_0(ps)
CLIMAParameters.Planet.e_int_i0(ps::EarthParameterSet)       = LH_f0(ps)
CLIMAParameters.Planet.press_triple(ps::EarthParameterSet)   = 611.657

# Properties of sea water
CLIMAParameters.Planet.ρ_ocean(ps::EarthParameterSet)        = 1.035e3
CLIMAParameters.Planet.cp_ocean(ps::EarthParameterSet)       = 3989.25

# Planetary parameters
CLIMAParameters.Planet.planet_radius(ps::EarthParameterSet)  = 6.371e6
CLIMAParameters.Planet.day(ps::EarthParameterSet)            = 86400
CLIMAParameters.Planet.Omega(ps::EarthParameterSet)          = 7.2921159e-5
CLIMAParameters.Planet.grav(ps::EarthParameterSet)           = 9.81
CLIMAParameters.Planet.year_anom(ps::EarthParameterSet)      = 365.26 * day(ps)
CLIMAParameters.Planet.orbit_semimaj(ps::EarthParameterSet)  = 1 * astro_unit()
CLIMAParameters.Planet.TSI(ps::EarthParameterSet)            = 1362
CLIMAParameters.Planet.MSLP(ps::EarthParameterSet)           = 1.01325e5
