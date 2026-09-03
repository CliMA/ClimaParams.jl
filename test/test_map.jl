using Test
import ClimaParams as CP

@testset "name map tests" begin
    toml_dict = CP.create_toml_dict(Float64)

    @testset "Every name map spelling" begin
        symbol_dict = Dict(
            :gravitational_acceleration => :g,
            :angular_velocity_planet_rotation => :omega,
        )
        string_dict = Dict(
            "gravitational_acceleration" => "g",
            "angular_velocity_planet_rotation" => "omega",
        )
        symbol_pairs = (
            :gravitational_acceleration => :g,
            :angular_velocity_planet_rotation => :omega,
        )
        string_pairs = (
            "gravitational_acceleration" => "g",
            "angular_velocity_planet_rotation" => "omega",
        )
        named_tuple = (;
            :gravitational_acceleration => :g,
            :angular_velocity_planet_rotation => :omega,
        )
        for name_map in (
            symbol_dict,
            string_dict,
            symbol_pairs,
            string_pairs,
            named_tuple,
            [symbol_pairs...],
            [string_pairs...],
        )
            params = CP.get_parameter_values(toml_dict, name_map)
            @test params.g == 9.81
            @test params.omega == 7.2921159e-5
        end
    end

    @testset "Varargs" begin
        params = CP.get_parameter_values(
            toml_dict,
            :gravitational_acceleration => :g,
            :angular_velocity_planet_rotation => :omega,
        )
        @test params.g == 9.81
        @test params.omega == 7.2921159e-5

        # `component` is a keyword here, unlike in the other methods,
        # because the positional slots are taken by the pairs.
        logged_dict = CP.create_toml_dict(Float64)
        CP.get_parameter_values(
            logged_dict,
            :gravitational_acceleration => :g;
            component = "TestComponent",
        )
        @test logged_dict.data["gravitational_acceleration"]["used_in"] ==
              ["TestComponent"]
    end

    @testset "Component logging" begin
        logged_dict = CP.create_toml_dict(Float64)
        CP.get_parameter_values(
            logged_dict,
            Dict("gravitational_acceleration" => "g"),
            "Ocean",
        )
        @test logged_dict.data["gravitational_acceleration"]["used_in"] ==
              ["Ocean"]
    end

    @testset "create_parameter_struct" begin
        Base.@kwdef struct TestParameters{FT}
            g::FT
            omega::FT
            # Derived parameter
            g_over_omega::FT = g / omega
        end

        name_map = Dict(
            "gravitational_acceleration" => "g",
            "angular_velocity_planet_rotation" => "omega",
        )
        params = CP.create_parameter_struct(TestParameters, toml_dict, name_map)
        @test params isa TestParameters{Float64}
        @test params.g == 9.81
        @test params.g_over_omega == 9.81 / 7.2921159e-5

        # The float type comes from the dictionary, not from the values.
        params_f32 = CP.create_parameter_struct(
            TestParameters,
            CP.create_toml_dict(Float32),
            name_map,
        )
        @test params_f32 isa TestParameters{Float32}
    end
end
