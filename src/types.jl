#### Types

"""
    AbstractParameterSet

The top-level super-type parameter set.
"""
abstract type AbstractParameterSet end
const APS = AbstractParameterSet

"""
    AbstractEarthParameterSet <: AbstractParameterSet

An earth parameter set, specific to planet Earth.
"""
abstract type AbstractEarthParameterSet <: AbstractParameterSet end
const AEPS = AbstractEarthParameterSet
