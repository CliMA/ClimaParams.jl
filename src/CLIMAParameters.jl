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

abstract type AbstractParameterSet end
abstract type AbstractEarthParameterSet <: AbstractParameterSet end
abstract type AbstractMicrophysicsParameterSet <: AbstractParameterSet end

abstract type AbstractCloudParameterSet  <: AbstractMicrophysicsParameterSet end
abstract type AbstractPrecipParameterSet <: AbstractMicrophysicsParameterSet end

abstract type AbstractLiquidParameterSet <: AbstractCloudParameterSet end
abstract type AbstractIceParameterSet    <: AbstractCloudParameterSet end
abstract type AbstractRainParameterSet   <: AbstractPrecipParameterSet end
abstract type AbstractSnowParameterSet   <: AbstractPrecipParameterSet end

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
