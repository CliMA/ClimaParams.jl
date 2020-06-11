module CLIMAParameters

include("types.jl")
include("UniversalConstants.jl")

# Function stubs
include("Planet.jl")
include("Atmos.jl")
include("SubgridScale.jl")
include(joinpath("Land", "Land.jl"))

# Define values
include("PlanetParameters.jl")
include("AtmosParameters.jl")
include("SubgridScaleParameters.jl")
include(joinpath("Land", "land_parameters.jl"))

end # module
