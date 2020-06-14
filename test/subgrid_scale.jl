using Test
using CLIMAParameters: AbstractEarthParameterSet
using CLIMAParameters.SubgridScale

@testset "SubgridScale" begin
  struct EarthParameterSet <: AbstractEarthParameterSet end
  ps = EarthParameterSet()
  @test von_karman_const(ps) ≈ 0.4
end

