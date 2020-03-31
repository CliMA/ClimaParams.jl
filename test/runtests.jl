using Test
using CLIMAParameters
using CLIMAParameters.Planet
using CLIMAParameters.Atmos.Turbulence
using CLIMAParameters.Atmos.Microphysics

struct EarthParameterSet <: AbstractEarthParameterSet end
earth = EarthParameterSet()

@testset "Earth - callable and not NaNs" begin

  # Test that all methods are callable, and that nothing returns NaNs
  for _module in [Planet, Turbulence, Microphysics]

    exported_methods = names(_module)
    filter!(x->x≠Symbol(nameof(_module)), exported_methods)
    for m in exported_methods
      @test !isnan(_module.eval(m)(earth))
    end
  end

end

@testset "Earth - correctness relations" begin

  # Planet
  @test cp_d(earth)           ≈ R_d(earth) / kappa_d(earth)
  @test cv_d(earth)           ≈ cp_d(earth) - R_d(earth)
  @test molmass_ratio(earth)  ≈ molmass_dryair(earth) / molmass_water(earth)
  @test cv_v(earth)           ≈ cp_v(earth) - R_v(earth)
  @test cv_l(earth)           ≈ cp_l(earth)
  @test cv_i(earth)           ≈ cp_i(earth)
  @test T_0(earth)            ≈ T_triple(earth)
  @test LH_f0(earth)          ≈ LH_s0(earth) - LH_v0(earth)
  @test e_int_v0(earth)       ≈ LH_v0(earth) - R_v(earth) * T_0(earth)
  @test e_int_i0(earth)       ≈ LH_f0(earth)
  @test R_d(earth)            ≈ gas_constant() / molmass_dryair(earth)
  @test R_v(earth)            ≈ gas_constant() / molmass_water(earth)
  @test year_anom(earth)      ≈ 365.26 * day(earth)
  @test orbit_semimaj(earth)  ≈ 1 * astro_unit()
  # Microphysics
  @test N_Sc(earth)           ≈ ν_air(earth)/D_vapor(earth)

end

