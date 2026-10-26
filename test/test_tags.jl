import ClimaParams as CP
using Test

override_file = joinpath("toml", "tags.toml")
toml_dict = CP.create_toml_dict(Float32; override_file)

businger_param_names = sort([
    "prandtl_number_0_businger",
    "coefficient_a_m_businger",
    "coefficient_b_m_businger",
    "coefficient_a_h_businger",
    "coefficient_b_h_businger",
    "most_stability_parameter_businger",
    "most_stability_exponent_businger",
])

businger_params = CP.get_parameter_values(toml_dict, businger_param_names)

@testset "Tags" begin

    @test pairs(businger_params) ==
          pairs(CP.get_tagged_parameter_values(toml_dict, ["bus in*ger"]))

    @test businger_param_names ==
          sort(CP.get_tagged_parameter_names(toml_dict, ["bus in*ger"]))

end
