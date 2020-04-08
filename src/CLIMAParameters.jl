module CLIMAParameters

export AbstractParameterSet
export AbstractEarthParameterSet
abstract type AbstractParameterSet end
abstract type AbstractEarthParameterSet <: AbstractParameterSet end

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
