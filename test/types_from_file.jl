using Test

import CLIMAParameters as CP

path_to_params = joinpath(@__DIR__, "toml", "typed_parameters.toml")

@testset "parameter types from file" begin

    # read parameters needed for tests
    toml_dict_64 = CP.create_toml_dict(
        Float64;
        override_file = path_to_params,
        dict_type = "name",
    )

    toml_dict_32 = CP.create_toml_dict(
        Float32;
        override_file = path_to_params,
        dict_type = "name",
    )

    param_names = [
        "int_array_param",
        "int_param",
        "string_param",
        "string_array_param",
        "untyped_param",
        "ft_array_param",
        "bool_param",
        "light_speed",
    ]

    param_pairs_64 = CP.get_parameter_values(toml_dict_64, param_names)
    nt = (; param_pairs_64...)
    @test typeof(nt.string_param) == String
    @test eltype(nt.string_array_param) == String
    @test typeof(nt.untyped_param) == String

    @test typeof(nt.int_param) == Int
    @test eltype(nt.int_array_param) == Int

    @test typeof(nt.light_speed) == Float64
    @test eltype(nt.ft_array_param) == Float64

    param_pairs_32 = CP.get_parameter_values(toml_dict_32, param_names)

    nt = (; param_pairs_32...)

    @test typeof(nt.string_param) == String
    @test eltype(nt.string_array_param) == String
    @test typeof(nt.untyped_param) == String

    @test typeof(nt.int_param) == Int
    @test eltype(nt.int_array_param) == Int

    @test typeof(nt.light_speed) == Float32
    @test eltype(nt.ft_array_param) == Float32

    @test_throws ErrorException CP.get_parameter_values(
        toml_dict_32,
        "badtype_param",
    )

end
