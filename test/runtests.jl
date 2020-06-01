using Test
using CLIMAParameters
using CLIMAParameters.Planet
using CLIMAParameters.Atmos.SubgridScale
using CLIMAParameters.SubgridScale

using CLIMAParameters.Atmos.Microphysics
struct LiquidParameterSet <: AbstractLiquidParameterSet end
struct IceParameterSet    <: AbstractIceParameterSet end
struct RainParameterSet   <: AbstractRainParameterSet end
struct SnowParameterSet   <: AbstractSnowParameterSet end
struct MicropysicsParameterSet{L,I,R,S} <: AbstractMicrophysicsParameterSet
  liquid ::L
  ice ::I
  rain ::R
  snow ::S
end
struct EarthParameterSet{M} <: AbstractEarthParameterSet
  microphysics::M
end
microphys_param_set = MicropysicsParameterSet(
    LiquidParameterSet(),
    IceParameterSet(),
    RainParameterSet(),
    SnowParameterSet()
)
earth = EarthParameterSet(microphys_param_set)

@testset "Earth - callable and not NaNs" begin

  # Test that all methods are callable, and that nothing returns NaNs
  for _module in [
                   CLIMAParameters.Planet,
                   CLIMAParameters.SubgridScale,
                   CLIMAParameters.Atmos.SubgridScale,
                 ]

    exported_methods = names(_module)
    filter!(x->x≠Symbol(nameof(_module)), exported_methods)
    for m in exported_methods
      @test !isnan(_module.eval(m)(earth))
    end
  end

end

@testset "Microphysics - callable and not NaNs" begin

  # Test that all methods are callable, and that nothing returns NaNs
  @test !isnan(Microphysics.C_drag(earth))
  @test !isnan(K_therm(earth))
  @test !isnan(D_vapor(earth))
  @test !isnan(ν_air(earth))
  @test !isnan(N_Sc(earth))

  @test !isnan(τ_cond_evap(earth.microphysics.liquid))

  @test !isnan(τ_sub_dep(earth.microphysics.ice))
  @test !isnan(r_ice_snow(earth.microphysics.ice))
  @test !isnan(n0(earth.microphysics.ice))
  @test !isnan(r0(earth.microphysics.ice))
  @test !isnan(me(earth.microphysics.ice))
  @test !isnan(m0(earth, earth.microphysics.ice))

  @test !isnan(q_liq_threshold(earth.microphysics.rain))
  @test !isnan(τ_acnv(earth.microphysics.rain))
  @test !isnan(a_vent(earth.microphysics.rain))
  @test !isnan(b_vent(earth.microphysics.rain))
  @test !isnan(n0(earth.microphysics.rain))
  @test !isnan(r0(earth.microphysics.ice))
  @test !isnan(me(earth.microphysics.rain))
  @test !isnan(ae(earth.microphysics.rain))
  @test !isnan(ve(earth.microphysics.rain))
  @test !isnan(m0(earth, earth.microphysics.rain))
  @test !isnan(a0(earth.microphysics.rain))

  @test !isnan(a_vent(earth.microphysics.snow))
  @test !isnan(b_vent(earth.microphysics.snow))
  @test !isnan(μ_sno(earth.microphysics.snow))
  @test !isnan(ν_sno(earth.microphysics.snow))
  @test !isnan(r0(earth.microphysics.snow))
  @test !isnan(me(earth.microphysics.snow))
  @test !isnan(ae(earth.microphysics.snow))
  @test !isnan(ve(earth.microphysics.snow))
  @test !isnan(m0(earth.microphysics.snow))
  @test !isnan(a0(earth.microphysics.snow))
  @test !isnan(v0(earth.microphysics.snow))

  @test !isnan(E(earth.microphysics.liquid, earth.microphysics.rain))
  @test !isnan(E(earth.microphysics.liquid, earth.microphysics.snow))
  @test !isnan(E(earth.microphysics.ice,   earth.microphysics.rain))
  @test !isnan(E(earth.microphysics.ice,   earth.microphysics.snow))
  @test !isnan(E(earth.microphysics.rain,  earth.microphysics.snow))
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

  # Atmos.Microphysics
  @test N_Sc(earth)           ≈ ν_air(earth)/D_vapor(earth)
  @test m0(earth, earth.microphysics.rain) ≈ 4/3. * π * ρ_cloud_liq(earth) * r0(earth.microphysics.rain)^me(earth.microphysics.rain)
  @test m0(earth, earth.microphysics.ice)  ≈ 4/3. * π * ρ_cloud_ice(earth) * r0(earth.microphysics.ice)^me(earth.microphysics.ice)
  @test E(earth.microphysics.rain, earth.microphysics.snow) ≈
        E(earth.microphysics.snow, earth.microphysics.rain)

  @test χm(earth.microphysics.ice) ≈ 1
  @test Δm(earth.microphysics.ice) ≈ 0

  @test χm(earth.microphysics.rain) ≈ 1
  @test Δm(earth.microphysics.rain) ≈ 0
  @test χa(earth.microphysics.rain) ≈ 1
  @test Δa(earth.microphysics.rain) ≈ 0
  @test χv(earth.microphysics.rain) ≈ 1
  @test Δv(earth.microphysics.rain) ≈ 0

  @test χm(earth.microphysics.snow) ≈ 1
  @test Δm(earth.microphysics.snow) ≈ 0
  @test χa(earth.microphysics.snow) ≈ 1
  @test Δa(earth.microphysics.snow) ≈ 0
  @test χv(earth.microphysics.snow) ≈ 1
  @test Δv(earth.microphysics.snow) ≈ 0

  # Atmos.SubgridScale
  @test c_1_KASM(earth)       ≈ c_a_KASM(earth)*0.76^2
  @test c_2_KASM(earth)       ≈ c_e2_KASM(earth)+2*c_1_KASM(earth)
  @test c_3_KASM(earth)       ≈ c_a_KASM(earth)^(3/2)

end

import CLIMAParameters
CLIMAParameters.Planet.grav(::EarthParameterSet) = 2.0
@testset "Overriding defaults" begin

  @test grav(earth) ≈ 2.0

end

