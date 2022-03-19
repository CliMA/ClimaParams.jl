using Test
using Distributions
using Random
using LinearAlgebra

# import CLIMAParameters
using CLIMAParameters
const CP = CLIMAParameters

using EnsembleKalmanProcesses
using EnsembleKalmanProcesses.Observations
using EnsembleKalmanProcesses.ParameterDistributions
const EKP = EnsembleKalmanProcesses

@testset "Parse and write parameter distributions" begin

    # Load UQ parameters
    uq_param_path = joinpath(@__DIR__,"uq_test_parameters.toml")
    param_dict = CP.parse_toml_file(uq_param_path)


    # True `ParameterDistribution`s. This is what `get_parameter_distribution`
    # should return
    target_map = Dict(
        "uq_param_1" => ParameterDistribution(
            Parameterized(Normal(2.0, 1.0)),
            no_constraint(),
            "uq_param_1"),

        "uq_param_2" => ParameterDistribution(
            Parameterized(Gamma(5.0, 2.0)),
            bounded_below(3.0),
            "uq_param_2"),

        "uq_param_3" => ParameterDistribution(
            Parameterized(MvNormal(4, 0.1)),
            [no_constraint(), bounded_below(-1.0),
            bounded_above(0.4), bounded(-0.1, 0.2)],
            "uq_param_3"),

        "uq_param_4" => ParameterDistribution(
            Samples([1.0 3.0 5.0 7.0; 9.0 11.0 13.0 15.0]),
            [bounded(10.0, 15.0), bounded_below(-1.0)],
            "uq_param_4"),

        "uq_param_5" => ParameterDistribution(
            Samples([1.0 3.0; 5.0 7.0; 9.0 11.0; 13.0 15.0]),
            [no_constraint(), no_constraint(),
             bounded_below(-2.0), bounded_above(100.0)],
            "uq_param_5")
    )

    # Get all `ParameterDistribution`s. We also add dummy (key, value) pairs
    # to check if that information gets added correctly when saving the
    # parameters back to file and re-loading them
    descr = " will be learned using CES"
    for param_name in keys(param_dict)
        param_dict[param_name]["description"] = param_name * descr
        pd = CP.get_parameter_distribution(param_dict, param_name)
        target_pd = target_map[param_name]

        # Check names
        @test get_name(pd) == get_name(target_pd)
        # Check distributions
        @test get_distribution(pd) == get_distribution(target_pd)
        # Check constraints
        constraints = get_all_constraints(pd)
        target_constraints = get_all_constraints(target_pd)
        @test constraints == target_constraints

    end

    # We can also get a `ParameterDistribution` representing
    # multiple parameters
    param_names = ["uq_param_2", "uq_param_4", "uq_param_5"]
    pd = CP.get_parameter_distribution(param_dict, param_names)

    # Save the parameter dictionary and re-load it. 
    logfile_path = joinpath(@__DIR__,"log_file_test_uq.toml")
    CP.write_log_file(param_dict, logfile_path)

    # Read in log file as new parameter file and rerun test.
    param_dict_from_log = CP.parse_toml_file(logfile_path)
    rm(logfile_path) # clean up
    for param_name in keys(param_dict_from_log)
        pd = CP.get_parameter_distribution(param_dict_from_log, param_name)
        @test get_distribution(pd) == get_distribution(target_map[param_name])
        @test param_dict_from_log[param_name]["description"] == param_name*descr
    end

end

# This test set creates a directory "test_output" in "CLIMAParameters.jl/test"
# where the new parameteter files resulting from updating an ensemble Kalman
# ensemble are saved
@testset "Save parameter ensemble" begin

    # Combine a parameter struct from the parameters defined in
    # "uq_test_parameters.toml" (the override file) and those defined in
    # "test_parameters.toml" (the default file)
    param_path = joinpath(@__DIR__, "test_parameters.toml")
    uq_param_path = joinpath(@__DIR__,"uq_test_parameters.toml")
    param_set = CP.create_parameter_struct(
        uq_param_path,
        param_path,
        dict_type="name"
    )

    # Extract the UQ parameters from the joint set of the parameters from
    # param_path and those from uq_param_path
    uq_param_names = CP.get_UQ_parameters(param_set)

    # Seed for pseudo-random number generator
    rng_seed = 42
    rng = Random.MersenneTwister(rng_seed)
    
    # Construct the parameter distribution
    pd = CP.get_parameter_distribution(param_set, uq_param_names)

    # ------
    # Set up an ensemble Kalman process to test writing of parameter ensembles
    # ------

    # Generate symthetic observations y_obs by evaluating a (completely
    # contrived) forward map G(u) (where u are the parameters) with the 
    # the true parameter values u* (which we pretend to know for the
    # purpose of this example) and adding random observational noise η

    # Define forward map (this is a completely contrived example)
    A3 = rand([0, 1], 4, 4)
    A5 = rand([0, 1], 4, 4)
    function G(u1, u2, u3, u4, u5)  # map from R^5 to R^4
        A4 = reshape([1, 1, u1, u2], 4, 1)
        y = A3 * u3 + A5 * u5 + norm(u4) * A4
        return dropdims(y, dims=2) 
    end

    # True parameter values
    u1_star = 2.5
    u2_star = 3.0
    u3_star = [0.12, -0.05, -0.13, 0.05]
    u4_star = [4.0, 14.0]
    u5_star = [2.5, 5.5, 10.0, 14.2]
    
    # Synthetic observation
    y_star = G(u1_star, u2_star, u3_star, u4_star, u5_star)
    Γy = 0.05 * I
    pdf_η = MvNormal(zeros(4), Γy)
    y_obs = y_star .+ rand(pdf_η)

    N_ens = 50 # number of ensemble members
    N_iter = 1 # number of iterations

    # Generate and save initial paramter ensemble 
    initial_ensemble = EKP.construct_initial_ensemble(rng, pd, N_ens)
    save_path = joinpath(@__DIR__, "test_output")
    save_file = "test_parameters.toml"
    CP.save_parameter_ensemble(
        initial_ensemble,
        pd,
        param_set,
        save_path,
        save_file,
        0 # We consider the initial ensemble to be the 0th iteration
    )

    # Instantiate an ensemble Kalman process
    eksobj = EKP.EnsembleKalmanProcess(
        initial_ensemble,
        y_obs,
        Γy,
        Inversion(),
        rng=rng)

    # EKS iterations
    for i in 1:N_iter
        params_i = get_u_final(eksobj)
        G_n = [G(params_i[1,i],
                 params_i[2,i],
                 params_i[3:6,i],
                 params_i[7:8,i],
                 params_i[9:12,i]) for i in 1:N_ens]
        G_ens = hcat(G_n...) 
        EKP.update_ensemble!(eksobj, G_ens)
        # Save updated parameter ensemble
        CP.save_parameter_ensemble(
            EKP.get_u_final(eksobj),
            pd,
            param_set,
            save_path,
            save_file,
            i
        )
    end

    # Check if all parameter files have been created (we expect there to be
    # one for each iteration and ensemble member)
    @test isdir(joinpath(save_path, "iteration_00"))
    @test isdir(joinpath(save_path, "iteration_01"))
    subdir_names = CP.generate_subdir_names(N_ens)
    for i in 1:N_ens
        subdir_0 = joinpath(save_path, "iteration_00", subdir_names[i])
        subdir_1 = joinpath(save_path, "iteration_01", subdir_names[i])
        @test isdir(subdir_0)
        @test isfile(joinpath(subdir_0, save_file))
        @test isdir(subdir_1)
        @test isfile(joinpath(subdir_1, save_file))
    end
end
