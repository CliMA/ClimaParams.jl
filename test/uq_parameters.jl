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

    # Load parameters
    toml_path = joinpath(@__DIR__,"uq_test_parameters.toml")
    param_dict = CP.read_parameters(toml_path)


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
            [Parameterized(Gamma(2.0, 1.0)), Parameterized(Gamma(2.0, 1.0)),
             Parameterized(Gamma(2.0, 1.0))],
            [[bounded_above(9.0)], [bounded_above(9.0)], [bounded_above(9.0)]],
            ["uq_param_6_(1)", "uq_param_6_(2)", "uq_param_6_(3)"]),

        "uq_param_7" => ParameterDistribution(
            Parameterized(MvNormal(3, 2.0)),
            [no_constraint(), no_constraint(), no_constraint()],
            "uq_param_7")
    )

    # Get all `ParameterDistribution`s. We also add dummy (key, value) pairs
    # to check if that information gets added correctly when saving the
    # parameters back to file and re-loading them
    uq_param_names = CP.get_UQ_parameters(param_dict)
    descr = " will be learned using CES"

    for param_name in uq_param_names
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
    param_list = ["uq_param_2", "uq_param_4", "uq_param_5"]
    pd = CP.get_parameter_distribution(param_dict, param_list)

    # Save the parameter dictionary and re-load it. 
    logfile_path = joinpath(@__DIR__,"log_file_test_uq.toml")
    CP.write_log_file(param_dict, logfile_path)

    # Read in log file as new parameter file and rerun test.
    param_dict_from_log = CP.read_parameters(logfile_path)
    for param_name in uq_param_names
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
    toml_path = joinpath(@__DIR__,"uq_test_parameters.toml")
    param_dict = CP.read_parameters(toml_path)

    # Extract the UQ parameters from the joint set of the parameters from
    # param_path and those from uq_param_path
    uq_param_names = CP.get_UQ_parameters(param_dict)

    # Seed for pseudo-random number generator
    rng_seed = 42
    rng = Random.MersenneTwister(rng_seed)
    
    # Construct the parameter distribution
    pd = CP.get_parameter_distribution(param_dict, uq_param_names)
    slices = batch(pd) # Will need this later to extract parameters

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

    function G(u) # map from R^18 to R^4
        u_constr = transform_unconstrained_to_constrained(pd, u)
        value_of = Dict()
        for (i, param) in enumerate(get_name(pd))
            value_of[param] = u_constr[slices[i]]
        end
        A4 = reshape(
            [norm(value_of["uq_param_4"]) + value_of["uq_param_6_(1)"][1],
             norm(value_of["uq_param_6_(2)"]) * value_of["uq_param_6_(3)"][1],
             value_of["uq_param_2"][1],
             value_of["uq_param_1"][1]], 4, 1)
        y = (A3 * value_of["uq_param_3"] + A5 * value_of["uq_param_5"]
             + norm(value_of["uq_param_4"]) * A4)
        return dropdims(y, dims=2) 
    end

    # True parameter values (in constrained space)
    u1_star = 14.6
    u2_star = 19.0
    u3_star = [0.12, -0.05, -0.13, 0.05]
    u4_star = [12.0, 14.0]
    u5_star = [10.0, -1.0, 1.5, 10.0]
    u6_1_star = 1.0
    u6_2_star = 1.0
    u6_3_star = 1.0
    u7_star = 3.0 * ones(3)
    u_star = vcat(u1_star, u2_star, u3_star, u4_star, u5_star,
                  u6_1_star, u6_2_star, u6_3_star, u7_star)

    # True parameter values in constrained space
    u_star_constr = transform_unconstrained_to_constrained(pd, u_star)
    
    # Synthetic observation
    A4_star = reshape(
        [norm(u4_star) + u6_1_star,
         norm(u6_2_star) * u6_3_star,
         u2_star,
         u1_star], 4, 1)

    y_star = A3 * u3_star + A5 * u5_star + norm(u4_star) * A4_star # G(u_star)
    Γy = 0.05 * I
    pdf_η = MvNormal(zeros(4), Γy)
    y_obs = dropdims(y_star, dims=2) .+ rand(pdf_η)

    N_ens = 50 # number of ensemble members
    N_iter = 1 # number of iterations

    # Generate and save initial paramter ensemble 
    initial_ensemble = EKP.construct_initial_ensemble(rng, pd, N_ens)
    save_path = joinpath(@__DIR__, "test_output")
    save_file = "test_parameters.toml"
    CP.save_parameter_ensemble(
        initial_ensemble,
        pd,
        param_dict,
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
        G_n = [G(params_i[:, member_idx]) for member_idx in 1:N_ens]
#?g        G_n = [G(params_i[1, i],
#?g                 params_i[2, i],
#?g                 params_i[3:6, i],
#?g                 params_i[7:8, i],
#?g                 params_i[9:12, i],
#?g                 params_i[13:15, i],
#?g                 params_i[16:18, i]) for i in 1:N_ens]
        G_ens = hcat(G_n...)
        EKP.update_ensemble!(eksobj, G_ens)
        # Save updated parameter ensemble
        CP.save_parameter_ensemble(
            EKP.get_u_final(eksobj),
            pd,
            param_dict,
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
