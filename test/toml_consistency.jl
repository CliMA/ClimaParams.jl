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
logfilepath1 = joinpath(@__DIR__, "log_file_test_1.toml")
logfilepath2 = joinpath(@__DIR__, "log_file_test_2.toml")
logfilepath3 = joinpath(@__DIR__, "log_file_test_3.toml")

@testset "parameter file interface tests" begin
    
    @testset "TOML - CliMAParameters.jl consistency" begin    
        # tests to check parameter consistency of new toml files with existing
        # CP defaults.
        
        
        
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
        CP.write_log_file(full_parameter_set, logfilepath1)
    end
    
    @testset "Parameter logging" begin
        

        #read in log file as new parameter file and rerun test.
        full_parameter_set_from_log = CP.create_parameter_struct(logfilepath1,dict_type = "alias")
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
    end

    @testset "parameter arrays" begin
        # Tests to check if file parsing, extracting and logging of parameter
        # values also works with array-valued parameters
        
        # Create parameter structs consisting of the parameters contained in the
        # default parameter file ("parameters.toml") and additional (array valued)
        # parameters ("array_parameters.toml"). 
#        path_to_array_params = joinpath(splitpath(pathof(CP))[1:end-2]...,"test/array_parameters.toml")
        path_to_array_params = joinpath(@__DIR__,"array_parameters.toml")
        # parameter struct of type Float64 (default)
        param_set = CP.create_parameter_struct(path_to_array_params,
                                               dict_type="name")
        # parameter struct of type Float32
        param_set_f32 = CP.create_parameter_struct(path_to_array_params,
                                                   dict_type="name",
                                                   value_type=Float32)
        
        # true parameter values (used to check if values are correctly read from
        # the toml file)
        true_param_1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
        true_param_2 = [0.0, 1.0, 1.0, 2.0, 3.0, 5.0, 8.0, 13.0, 21.0, 34.0]
        true_param_3 = [9.81, 10.0]
        true_param_4 = 299792458 
        true_params = [true_param_1, true_param_2, true_param_3, true_param_4]
        param_names = ["array_parameter_1", "array_parameter_2",
                       "gravitational_acceleration", "light_speed"]
        
        # Let's assume that parameter_vector_1 and parameter_vector_2 are used
        # in a module called "Test"
        mod = "Test"
        
        # Get parameter values and add information on the module where the
        # parameters are used. 
        for i in range(1, stop=length(true_params))
            
            param = CP.get_parameter_values!(param_set, param_names[i], mod)
            @test param == true_params[i]
            # Check if the parameter is of the correct type. It should have
            # the same type as the ParamDict, which is specified by the
            # `value_type`` argument to `create_parameter_struct`.
            @test eltype(param) == Float64
            
            param_f32 = CP.get_parameter_values!(param_set_f32, param_names[i], mod)
            @test eltype(param_f32) == Float32

        end
        
        # Get several parameter values (scalar and arrays) at once
        params = CP.get_parameter_values(param_set, param_names)
        for j in 1:length(param_names)
            @test params[j] == true_params[j]
        end
        
        # Write parameters to log file
        CP.write_log_file(param_set, logfilepath2)
        
        # `param_set` and `full_param_set` contain different values for the
        # `gravitational_acceleration` parameter. The merged parameter set should
        # contain the value from `param_set`.
        full_param_set = CP.create_parameter_struct(dict_type="name")
        merged_param_set = CP.merge_override_default_values(
            param_set,
            full_param_set,
        )
        grav = CP.get_parameter_values(
            merged_param_set,
            "gravitational_acceleration")
        @test grav == true_param_3
    end

    @testset "checks for overrides" begin
        full_param_set = CP.create_parameter_struct(joinpath(@__DIR__,"override_typos.toml"), dict_type="name")
        @test_logs (:warn,) CP.log_parameter_information(full_param_set, logfilepath3)
        @test_throws ErrorException CP.log_parameter_information(full_param_set, logfilepath3, warn_else_error="error")
    end


end
