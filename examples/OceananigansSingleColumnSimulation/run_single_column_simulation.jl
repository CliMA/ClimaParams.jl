using Oceananigans
using CLIMAParameters

# In a "real" use case, we recommend implementing setups in source code.
include("single_column_simulation.jl")

parameters = CLIMAParameters.create_toml_dict(Float64,
                                              override_file = "my_parameters.toml",
                                              default_file = "default_parameters.toml",
                                              dict_type = "name")

parameters = CLIMAParameters.get_parameter_values!(parameters, "gravitational_acceleration", "Ocean")
parameters = NamedTuple(parameters...)

output_filename = "single_column_simulation.jld2"
simulation = single_column_simulation(; parameters..., output_filename,
                                      initial_buoyancy_frequency = 1e-5)

@info "Running a simulation on \n $(simulation.model.grid)..."

run!(simulation)

include("visualize_single_column_simulation.jl")

