using Test
using CLIMAParameters: AbstractEarthParameterSet
using CLIMAParameters.Planet
using CLIMAParameters.Atmos.SubgridScale

@testset "Atmos SubgridScale" begin
  struct EarthParameterSet <: AbstractEarthParameterSet end

  ps = EarthParameterSet()
  # Atmos.SubgridScale
  @test c_1_KASM(ps)       ≈ c_a_KASM(ps)*0.76^2
  @test c_2_KASM(ps)       ≈ c_e2_KASM(ps)+2*c_1_KASM(ps)
  @test c_3_KASM(ps)       ≈ c_a_KASM(ps)^(3/2)

end

