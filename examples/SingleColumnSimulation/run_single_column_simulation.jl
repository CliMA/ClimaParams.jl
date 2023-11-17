using Oceananigans
using CLIMAParameters

# In a "real" use case, we recommend implementing setups in source code.
include("single_column_simulation.jl")

parameters = CLIMAParameters.create_toml_dict(Float64,
                                              override_file = "my_parameters.toml",
                                              default_file = "default_parameters.toml",
                                              dict_type = "name")

parameters = CLIMAParameters.get_parameter_values!(parameters, String[], "Ocean")
parameters = NamedTuple(parameters...)

simulation = single_column_simulation(; parameters...)

run!(simulation)
