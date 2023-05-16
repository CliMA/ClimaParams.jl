using Test

import CLIMAParameters as CP

@testset "Merge correctness" begin

    FT = Float64
    toml_1 = ("toml/merge1.toml")
    toml_2 = ("toml/merge2.toml")

    toml_dict_1 = CP.create_toml_dict(FT, default_file = toml_1)
    toml_dict_2 = CP.create_toml_dict(FT, default_file = toml_2)

    # Test individual TOMLs
    a_1 = CP.get_parameter_values(toml_dict_1, "a")[2]
    a_2 = CP.get_parameter_values(toml_dict_2, "a")[2]
    @test a_1 == 0.0
    @test a_1 isa FT
    @test a_2 == 2
    @test a_2 isa Int

    # Test merging
    merged_dict = CP.merge_toml_files([toml_1, toml_2]; override = true)
    merged_toml_dict = CP.create_toml_dict(FT, default_file = merged_dict)
    merged_a = CP.get_parameter_values(merged_toml_dict, "a")[2]
    @test merged_a == 2
    @test merged_a isa Int
    merged_b = CP.get_parameter_values(merged_toml_dict, "b")[2]
    @test merged_b == 3.0
    @test merged_b isa FT

    # Swap merge order
    merged_dict = CP.merge_toml_files([toml_2, toml_1]; override = true)
    merged_toml_dict = CP.create_toml_dict(FT, default_file = merged_dict)
    merged_a = CP.get_parameter_values(merged_toml_dict, "a")[2]
    @test merged_a == 0.0
    @test merged_a isa FT
    merged_b = CP.get_parameter_values(merged_toml_dict, "b")[2]
    @test merged_b == 3.0
    @test merged_b isa FT
end
