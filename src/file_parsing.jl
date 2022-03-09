using TOML

function parse_toml_file(filepath)
    return TOML.parsefile(filepath)
end

struct ParamDict{FT}
    data::Dict
    dict_type::String
    override_dict::Union{Nothing,Dict}
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
    component_key = "used_in"
    if dict_type == "alias"
        for name in names
            for (key,val) in data
                if name == val["alias"]
                    if component_key in keys(data[key])
                        data[key][component_key] = unique([data[key][component_key]...,String(Symbol(component))])
                    else
                        data[key][component_key] = [String(Symbol(component))]
                    end
                end
            end
        end
    elseif dict_type == "name"
         for name in names
            for (key,val) in data
                if name == key
                    if component_key in keys(data[key])
                        data[key][component_key] = unique([data[key][component_key]...,String(Symbol(component))])
                    else
                        data[key][component_key] = [String(Symbol(component))]
                    end
                end
            end
         end
        
    end
end

get_values(param_set::ParamDict{FT}, names) where {FT} =
    get_values(param_set.data, names, param_set.dict_type, get_parametric_type(param_set))

function get_values(data::Dict, names, dict_type, ret_values_type)
    
    ret_values = []
    if dict_type == "alias"
        for name in names
            for (key,val) in data
                if name == val["alias"]
                    param_value = val["value"]
                    if eltype(param_value) != ret_values_type
                        push!(ret_values, map(ret_values_type, param_value))
                    else
                        push!(ret_values, param_value)
                    end
                end
            end
        end
    elseif dict_type == "name"
        for name in names
            param_value = data[name]["value"]
            if eltype(param_value) != ret_values_type
                push!(ret_values, map(ret_values_type, param_value))
            else
                push!(ret_values, param_value)
            end
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


function check_override_parameter_usage(param_set::ParamDict{FT},warn_else_error) where {FT}
    if !(isnothing(param_set.override_dict))
        flag_error = !(warn_else_error == "warn")
        component_key = "used_in" # must agree with key above
        for (key,val) in param_set.override_dict
            logged_val = param_set.data[key]
            if ~(component_key in keys(logged_val)) #as val is a Dict
                    @warn("key " * key * " is present in parameter file, but not used in the simulation. \n Typically this is due to a mismatch in parameter name in toml and in source.")
            end
        end
        if flag_error
            @error("At least one override parameter set and not used in simulation")
            throw(ErrorException("Halting simulation due to unused parameters."
                                 * "\n Typically this is due to a typo in the parameter name."
                                 * "\n change warn_else_error flag to \"warn\" to prevent this causing an exception"))
        end
    end
end

# write a parameter log file to given file. Unfortunately it is unordered thanks to TOML.jl
# can't read in an ordered dict
function write_log_file(param_set::ParamDict{FT}, filepath) where {FT}
    component_key = "used_in"
    used_parameters = Dict()
    for (key,val) in param_set.data
        if ~(component_key in keys(val))
            used_parameters[key] = val
        end
    end
    open(filepath, "w") do io
        TOML.print(io, used_parameters)
    end
end

function log_parameter_information(param_set::ParamDict{FT}, filepath; warn_else_error = "warn") where {FT}
    #[1.] write the parameters to log file
    write_log_file(param_set,filepath)
    #[2.] send warnings or errors if parameters were not used
    check_override_parameter_usage(param_set,warn_else_error)
end

#combines the default data, and dict_type, with the overrides and the retains the override_dict.
function merge_override_default_values(override_param_struct::ParamDict{FT},default_param_struct::ParamDict{FT}) where {FT}
    data = default_param_struct.data
    dict_type = default_param_struct.dict_type
    override_dict = override_param_struct.override_dict
    for (key, val) in override_param_struct.data
        if ~(key in keys(data))
            data[key] = val
        else
            for (kkey,vval) in val # as val is a Dict too
                data[key][kkey] = vval
            end
        end
    end
    return ParamDict{FT}(data, dict_type, override_dict)
end


function create_parameter_struct(path_to_override, path_to_default; dict_type="alias", value_type=Float64)
    #if there isn't  an override file take defaults
    if isnothing(path_to_override)
        return ParamDict{value_type}(parse_toml_file(path_to_default), dict_type, nothing)
    else
        try 
            override_param_struct = ParamDict{value_type}(parse_toml_file(path_to_override), dict_type, parse_toml_file(path_to_override))
            default_param_struct = ParamDict{value_type}(parse_toml_file(path_to_default), dict_type, nothing)
        
            #overrides the defaults where they clash
            return merge_override_default_values(override_param_struct, default_param_struct)
        catch
            @warn("Error in building from parameter file: "*"\n " * path_to_override * " \n instead, created using defaults from CLIMAParameters...")
            return ParamDict{value_type}(parse_toml_file(path_to_default), dict_type, nothing)
        end
    end
        
end



function create_parameter_struct(path_to_override; dict_type="alias", value_type=Float64)
    #pathof finds the CLIMAParameters.jl/src/ClimaParameters.jl location
    path_to_default = joinpath(splitpath(pathof(CLIMAParameters))[1:end-1]...,"parameters.toml")
    return create_parameter_struct(
        path_to_override,
        path_to_default,
        dict_type=dict_type,
        value_type=value_type,
    )
end

function create_parameter_struct(; dict_type="alias", value_type=Float64)
    return create_parameter_struct(
        nothing,
        dict_type=dict_type,
        value_type=value_type,
    )
end

