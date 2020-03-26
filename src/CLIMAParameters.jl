module CLIMAParameters

export AbstractParameterSet
abstract type AbstractParameterSet end

include("UniversalConstants.jl")

# Function stubs
include("Planet.jl")
include("Atmos.jl")
# include("Ocean.jl")
# include("Land.jl")
# include("Ice.jl")

# Make function stubs accessible.
# Cannot ignore warnings of method
# redefinition, since parameter names
# from different models could clash.
using .Planet
using .Atmos

# Earth default values
export EarthParameterSet
struct EarthParameterSet <: AbstractParameterSet end
include("EarthParameters.jl")

end # module
