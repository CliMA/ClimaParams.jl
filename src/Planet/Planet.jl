"""
    Planet

Planetary parameters.
"""
module Planet

export molmass_dryair,
    R_d,
    kappa_d,
    cp_d,
    cv_d,
    ρ_cloud_liq,
    ρ_cloud_ice,
    molmass_water,
    molmass_ratio,
    R_v,
    cp_v,
    cp_l,
    cp_i,
    cv_v,
    cv_l,
    cv_i,
    T_freeze,
    T_min,
    T_max,
    T_icenuc,
    T_triple,
    T_0,
    LH_v0,
    LH_s0,
    LH_f0,
    e_int_v0,
    e_int_i0,
    press_triple,
    surface_tension_coeff,
    ρ_ocean,
    cp_ocean,
    planet_radius,
    day,
    Omega,
    grav,
    year_anom,
    orbit_semimaj,
    tot_solar_irrad,
    epoch,
    mean_anom_epoch,
    obliq_epoch,
    lon_perihelion_epoch,
    eccentricity_epoch,
    lon_perihelion,
    MSLP,
    T_surf_ref,
    T_min_ref

# Properties of dry air
""" Molecular weight dry air (kg/mol) """
function molmass_dryair end
""" Gas constant dry air (J/kg/K) """
function R_d end
""" Adiabatic exponent dry air """
function kappa_d end
""" Isobaric specific heat dry air """
function cp_d end
""" Isochoric specific heat dry air """
function cv_d end

# Properties of water
""" Density of liquid water (kg/m``^3``) """
function ρ_cloud_liq end
""" Density of ice water (kg/m``^3``) """
function ρ_cloud_ice end
""" Molecular weight (kg/mol) """
function molmass_water end
""" Molar mass ratio dry air/water """
function molmass_ratio end
""" Gas constant water vapor (J/kg/K) """
function R_v end
""" Isobaric specific heat vapor (J/kg/K) """
function cp_v end
""" Isobaric specific heat liquid (J/kg/K) """
function cp_l end
""" Isobaric specific heat ice (J/kg/K) """
function cp_i end
""" Isochoric specific heat vapor (J/kg/K) """
function cv_v end
""" Isochoric specific heat liquid (J/kg/K) """
function cv_l end
""" Isochoric specific heat ice (J/kg/K) """
function cv_i end
""" Freezing point temperature (K) """
function T_freeze end
""" Minimum temperature guess in saturation adjustment (K) """
function T_min end
""" Maximum temperature guess in saturation adjustment (K) """
function T_max end
""" Homogeneous nucleation temperature (K) """
function T_icenuc end
""" Triple point temperature (K) """
function T_triple end
""" Reference temperature (K) """
function T_0 end
""" Latent heat vaporization at ``T_0`` (J/kg) """
function LH_v0 end
""" Latent heat sublimation at ``T_0`` (J/kg) """
function LH_s0 end
""" Latent heat of fusion at ``T_0`` (J/kg) """
function LH_f0 end
""" Specific internal energy of vapor at ``T_0`` (J/kg) """
function e_int_v0 end
""" Specific internal energy of ice at ``T_0`` (J/kg) """
function e_int_i0 end
""" Triple point vapor pressure (Pa) """
function press_triple end
""" Surface tension coefficient of water (J/m2) """
function surface_tension_coeff end

# Properties of sea water
""" Reference density sea water (kg/m``^3``) """
function ρ_ocean end
""" Specific heat sea water (J/kg/K) """
function cp_ocean end

# Planetary parameters
""" Mean planetary radius (m) """
function planet_radius end
""" Length of day (s) """
function day end
""" Ang. velocity planetary rotation (1/s) """
function Omega end
""" Gravitational acceleration (m/s``^2``) """
function grav end
""" Length of anomalistic year (s) """
function year_anom end
""" ngth of semimajor orbital axis (m) """
function orbit_semimaj end
""" Total solar irradiance (W/m``^2``) """
function tot_solar_irrad end
""" Time of  epoch (J2000) (s) """
function epoch end
""" Mean anomaly at the epoch (radians) """
function mean_anom_epoch end
""" Orbital obliquity at the epoch (radians) """
function obliq_epoch end
""" Longitude of perihelion at the epoch (radians),
measured relative to vernal equinox (i.e., the longitude of perihelion is the angle
subtended at the Sun by the orbital arc from vernal equinox to perihelion). """
function lon_perihelion_epoch end
""" Orbital eccentricity at the epoch """
function eccentricity_epoch end
""" Longitude of perihelion (radians), measured relative to vernal equinox.
The calculation of the mean anomaly is formulated such that the vernal equinox
is fixed in the calendar. However, this requires tracking both the current longitude of perihelion
as well as the reference longitude of perihelion at the reference time (epoch). """
function lon_perihelion end
""" Mean sea level pressure (Pa) """
function MSLP end
""" Mean surface temperature (K) in reference state """
function T_surf_ref end
""" Minimum temperature (K) in reference state """
function T_min_ref end

end
