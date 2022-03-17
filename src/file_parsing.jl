using TOML
using DocStringExtensions

export ParamDict
export parse_toml_file,
    get_parametric_type,
    iterate_alias,
    log_component!,
    get_values,
    get_parameter_values!,
    get_parameter_values,
    check_override_parameter_usage,
    write_log_file,
    log_parameter_information,
    merge_override_default_values,
    create_parameter_struct
        
    
"""
    ParamDict{FT}

structure to hold information read-in from TOML file, as well as a parametrization type `FT`
# Constructors

    ParamDict(data::Dict, dict_type::String, override_dict::Union{Nothing,Dict})

# Fields

$(DocStringExtensions.FIELDS)

"""
struct ParamDict{FT}
    "dictionary representing a default/merged parameter TOML file"
    data::Dict
    "string to determine how dictionary look-up is performed"
    dict_type::String
    "either a nothing, or a dictionary representing an override parameter TOML file"
    override_dict::Union{Nothing,Dict}
end

"""
    parse_toml_file(filepath)

use a TOML parser to read TOML file at `filepath`.
"""
function parse_toml_file(filepath)
    return TOML.parsefile(filepath)
end

"""
    get_parametric_type(::ParamDict{FT}) where {FT}

obtains the type `FT` from `ParamDict{FT}`.
"""
get_parametric_type(::ParamDict{FT}) where {FT} = FT

"""
    iterate_alias(d::Dict)

An iteration utility to iterate dictionary by alias key.
"""
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


"""
    log_component!(param_set::ParamDict{FT},names,component) where {FT}

Adds a new key,val pair: `("used_in",component)` to each named parameter in `param_set`.
Appends a new val: `component` if "used_in" key exists.
"""
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


"""
    get_values(param_set::ParamDict{FT}, names) where {FT}

gets the `value` of the named parameters.
"""
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

"""
    get_parameter_values!(param_set::ParamDict{FT}, names, component; log_component=true) where {FT}

(Note the `!`) Gets the parameter values, and logs the component (if `log_component=true`) where parameters are used.
"""
function get_parameter_values!(param_set::ParamDict{FT}, names, component; log_component=true) where {FT}
    names_vec = (typeof(names) <: AbstractVector) ? names : [names]
    
    if log_component
        log_component!(param_set,names_vec,component)
    end
    
    return (typeof(names) <: AbstractVector) ? get_values(param_set,names_vec) : get_values(param_set,names_vec)[1]
end

"""
    get_parameter_values(param_set::ParamDict{FT}, names) where {FT}

Gets the parameter values only.
"""
get_parameter_values(param_set::ParamDict{FT}, names) where {FT} = get_parameter_values!(param_set, names, nothing, log_component=false)

"""
    check_override_parameter_usage(param_set::ParamDict{FT},warn_else_error) where {FT}

Checks if parameters in the ParamDict.override_dict have the key "used_in" (i.e. were these parameters used within the model run).
Throws warnings in each where parameters are not used. Also throws an error if `warn_else_error` is not "warn"`. 
"""
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

"""
    write_log_file(param_set::ParamDict{FT}, filepath) where {FT}

Writes a log file of all used parameters of `param_set` at the `filepath`. This file can be used to rerun the experiment.
"""
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


"""
    log_parameter_information(param_set::ParamDict{FT}, filepath; warn_else_error = "warn") where {FT}

Writes the parameter log file at `filepath`; checks that override parameters are all used.
"""
function log_parameter_information(param_set::ParamDict{FT}, filepath; warn_else_error = "warn") where {FT}
    #[1.] write the parameters to log file
    write_log_file(param_set,filepath)
    #[2.] send warnings or errors if parameters were not used
    check_override_parameter_usage(param_set,warn_else_error)
end


"""
    merge_override_default_values(override_param_struct::ParamDict{FT},default_param_struct::ParamDict{FT}) where {FT}

Combines the `default_param_struct` with the `override_param_struct`, precedence is given to override information.
"""
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

"""
    create_parameter_struct(path_to_override, path_to_default; dict_type="alias", value_type=Float64)

Creates a `ParamDict{value_type}` struct, by reading and merging upto two TOML files with override information taking precedence over default information.
"""
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


"""
    create_parameter_struct(path_to_override; dict_type="alias", value_type=Float64)

a single filepath is assumed to be the override file, defaults are obtained from the CLIMAParameters defaults list.
"""
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

"""
    create_parameter_struct(; dict_type="alias", value_type=Float64)

when no filepath is provided, all parameters are created from CLIMAParameters defaults list.
"""
function create_parameter_struct(; dict_type="alias", value_type=Float64)
    return create_parameter_struct(
        nothing,
        dict_type=dict_type,
        value_type=value_type,
    )
end

