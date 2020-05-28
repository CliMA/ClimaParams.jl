#### Types

"""
    AbstractParameterSet

The top-level super-type parameter set.
"""
abstract type AbstractParameterSet end

"""
    AbstractEarthParameterSet <: AbstractParameterSet

An earth parameter set, specific to planet Earth.
"""
abstract type AbstractEarthParameterSet <: AbstractParameterSet end

"""
    AbstractMicrophysicsParameterSet <: AbstractParameterSet

A set of parameters for cloud and precipitation microphysics parameterization.
"""
abstract type AbstractMicrophysicsParameterSet <: AbstractParameterSet end

"""
    AbstractCloudParameterSet  <: AbstractMicrophysicsParameterSet

A set of parameters for cloud microphysics parameterization.
"""
abstract type AbstractCloudParameterSet  <: AbstractMicrophysicsParameterSet end

"""
    AbstractPrecipParameterSet <: AbstractMicrophysicsParameterSet

A set of parameters for precipitation microphysics parameterization.
"""
abstract type AbstractPrecipParameterSet <: AbstractMicrophysicsParameterSet end

"""
    AbstractLiquidParameterSet <: AbstractCloudParameterSet

A set of parameters for cloud liquid water microphysics parameterization.
"""
abstract type AbstractLiquidParameterSet <: AbstractCloudParameterSet end

"""
    AbstractIceParameterSet    <: AbstractCloudParameterSet

A set of parameters for cloud ice microphysics parameterization.
"""
abstract type AbstractIceParameterSet    <: AbstractCloudParameterSet end

"""
    AbstractRainParameterSet   <: AbstractPrecipParameterSet

A set of parameters for rain microphysics parameterization.
"""
abstract type AbstractRainParameterSet   <: AbstractPrecipParameterSet end

"""
    AbstractSnowParameterSet   <: AbstractPrecipParameterSet

A set of parameters for snow microphysics parameterization.
"""
abstract type AbstractSnowParameterSet   <: AbstractPrecipParameterSet end
