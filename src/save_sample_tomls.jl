using EnsembleKalmanProcesses: ParameterDistributions
import EnsembleKalmanProcesses.ParameterDistributions: get_distribution, ParameterDistribution, Samples, transform_unconstrained_to_constrained
import TOML, JLD2
import StatsBase: sample

function save_sample_tomls(posterior::ParameterDistribution{Samples},prior_toml, num_samples, output_dir) where {Samples}
    isdir(output_dir) || mkdir(output_dir)
    samples = get_distribution(posterior)
    constrained_samples = Dict(k => transform_unconstrained_to_constrained(posterior, samples[k]) for k in keys(samples))

    # Get the first value for reference
    first_value = first(values(samples))

    # Sample indices without replacement
    sample_indices = sample(1:length(first_value), num_samples)
    for (file_index, i) in enumerate(sample_indices)
        single_sample = TOML.parsefile(prior_toml)
        for k in keys(samples)
            single_sample[k]["value"] = constrained_samples[k][i]
        end
        mkdir(joinpath(output_dir, string(file_index)))
        open(joinpath(output_dir, string(file_index), "parameters.toml") ,"w") do io
            TOML.print(io, single_sample)
        end
        # Sample from each value using the same indices
    end
end

posterior = JLD2.load_object("test/toml/samples.jld2");
prior_toml = "test/toml/prior.toml"
num_samples = 100
output_dir = "param_test"

save_sample_tomls(posterior, prior_toml, num_samples, output_dir)

# TODO: Write tests, test with multiple parameters,