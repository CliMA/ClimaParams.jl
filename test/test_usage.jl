using Test

import ClimaParams as CP

@testset "Test parameter usage" begin
    toml_1 = ("toml/merge1.toml")
    toml_2 = ("toml/merge2.toml")

    pd = CP.create_toml_dict(Float32, toml_2; default_file = toml_1)

    @test_throws ErrorException CP.check_override_parameter_usage(
        pd,
        ("a",),
        true,
    )

    used_a = pd["a"]
    @test isnothing(CP.check_override_parameter_usage(pd, ("a",), true))

    used_b = pd["b"]
    @test isnothing(CP.check_override_parameter_usage(pd, ("a", "b"), true))

    # Error from parameter not existing in override file
    @test_throws r"does not exist in override file" CP.check_override_parameter_usage(
        pd,
        ("c",),
        true,
    )

    no_override_dict = CP.create_toml_dict(Float32)
    @test_throws r"Override file was not provided when creating ParamDict" CP.check_override_parameter_usage(
        no_override_dict,
        ("a",),
        true,
    )
end
