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

@testset "parsing and writing parameter distributions" begin

    # Load UQ parameters
    uq_param_path = joinpath(@__DIR__,"uq_parameters.toml")
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
            "uq_param_5"),

        "uq_param_6" => ParameterDistribution(
            [Parameterized(Normal(0.0, 1.0)), Parameterized(Normal(5.0, 2.0)),
            Samples([1.0 3.0; 5.0 7.0; 9.0 11.0; 13.0 15.0])],
            [bounded_below(-1.0), no_constraint(), [bounded(5.0, 15.0),
             no_constraint(), bounded_above(100.0), bounded_above(100.0)]],
            ["uq_param_6a", "uq_param_6b", "uq_param_6c"])
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

    # We can also extract multiple `ParameterDistribution`s at once 
    param_names = ["uq_param_2", "uq_param_5", "uq_param_6"]
    pds = CP.get_parameter_distribution(param_dict, param_names)
    #@test pds == [target_map[param_name] for param_name in param_names]

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

@testset "save parameter ensemble" begin

    # Set up an ensemble Kalman process to test writing of parameter ensembles

    # Seed for pseudo-random number generator
    rng_seed = 42
    rng = Random.MersenneTwister(rng_seed)
    
    # Generate data from a linear model:
    # a regression problem with N_par parameters and 1 observation of
    # G(u) = A \times u, where A : R^N_par -> R^N_obs
    N_obs = 10                  # dimension of synthetic observation from G(u)
    N_par = 2                   # Number of parameteres
    u_star = [-1.0, 2.0]        # True parameters
    noise_level = 0.05          # Defining the observation noise level (std) 
    Γy = noise_level^2 * I
    noise = MvNormal(zeros(N_obs), Γy)
    C = [1 -.9; -.9 1]          # Correlation structure for linear operator
    # Linear operator in R^{N_par x N_obs}
    A = rand(rng, MvNormal(zeros(2,), C), N_obs)'

    # Define linear model
    function G(u)
        A * u
    end

    y_star = G(u_star)
    y_obs = y_star .+ rand(rng, noise)

    # Define prior information on parameters
    prior_dist = [Parameterized(Normal(0.0, 0.5)),
                  Parameterized(Normal(3.0, 0.5))]
    constraints = [[no_constraint()], [no_constraint()]]
    param_names = ["u1", "u2"]
    prior = ParameterDistribution(prior_dist, constraints, param_names)

    prior_mean = mean(prior)

    # Assuming independence of u1 and u2
    prior_cov = cov(prior)

    N_ens = 50 # number of ensemble members
    N_iter = 1 # number of iterations

    initial_ensemble = EKP.construct_initial_ensemble(rng, prior, N_ens)
    eksobj = EKP.EnsembleKalmanProcess(
        initial_ensemble,
        y_obs,
        Γy,
        Sampler(prior_mean, prior_cov);
        rng = rng)

    g_ens = G(get_u_final(eksobj))

    save_path = joinpath(@__DIR__, "test_output")
    # EKS iterations
    for i in 1:N_iter
        params_i = get_u_final(eksobj)
        g_ens = G(params_i)
        EKP.update_ensemble!(eksobj, g_ens)
        # Save parameter ensemble
        CP.save_parameter_ensemble(
            EKP.get_u_final(eksobj),
            param_names,
            save_path,
            i
        )
    end

    @test isdir(joinpath(save_path, "iteration_01"))
    file_names = CP.generate_file_names(N_ens)
    for i in 1:N_ens
        @test isfile(joinpath(save_path, "iteration_01", file_names[i]))
    end


end
