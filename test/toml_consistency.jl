using Test

# read parameters needed for tests
import CLIMAParameters
full_parameter_set = CLIMAParameters.create_parameter_dict(dict_type = "alias")

# import CLIMAParameters
const CP = CLIMAParameters
const CPP = CP.Planet
struct EarthParameterSet <: CP.AbstractEarthParameterSet end
const param_set_cpp = EarthParameterSet()

universal_constant_aliases = [
    "gas_constant",
    "light_speed",
    "h_Planck",
    "k_Boltzmann",
    "Stefan",
    "astro_unit",
    "avogad",
]

@testset "parameter_consistency" begin

    # tests to check parameter consistency of new toml files with existing
    # CP defaults.
    
    # CP modules list:
    module_names = [
    CLIMAParameters,
    CLIMAParameters.Planet,
    #CLIMAParameters.SubgridScale,
    #CLIMAParameters.Atmos.EDMF,
    CLIMAParameters.Atmos.Microphysics_0M,
    CLIMAParameters.Atmos.Microphysics,
    #CLIMAParameters.Atmos.SubgridScale,
    #CLIMAParameters.SurfaceFluxes.UniversalFunctions,
    ]
    CP_parameters = Dict(mod => String.(names(mod)) for mod in module_names)
    
    k_found=[0]
    for (k, v) in full_parameter_set
        for mod in module_names
            if k in CP_parameters[mod]
                k_found[1] = 1
                cp_k = getfield(mod, Symbol(k))                 
                if ~(k in universal_constant_aliases)
                    @test (v ≈ cp_k(param_set_cpp))
                else #universal parameters have no argument
                    @test (v ≈ cp_k())
                end
            end
        end
        if k_found[1] == 0
            println("on trying alias", k)
            throw("did not find in any modules")
        end
        k_found[1] = 0
    end

end
