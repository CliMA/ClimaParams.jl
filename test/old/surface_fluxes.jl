using Test
using CLIMAParameters: AbstractEarthParameterSet
using CLIMAParameters.SurfaceFluxes.UniversalFunctions

@testset "SurfaceFluxes" begin
    struct EarthParameterSet <: AbstractEarthParameterSet end
    ps = EarthParameterSet()

    @testset "UniversalFunctions" begin
        @test Pr_0_Businger(ps) ≈ 0.74
        @test a_m_Businger(ps) ≈ 4.7
        @test a_h_Businger(ps) ≈ 4.7
        @test Pr_0_Gryanik(ps) ≈ 0.98
        @test a_m_Gryanik(ps) ≈ 5.0
        @test a_h_Gryanik(ps) ≈ 5.0
        @test b_m_Gryanik(ps) ≈ 0.3
        @test b_h_Gryanik(ps) ≈ 0.4
        @test Pr_0_Grachev(ps) ≈ 0.98
        @test a_m_Grachev(ps) ≈ 5.0
        @test a_h_Grachev(ps) ≈ 5.0
        @test b_m_Grachev(ps) ≈ a_m_Grachev(ps) / 6.5
        @test b_h_Grachev(ps) ≈ 5.0
        @test c_h_Grachev(ps) ≈ 3.0
    end
end
