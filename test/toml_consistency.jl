using Test

# read parameters needed for tests
import CLIMAParameters
full_parameter_set = CLIMAParameters.create_parameter_struct(dict_type = "alias")

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
    CLIMAParameters.SubgridScale,
    # CLIMAParameters.Atmos.EDMF,
    # CLIMAParameters.Atmos.SubgridScale,
    CLIMAParameters.Atmos.Microphysics_0M,
    CLIMAParameters.Atmos.Microphysics,
    #CLIMAParameters.SurfaceFluxes.UniversalFunctions,
    # NB: Cannot do universal functions - as I have changed the aliases (removing _Businger etc. suffixes)
    ]
    CP_parameters = Dict(mod => String.(names(mod)) for mod in module_names)
    
    k_found=[0]
    for (k, v) in full_parameter_set #iterates over data (by alias) 
        for mod in module_names
            k_value = CLIMAParameters.get_parameter_values(full_parameter_set, k) 
            if k in CP_parameters[mod]
                k_found[1] = 1
                cp_k = getfield(mod, Symbol(k))                 
                if ~(k in universal_constant_aliases)
                    @test (k_value ≈ cp_k(param_set_cpp))
                else #universal parameters have no argument
                    @test (k_value ≈ cp_k())
                end
                #for the logfile test later:
                CLIMAParameters.get_parameter_values!(full_parameter_set, k, mod) 
            end
        end
        if k_found[1] == 0
            println("on trying alias: ", k)
            @warn("did not find in any modules")
        end
        
        k_found[1] = 0
    end

    #create a dummy log file listing where CLIMAParameter lives
    logfilepath = joinpath(@__DIR__,"log_file_test.toml")
    CLIMAParameters.write_log_file(full_parameter_set,logfilepath)

    #read in log file as new parameter file and rerun test.
    full_parameter_set_from_log = CLIMAParameters.create_parameter_struct(logfilepath,dict_type = "alias")
    k_found=[0]
    for (k, v) in full_parameter_set_from_log #iterates over data (by alias) 
        for mod in module_names
            k_value = CLIMAParameters.get_parameter_values(full_parameter_set_from_log, k) 
            if k in CP_parameters[mod]
                k_found[1] = 1
                cp_k = getfield(mod, Symbol(k))                 
                if ~(k in universal_constant_aliases)
                    @test (k_value ≈ cp_k(param_set_cpp))
                else #universal parameters have no argument
                    @test (k_value ≈ cp_k())
                end
            end
        end
        if k_found[1] == 0
            println("on trying alias: ", k)
            @warn("did not find in any modules")
        end
        k_found[1] = 0
    end
    
                   
    

end
