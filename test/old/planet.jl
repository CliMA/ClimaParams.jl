using Test
using CLIMAParameters
using CLIMAParameters: AbstractEarthParameterSet
using CLIMAParameters.Planet

@testset "Planet (Earth)" begin
  struct EarthParameterSet <: AbstractEarthParameterSet end

  ps = EarthParameterSet()

  # Planet
  @test cp_d(ps)           ≈ R_d(ps) / kappa_d(ps)
  @test cv_d(ps)           ≈ cp_d(ps) - R_d(ps)
  @test molmass_ratio(ps)  ≈ molmass_dryair(ps) / molmass_water(ps)
  @test cv_v(ps)           ≈ cp_v(ps) - R_v(ps)
  @test cv_l(ps)           ≈ cp_l(ps)
  @test cv_i(ps)           ≈ cp_i(ps)
  @test T_0(ps)            ≈ T_triple(ps)
  @test LH_f0(ps)          ≈ LH_s0(ps) - LH_v0(ps)
  @test e_int_v0(ps)       ≈ LH_v0(ps) - R_v(ps) * T_0(ps)
  @test e_int_i0(ps)       ≈ LH_f0(ps)
  @test R_d(ps)            ≈ gas_constant() / molmass_dryair(ps)
  @test R_v(ps)            ≈ gas_constant() / molmass_water(ps)
  @test year_anom(ps)      ≈ 365.26 * day(ps)
  @test orbit_semimaj(ps)  ≈ 1 * astro_unit()

  @test !isnan(T_freeze(ps))
  @test !isnan(T_min(ps))
  @test !isnan(T_max(ps))
  @test !isnan(T_icenuc(ps))
  @test !isnan(pow_icenuc(ps))
  @test !isnan(press_triple(ps))
  @test !isnan(surface_tension_coeff(ps))

end
