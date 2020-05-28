module CLIMAParameters

export AbstractParameterSet
export AbstractEarthParameterSet
export AbstractMicrophysicsParameterSet

export AbstractCloudParameterSet
export AbstractPrecipParameterSet

export AbstractLiquidParameterSet
export AbstractIceParameterSet
export AbstractRainParameterSet
export AbstractSnowParameterSet

include("types.jl")
include("UniversalConstants.jl")

# Function stubs
include("Planet.jl")
include("Atmos.jl")
include("SubgridScale.jl")

# Define values
include("PlanetParameters.jl")
include("AtmosParameters.jl")
include("SubgridScaleParameters.jl")

end # module
