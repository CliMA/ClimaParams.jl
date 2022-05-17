using Test
using CLIMAParameters
using CLIMAParameters.Atmos.EDMF

@testset "EDMF" begin

  struct EarthParameterSet <: AbstractEarthParameterSet end
  ps = EarthParameterSet()

  @test !isnan(EDMF.c_λ(ps))
  @test !isnan(EDMF.c_ε(ps))
  @test !isnan(EDMF.c_δ(ps))
  @test !isnan(EDMF.c_γ(ps))
  @test !isnan(EDMF.β(ps))
  @test !isnan(EDMF.μ_0(ps))
  @test !isnan(EDMF.χ(ps))
  @test !isnan(EDMF.w_min(ps))
  @test !isnan(EDMF.lim_ϵ(ps))
  @test !isnan(EDMF.lim_amp(ps))
  @test !isnan(EDMF.a_min(ps))
  @test !isnan(EDMF.a_surf(ps))
  @test !isnan(EDMF.κ_star²(ps))
  @test !isnan(EDMF.ψϕ_stab(ps))
  @test !isnan(EDMF.α_d(ps))
  @test !isnan(EDMF.α_a(ps))
  @test !isnan(EDMF.α_b(ps))
  @test !isnan(EDMF.H_up_min(ps))
  @test !isnan(EDMF.c_d(ps))
  @test !isnan(EDMF.c_m(ps))
  @test !isnan(EDMF.c_b(ps))
  @test !isnan(EDMF.a1(ps))
  @test !isnan(EDMF.a2(ps))
  @test !isnan(EDMF.ω_pr(ps))
  @test !isnan(EDMF.Pr_n(ps))
  @test !isnan(EDMF.Ri_c(ps))
  @test !isnan(EDMF.smin_ub(ps))
  @test !isnan(EDMF.smin_rm(ps))

end
