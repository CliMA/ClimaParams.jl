module ParameterBoxes

using Test
import CLIMAParameters
const CP = CLIMAParameters

Base.@kwdef struct ParameterBox{FT}
    molmass_dryair::FT
    gas_constant::FT
    new_parameter::FT
    # Derived parameters
    R_d::FT = gas_constant / molmass_dryair
end

function ParameterBox(toml_dict::CP.AbstractTOMLDict)

    aliases = ["molmass_dryair", "gas_constant", "new_parameter"]

    params = CP.get_parameter_values!(toml_dict, aliases, "ParameterBox")
    # Returns an array of `Pair`s for all given `aliases`

    FT = CP.float_type(toml_dict)
    return ParameterBox{FT}(; params...)
end


@testset "Example use case: parameter box" begin

    # [1.] read from file
    toml_file = joinpath(@__DIR__, "toml", "parambox.toml")
    toml_dict = CP.create_toml_dict(
        Float64;
        override_file = toml_file,
        dict_type = "alias",
    )

    # [2.] build
    param_set = ParameterBox(toml_dict)

    # [3.] log & checks(with warning)
    mktempdir(@__DIR__) do path
        logfilepath = joinpath(path, "logfilepath.toml")
        @test_logs (:warn,) CP.log_parameter_information(toml_dict, logfilepath)
    end

    # [4.] use
    # from default
    @test param_set.molmass_dryair ≈ 0.02897
    # overridden default
    @test param_set.gas_constant ≈ 4.0
    # derived in constructor
    @test param_set.R_d ≈ param_set.gas_constant / param_set.molmass_dryair
    # from toml
    @test param_set.new_parameter ≈ 19.99

end

end # end module
