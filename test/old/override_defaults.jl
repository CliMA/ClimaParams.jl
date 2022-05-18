import CLIMAParameters

@testset "Override defaults" begin
    struct EarthParameterSet <: AbstractEarthParameterSet end

    ps = EarthParameterSet()
    CLIMAParameters.Planet.grav(::EarthParameterSet) = 2.0
    @test grav(ps) ≈ 2.0

end
