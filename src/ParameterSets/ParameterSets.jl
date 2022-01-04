module ParameterSets

import TOML

export value, @parameterset

abstract type AbstractParameter end
abstract type AbstractParameterSet end

"""
    inherits_from(ps::AbstractParameterSet)

For defining parameter set inheritance.
"""
function inherits_from end

"""
    value(ps::AbstractParameterSet, param::AbstractParameter)

The value of the parameter `param` in parameter set `ps`
"""
function value end

macro parameterset(fileexpr)
    paramsetfile = joinpath(dirname(String(__source__.file)), eval(fileexpr))
    dict = TOML.parsefile(paramsetfile)
    paramsetname = dict["name"]
    ex = quote
        # ensure we trigger recompilation if the file changes
        include_dependency($paramsetfile)
        struct $(esc(Symbol(paramsetname))) <: AbstractParameterSet
        end
    end
    
    if haskey(dict, "inherits_from")
        push!(ex.args, :(inherits_from(::$(esc(Symbol(paramsetname)))) = $(esc(Symbol(dict["inherits_from"])))))
    end

    paramdict = get(dict, "parameters", Dict{String,Any}())
    for paramfile in get(dict, "parameters_include", Dict{String,Any}())
        paramfile = joinpath(dirname(paramsetfile), paramfile)
        includedict = TOML.parsefile(paramfile)
        merge!(paramdict, includedict)
        push!(ex.args, :(include_dependency($paramfile)))
    end
    
    for (name, properties) in paramdict
        push!(ex.args, quote
            # TODO: define docs
            struct $(esc(Symbol(name))) <: AbstractParameter end
            ParameterSets.value(::$(esc(Symbol(paramsetname))), ::$(esc(Symbol(name)))) = $(properties["value"])
        end)
    end
    ex
end


end # module
