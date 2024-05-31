using Oceananigans
using ClimaParams

# In a "real" use case, we recommend implementing setups in source code.
include("single_column_simulation.jl")
project_dir = dirname(Base.active_project())

toml_dict = ClimaParams.create_toml_dict(
    Float64,
    override_file = joinpath(project_dir, "my_parameters.toml"),
    default_file = joinpath(project_dir, "default_parameters.toml"),
)

parameters = ClimaParams.get_parameter_values(
    toml_dict,
    "gravitational_acceleration",
    "Ocean",
)

output_filename = "single_column_simulation.jld2"
simulation = single_column_simulation(;
    parameters...,
    output_filename,
    initial_buoyancy_frequency = 1e-5,
)

@info "Running a simulation on \n $(simulation.model.grid)..."

run!(simulation)

include("visualize_single_column_simulation.jl")
