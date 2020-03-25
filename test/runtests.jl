using Test
using CLIMAParameters
using CLIMAParameters.Planet

@testset "Earth" begin
  ps = EarthParameterSet()

  @test molmass_dryair(ps) ≈ 28.97e-3
  @test R_d(ps)            ≈ gas_constant() / molmass_dryair(ps)
  @test kappa_d(ps)        ≈ 2 / 7
  @test cp_d(ps)           ≈ R_d(ps) / kappa_d(ps)
  @test cv_d(ps)           ≈ cp_d(ps) - R_d(ps)

  # Properties of water
  @test ρ_cloud_liq(ps)    ≈ 1e3
  @test ρ_cloud_ice(ps)    ≈ 916.7
  @test molmass_water(ps)  ≈ 18.01528e-3
  @test molmass_ratio(ps)  ≈ molmass_dryair(ps) / molmass_water(ps)
  @test R_v(ps)            ≈ gas_constant() / molmass_water(ps)
  @test cp_v(ps)           ≈ 1859
  @test cp_l(ps)           ≈ 4181
  @test cp_i(ps)           ≈ 2100
  @test cv_v(ps)           ≈ cp_v(ps) - R_v(ps)
  @test cv_l(ps)           ≈ cp_l(ps)
  @test cv_i(ps)           ≈ cp_i(ps)
  @test T_freeze(ps)       ≈ 273.15
  @test T_min(ps)          ≈ 150.0
  @test T_max(ps)          ≈ 1000.0
  @test T_icenuc(ps)       ≈ 233.00
  @test T_triple(ps)       ≈ 273.16
  @test T_0(ps)            ≈ T_triple(ps)
  @test LH_v0(ps)          ≈ 2.5008e6
  @test LH_s0(ps)          ≈ 2.8344e6
  @test LH_f0(ps)          ≈ LH_s0(ps) - LH_v0(ps)
  @test e_int_v0(ps)       ≈ LH_v0(ps) - R_v(ps) * T_0(ps)
  @test e_int_i0(ps)       ≈ LH_f0(ps)
  @test press_triple(ps)   ≈ 611.657

  # Properties of sea water
  @test ρ_ocean(ps)        ≈ 1.035e3
  @test cp_ocean(ps)       ≈ 3989.25

  # Planetary parameters
  @test planet_radius(ps)  ≈ 6.371e6
  @test day(ps)            ≈ 86400
  @test Omega(ps)          ≈ 7.2921159e-5
  @test grav(ps)           ≈ 9.81
  @test year_anom(ps)      ≈ 365.26 * day(ps)
  @test orbit_semimaj(ps)  ≈ 1 * astro_unit()
  @test TSI(ps)            ≈ 1362
  @test MSLP(ps)           ≈ 1.01325e5
end

