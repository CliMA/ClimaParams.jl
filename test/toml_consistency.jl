using Test

# import CLIMAParameters
import CLIMAParameters
const CP = CLIMAParameters

# read parameters needed for tests
full_parameter_set = CP.create_parameter_struct(dict_type="alias")

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

@testset "CLIMA_parameter_consistency" begin

    # tests to check parameter consistency of new toml files with existing
    # CP defaults.
    
    # CP modules list:
    module_names = [
    CP,
    CP.Planet,
    CP.SubgridScale,
    # CP.Atmos.EDMF,
    # CP.Atmos.SubgridScale,
    CP.Atmos.Microphysics_0M,
    CP.Atmos.Microphysics,
    CP.SurfaceFluxes.UniversalFunctions,
    ]
    CP_parameters = Dict(mod => String.(names(mod)) for mod in module_names)
    
    k_found=[0]
    for (k, v) in full_parameter_set #iterates over data (by alias) 

        for mod in module_names
            k_value = CP.get_parameter_values(full_parameter_set, k) 
            if k in CP_parameters[mod]
                k_found[1] = 1
                cp_k = getfield(mod, Symbol(k))                 
                if ~(k in universal_constant_aliases)
                    @test (k_value ≈ cp_k(param_set_cpp))
                else #universal parameters have no argument
                    @test (k_value ≈ cp_k())
                end
                #for the logfile test later:
                CP.get_parameter_values!(full_parameter_set, k, mod) 
            end
        end
        if k_found[1] == 0
            println("on trying alias: ", k)
            @warn("did not find in any modules")
        end
        
        k_found[1] = 0
    end

    #create a dummy log file listing where CLIMAParameter lives
    logfilepath = joinpath(@__DIR__,"log_file_test_1.toml")
    CP.write_log_file(full_parameter_set, logfilepath)

    #read in log file as new parameter file and rerun test.
    full_parameter_set_from_log = CP.create_parameter_struct(logfilepath,dict_type = "alias")
    k_found=[0]
    for (k, v) in full_parameter_set_from_log #iterates over data (by alias) 
        for mod in module_names
            k_value = CP.get_parameter_values(full_parameter_set_from_log, k) 
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
    
@testset "vector_valued_parameters" begin

    # Tests to check if file parsing, extracting and logging of parameter
    # values also works with array-valued parameters

	  # Create parameter struct consisting of the parameters contained in the
    # default parameter file ("parameters.toml") and additional (array valued)
    # parameters ("array_parameters.toml")
    path_to_array_params = joinpath(splitpath(pathof(CP))[1:end-1]...,"array_parameters.toml")
    param_set = CP.create_parameter_struct(path_to_array_params,
                                           dict_type="name")
    true_param_1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    true_param_2 = [0.0, 1.0, 1.0, 2.0, 3.0, 5.0, 8.0, 13.0, 21.0, 34.0]
    true_param_3 = [9.81, 10.0]
    true_params = [true_param_1, true_param_2, true_param_3]
    param_names = ["array_parameter_1", "array_parameter_2",
                   "gravitational_acceleration"]

    # Let's assume that parameter_vector_1 and parameter_vector_2 are used
    # in a module called "Test"
    mod = "Test"

    # Get parameter values and add information on the module where the
    # parameters are used
    for i in range(1, stop=length(true_params))
        param = CP.get_parameter_values!(param_set, param_names[i], mod)
        @test param == true_params[i]
    end

    # Write parameters to log file
    logfilepath = joinpath(@__DIR__, "log_file_test_2.toml")
    CP.write_log_file(param_set, logfilepath)

    # param_set and full_param_set contain different values for the
    # gravitational_acceleration parameter. The merged parameter set should
    # contain the value from param_set.
    full_param_set = CP.create_parameter_struct(dict_type="name")
    merged_param_set = CP.merge_override_default_values(param_set,
                                                        full_param_set,
                                                        )
    grav = CP.get_parameter_values(merged_param_set,
                                   "gravitational_acceleration")
    @test grav == true_param_3

end
    
end
