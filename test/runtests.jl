using Test
using CLIMAParameters
using CLIMAParameters.Planet
using CLIMAParameters.Atmos.Turbulence
using CLIMAParameters.Atmos.Microphysics

@testset "Earth" begin
  struct EarthParameterSet <: AbstractEarthParameterSet end

  param_set = EarthParameterSet()

  # Test that all methods are callable, and that nothing returns NaNs
  for _module in [Planet, Turbulence, Microphysics]

    exported_methods = names(_module)
    filter!(x->x≠Symbol(nameof(_module)), exported_methods)
    for m in exported_methods
      @test !isnan(_module.eval(m)(param_set))
    end
  end

end

