module ParameterSets

import TOML

export value, @parameterset

abstract type AbstractParameter end
abstract type AbstractParameterSet end

"""
    inherits_from(ps::AbstractParameterSet)

For defining parameter set inheritance.
"""
function inherits_from(::AbstractParameterSet)
    return nothing
end

"""
    value(ps::AbstractParameterSet, param::AbstractParameter)

The value of the parameter `param` in parameter set `ps`
"""
function value end


function Base.getproperty(ps::AbstractParameterSet, name::Symbol)
    _getproperty(ps, ps, name)
end
function _getproperty(ps::AbstractParameterSet, ::Nothing, name::Symbol)
    error("$(typeof(ps)) does not have a parameter $name")
end

macro parameterset(fileexpr)
    paramsetfile = joinpath(dirname(String(__source__.file)), eval(fileexpr))
    dict = TOML.parsefile(paramsetfile)
    paramsetname = dict["name"]
    ex_getproperty = quote end
    symbols = Symbol[]
    ex = quote
        # ensure we trigger recompilation if the .toml file changes
        include_dependency($paramsetfile)
        struct $(esc(Symbol(paramsetname))) <: AbstractParameterSet
        end
        @inline function $(@__MODULE__)._getproperty(pparamset::AbstractParameterSet, paramset::$(esc(Symbol(paramsetname))), name::Symbol)
            $ex_getproperty
            _getproperty(pparamset, inherits_from(paramset), name)
        end
        function Base.propertynames(paramset::$(esc(Symbol(paramsetname))), private::Bool=false)
            append!($symbols, propertynames(inherits_from(paramset)))
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
            $(@__MODULE__).value(::$(esc(Symbol(paramsetname))), ::$(esc(Symbol(name)))) = $(properties["value"])
        end)
        if haskey(properties, "symbol")
            symbol = Symbol(properties["symbol"])
            push!(symbols, symbol)
            push!(ex_getproperty.args, :(name == $(QuoteNode(symbol)) && return value(paramset, $(esc(Symbol(name)))())))
        end
    end
    ex
end


end # module
