using TOML

function parse_toml_file(filepath)
    return TOML.parsefile(filepath)
end

#=
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
=#
# Alternatively do it with a wrapper struct. 
struct ParamDict{FT}
    data::Dict
    dict_type::String
end

# to get the "float" or whatever back
get_parametric_type(::ParamDict{FT}) where {FT} = FT

function iterate_alias(d::Dict)
    it = iterate(d)
    if it !== nothing
        return (Pair(it[1].second["alias"],it[1].second),it[2])
    else
        return nothing
    end
end

function iterate_alias(d::Dict, state)
    it = iterate(d,state)
    if it !== nothing
        return (Pair(it[1].second["alias"],it[1].second),it[2])
    else
        return nothing
    end
end

function Base.iterate(pd::ParamDict{FT}) where {FT}
    if pd.dict_type == "name"
        return Base.iterate(pd.data)
    else
        return iterate_alias(pd.data)
    end
end

function Base.iterate(pd::ParamDict{FT},state) where {FT}
    if pd.dict_type == "name"
        return Base.iterate(pd.data,state)
    else
        return iterate_alias(pd.data,state)
    end
end



log_component!(param_set::ParamDict{FT},names,component) where {FT} = log_component!(param_set.data,names,component,param_set.dict_type)

function log_component!(data::Dict,names,component,dict_type)
    if dict_type == "alias"
        for name in names
            for (key,val) in data
                if name == val["alias"]
                    if ["used_in_components"] in keys(data[key])
                        append!(data[key]["used_in_components"],[String(Symbol(component))])
                    else
                        data[key]["used_in_components"] = [String(Symbol(component))]
                    end
                end
            end
        end
    elseif dict_type == "name"
         for name in names
            for (key,val) in data
                if name == key
                    if ["used_in_components"] in keys(data[key])
                        append!(data[key]["used_in_components"],[String(Symbol(component))])
                    else
                        data[key]["used_in_components"] = [String(Symbol(component))]
                    end
                end
            end
         end
        
    end
end

get_values(param_set::ParamDict{FT}, names) where {FT} = get_values(param_set.data, names, param_set.dict_type)

function get_values(data::Dict, names, dict_type)

    ret_values = []
    if dict_type == "alias"
        for name in names
            for (key,val) in data
                if name == val["alias"]
                    append!(ret_values,val["value"])
                end
            end
        end
    elseif dict_type == "name"
        for name in names
            append!(ret_values,val["value"])
        end
    end
    return ret_values
end

function get_parameter_values!(param_set::ParamDict{FT}, names, component; log_component=true) where {FT}
    names_vec = (typeof(names) <: AbstractVector) ? names : [names]
    
    if log_component
        log_component!(param_set,names_vec,component)
    end
    
    return (typeof(names) <: AbstractVector) ? get_values(param_set,names_vec) : get_values(param_set,names_vec)[1]
end

#as log_component is false, the get_parameter_values! does not change param_set
get_parameter_values(param_set::ParamDict{FT}, names) where {FT} = get_parameter_values!(param_set, names, nothing, log_component=false)


# write a parameter log file to given file. Unfortunately it is unordered thanks to TOML.jl
# can't read in an ordered dict
function write_log_file(param_set::ParamDict{FT}, filepath) where {FT}
    open(filepath, "w") do io
        TOML.print(io, param_set.data)
    end
end

function merge_override_default_values(override_param_struct::ParamDict{FT},default_param_struct::ParamDict{FT}) where {FT}
    merged_struct = deepcopy(default_param_struct)
    for (key, val) in override_param_struct.data
        if ~(key in keys(merged_struct.data))
            merged_struct.data[key] = val
        else
            for (kkey,vval) in val # as val is a Dict too
                merged_struct.data[key][kkey] = vval
            end
        end
    end
    return merged_struct
end


function create_parameter_struct(path_to_override, path_to_default; dict_type="alias")
    #if there isn't  an override file take defaults
    if isnothing(path_to_override)
        return ParamDict{Float64}(parse_toml_file(path_to_default), dict_type)
    else
        try 
            override_param_struct = ParamDict{Float64}(parse_toml_file(path_to_override), dict_type)
            default_param_struct = ParamDict{Float64}(parse_toml_file(path_to_default), dict_type)
        
            #overrides the defaults where they clash
            return merge_override_default_values(override_param_struct, default_param_struct)
        catch
            @warn("Error in building from parameter file: ", path_to_override,"instead, created using defaults from CLIMAParameters...")
            return ParamDict{Float64}(parse_toml_file(path_to_default), dict_type)
        end
    end
        
end



function create_parameter_struct(path_to_override; dict_type="alias")
    #pathof finds the CLIMAParameters.jl/src/ClimaParameters.jl location
    path_to_default = joinpath(splitpath(pathof(CLIMAParameters))[1:end-1]...,"parameters.toml")
    return create_parameter_struct(
        path_to_override,
        path_to_default,
        dict_type=dict_type
    )
end

function create_parameter_struct(; dict_type="alias")
    return create_parameter_struct(
        nothing,
        dict_type=dict_type
    )
end

