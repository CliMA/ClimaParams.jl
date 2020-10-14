"""
    UniversalFunctions

Universal functions for the surface fluxes module.
"""
module UniversalFunctions

export Pr_0_Businger,
    a_m_Businger,
    a_h_Businger,
    Pr_0_Gryanik,
    a_m_Gryanik,
    a_h_Gryanik,
    b_m_Gryanik,
    b_h_Gryanik,
    Pr_0_Grachev,
    a_m_Grachev,
    a_h_Grachev,
    b_m_Grachev,
    b_h_Grachev,
    c_h_Grachev

#####
##### Businger model
#####

# Reference:
#
#    Nishizawa, S., and Y. Kitamura. "A Surface Flux
#    Scheme Based on the Monin‐Obukhov Similarity for
#    Finite Volume Models." Journal of Advances in
#    Modeling Earth Systems 10.12 (2018): 3159-3175.
#    Appendix A.

# Original work
#
#    Businger, Joost A., et al. "Flux-profile
#    relationships in the atmospheric surface layer."
#    Journal of the atmospheric Sciences 28.2 (1971):
#    181-189.

""" Prandtl number at neutral stratification """
function Pr_0_Businger end
""" coefficient for momentum """
function a_m_Businger end
""" coefficient for heat """
function a_h_Businger end

#####
##### Gryanik model
#####

# Reference
#
#    Gryanik, Vladimir M., et al. "New modified and extended
#    stability functions for the stable boundary layer based
#    on SHEBA and parametrizations of bulk transfer coefficients
#    for climate models." Journal of the Atmospheric Sciences
#    (2020).

""" neutral-limit turbulent Prandtl number """
function Pr_0_Gryanik end
""" empirical coefficient (a) for momentum """
function a_m_Gryanik end
""" empirical coefficient (a) for heat """
function a_h_Gryanik end
""" empirical coefficient (b) for momentum """
function b_m_Gryanik end
""" empirical coefficient (b) for heat """
function b_h_Gryanik end

#####
##### Grachev model
#####

# Reference:
#
#    Grachev, A. A., E. L. Andreas, C. W. Fairall, P. S. Guest, and
#    P. O. G. Persson, 2007a: SHEBA flux–profile relationships in
#    the stable atmospheric boundary layer. Bound.-Layer Meteor.,
#    124, 315–333, https://doi.org/10.1007/s10546-007-9177-6.

""" Prandtl number at neutral stratification """
function Pr_0_Grachev end
""" empirical coefficient (a) for momentum """
function a_m_Grachev end
""" empirical coefficient (a) for heat """
function a_h_Grachev end
""" empirical coefficient (b) for momentum """
function b_m_Grachev end
""" empirical coefficient (b) for heat """
function b_h_Grachev end
""" empirical coefficient (c) for heat """
function c_h_Grachev end

end # module UniversalFunctions
