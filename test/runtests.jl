

# read parameters needed for tests
import CLIMAParameters
src_parameter_dict = CLIMAParameters.create_parameter_dict(dict_type = "alias")

include("toml_consistency.jl")
include("planet.jl")
include("subgrid_scale.jl")
include("edmf.jl")
include("microphysics.jl")
include("atmos_subgrid_scale.jl")
include("surface_fluxes.jl")
include("override_defaults.jl")
