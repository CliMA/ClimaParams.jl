using Test
using CLIMAParameters
using CLIMAParameters.Planet

using CLIMAParameters.Atmos.Microphysics_ne
using CLIMAParameters.Atmos.Microphysics_0M
using CLIMAParameters.Atmos.Microphysics_1M

@testset "Microphysics_ne" begin

  struct EarthParamSet <: AbstractEarthParameterSet end
  earth = EarthParamSet()

  @test !isnan(τ_cond_evap(earth))
  @test !isnan(τ_sub_dep(earth))

end

@testset "Microphysics_0M" begin

  struct EarthParameterSet <: AbstractEarthParameterSet end
  ps = EarthParameterSet()

  @test !isnan(τ_precip(ps))
  @test !isnan(qc_0(ps))
  @test !isnan(S_0(ps))

end

@testset "Microphysics_1M" begin

  struct EarthParamSet <: AbstractEarthParameterSet end
  earth = EarthParamSet()

  # Test that all methods are callable, and that nothing returns NaNs
  @test !isnan(C_drag(earth))
  @test !isnan(K_therm(earth))
  @test !isnan(D_vapor(earth))
  @test !isnan(ν_air(earth))
  @test !isnan(N_Sc(earth))

  @test !isnan(r_ice_snow(earth))
  @test !isnan(n0_ice(earth))
  @test !isnan(r0_ice(earth))
  @test !isnan(me_ice(earth))
  @test !isnan(m0_ice(earth))

  @test !isnan(q_liq_threshold(earth))
  @test !isnan(τ_acnv_rai(earth))
  @test !isnan(a_vent_rai(earth))
  @test !isnan(b_vent_rai(earth))
  @test !isnan(n0_rai(earth))
  @test !isnan(r0_ice(earth))
  @test !isnan(me_rai(earth))
  @test !isnan(ae_rai(earth))
  @test !isnan(ve_rai(earth))
  @test !isnan(m0_rai(earth))
  @test !isnan(a0_rai(earth))

  @test !isnan(q_ice_threshold(earth))
  @test !isnan(τ_acnv_sno(earth))
  @test !isnan(a_vent_sno(earth))
  @test !isnan(b_vent_sno(earth))
  @test !isnan(μ_sno(earth))
  @test !isnan(ν_sno(earth))
  @test !isnan(r0_sno(earth))
  @test !isnan(me_sno(earth))
  @test !isnan(ae_sno(earth))
  @test !isnan(ve_sno(earth))
  @test !isnan(m0_sno(earth))
  @test !isnan(a0_sno(earth))
  @test !isnan(v0_sno(earth))

  @test !isnan(microph_scaling(earth))
  @test !isnan(microph_scaling_dep_sub(earth))
  @test !isnan(microph_scaling_melt(earth))

  @test !isnan(E_liq_rai(earth))
  @test !isnan(E_liq_sno(earth))
  @test !isnan(E_ice_rai(earth))
  @test !isnan(E_ice_sno(earth))
  @test !isnan(E_rai_sno(earth))

  # Correctness / relations

  # Atmos.Microphysics
  @test N_Sc(earth)           ≈ ν_air(earth)/D_vapor(earth)
  @test m0_rai(earth) ≈ 4/3. * π * ρ_cloud_liq(earth) * r0_rai(earth)^me_rai(earth)
  @test m0_ice(earth) ≈ 4/3. * π * ρ_cloud_ice(earth) * r0_ice(earth)^me_ice(earth)

  @test χm_ice(earth) ≈ 1
  @test Δm_ice(earth) ≈ 0

  @test χm_rai(earth) ≈ 1
  @test Δm_rai(earth) ≈ 0
  @test χa_rai(earth) ≈ 1
  @test Δa_rai(earth) ≈ 0
  @test χv_rai(earth) ≈ 1
  @test Δv_rai(earth) ≈ 0

  @test χm_sno(earth) ≈ 1
  @test Δm_sno(earth) ≈ 0
  @test χa_sno(earth) ≈ 1
  @test Δa_sno(earth) ≈ 0
  @test χv_sno(earth) ≈ 1
  @test Δv_sno(earth) ≈ 0

end

# Adding convenience methods:
abstract type Phase end
struct Liquid <: Phase end
struct Rain   <: Phase end
struct Snow   <: Phase end

E(earth::AbstractEarthParameterSet, ::Liquid, ::Rain) = E_liq_rai(earth)
E(earth::AbstractEarthParameterSet, ::Liquid, ::Snow) = E_liq_sno(earth)

@testset "Microphysics" begin

  struct EarthParamSet <: AbstractEarthParameterSet end

  earth = EarthParamSet()

  @test !isnan(E(earth, Liquid(), Rain()))
  @test !isnan(E(earth, Liquid(), Snow()))

end

