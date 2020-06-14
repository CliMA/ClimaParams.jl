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
include(joinpath("Planet", "Planet.jl"))
include(joinpath("Atmos", "Atmos.jl"))
include(joinpath("SubgridScale", "SubgridScale.jl"))

# Define values
include(joinpath("Planet", "planet_parameters.jl"))
include(joinpath("Atmos", "atmos_parameters.jl"))
include(joinpath("SubgridScale", "subgrid_scale_parameters.jl"))

end # module
