using TOML

function parse_toml_file(filepath)
    return TOML.parsefile(filepath)
end




function create_alias_value_dict(full_parameter_dict)
    alias_value_dict = Dict{String, Float64}()
    for (key, val) in full_parameter_dict
        # In the future - we will use the full names,
        # param_dict[key] = val["value"]
        
        # for now we use the aliases
        alias_value_dict[val["alias"]] = val["value"]
    end
    return alias_value_dict
end

function create_name_value_dict(full_parameter_dict)
    name_value_dict = Dict{String, Float64}()
    for (key, val) in full_parameter_dict
        # In the future - we will use the full names,
        name_value_dict[key] = val["value"]
    end
    return name_value_dict
end

function merge_override_default_values(override_param_dict,default_param_dict)
    merged_dict = default_param_dict
    for (key, val) in override_param_dict
        merged_dict[key] = val
    end
    return merged_dict
end

function create_param_dict(full_parameter_dict, dict_type)
    if dict_type == "alias"
        return create_alias_value_dict(full_parameter_dict)
    elseif dict_type == "name"
        return create_name_value_dict(full_parameter_dict)
    else
        throw(ArgumentError("Unknown dict_type, choose from \"alias\" or \"name\""))
    end
end

function create_parameter_dict(path_to_override, path_to_default; dict_type="alias")
    #if there isn't  an override file take defaults
    if isnothing(path_to_override)
        return create_param_dict(parse_toml_file(path_to_default), dict_type)
    else
        try 
            override_param_dict = create_param_dict(parse_toml_file(path_to_override), dict_type)
            default_param_dict = create_param_dict(parse_toml_file(path_to_default), dict_type)
        
            #overrides the defaults where they clash
            return merge_override_default_values(override_param_dict, default_param_dict)
        catch
            @warn("Error in building from parameter file: ", path_to_override,"instead, created using defaults from CLIMAParameters...")
            return create_param_dict(parse_toml_file(path_to_default), dict_type)
        end
    end
        
end

function create_parameter_dict(path_to_override; dict_type="alias")
    #pathof finds the CLIMAParameters.jl/src/ClimaParameters.jl location
    path_to_default = joinpath(splitpath(pathof(CLIMAParameters))[1:end-1]...,"parameters.toml")
    return create_parameter_dict(
        path_to_override,
        path_to_default,
        dict_type=dict_type
    )
end

function create_parameter_dict(; dict_type="alias")
    return create_parameter_dict(
        nothing,
        dict_type=dict_type
    )
end
