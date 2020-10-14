const UF = CLIMAParameters.SurfaceFluxes.UniversalFunctions

UF.Pr_0_Businger(::AbstractEarthParameterSet) = 0.74
UF.a_m_Businger(::AbstractEarthParameterSet) = 4.7
UF.a_h_Businger(::AbstractEarthParameterSet) = 4.7

UF.Pr_0_Gryanik(::AbstractEarthParameterSet) = 0.98
UF.a_m_Gryanik(::AbstractEarthParameterSet) = 5.0
UF.a_h_Gryanik(::AbstractEarthParameterSet) = 5.0
UF.b_m_Gryanik(::AbstractEarthParameterSet) = 0.3
UF.b_h_Gryanik(::AbstractEarthParameterSet) = 0.4

UF.Pr_0_Grachev(::AbstractEarthParameterSet) = 0.98
UF.a_m_Grachev(::AbstractEarthParameterSet) = 5.0
UF.a_h_Grachev(::AbstractEarthParameterSet) = 5.0
UF.b_m_Grachev(ps::AbstractEarthParameterSet) = UF.a_m_Grachev(ps) / 6.5
UF.b_h_Grachev(::AbstractEarthParameterSet) = 5.0
UF.c_h_Grachev(::AbstractEarthParameterSet) = 3.0
