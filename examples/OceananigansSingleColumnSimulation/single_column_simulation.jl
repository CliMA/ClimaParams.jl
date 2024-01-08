using Oceananigans  
using Oceananigans.Units
using SeawaterPolynomials
using SeawaterPolynomials.TEOS10: TEOS10EquationOfState
using CLIMAParameters

using Printf

using Oceananigans.TurbulenceClosures.CATKEVerticalDiffusivities:
    CATKEVerticalDiffusivity,
    MixingLength,
    TurbulentKineticEnergyEquation
    
function single_column_simulation(;
    # Grid / domain parameters
    architecture                                       = CPU(),
    Nz                                                 = 64,
    Lz                                                 = 256,
    floating_point_type                                = Float64,
    # Output
    output_fields                                      = (:u, :v, :T, :S, :e),
    output_schedule                                    = TimeInterval(10minutes),
    output_filename                                    = "single_column_simulation.jld2",
    # Boundary conditions
    surface_heat_flux                                  = 200,
    surface_zonal_momentum_flux                        = -0.2,
    surface_meridional_momentum_flux                   = 0.0,
    # Ocean physical parameters
    ocean_reference_density                            = 1020,
    ocean_heat_capacity                                = 3991,
    gravitational_acceleration                         = 9.81,
    coriolis_parameter                                 = 1e-4,
    # CATKE parameters
    catke_surface_distance_coefficient                 = 2.4,
    catke_tracer_convective_mixing_length_coefficient  = 1.5,
    catke_tracer_convective_penetration_coefficient    = 0.2,
    catke_tke_convective_mixing_length_coefficient     = 1.2,
    catke_sheared_convection_coefficient               = 0.14,
    catke_low_Ri_momentum_shear_mixing_coefficient     = 0.19,
    catke_high_Ri_momentum_shear_mixing_coefficient    = 0.086,
    catke_low_Ri_tracer_shear_mixing_coefficient       = 0.2,
    catke_high_Ri_tracer_shear_mixing_coefficient      = 0.045,
    catke_low_Ri_tke_shear_mixing_coefficient          = 1.9,
    catke_high_Ri_tke_shear_mixing_coefficient         = 0.57,
    catke_stability_function_width                     = 0.45,
    catke_stability_function_threshold_Ri              = 0.47,
    catke_low_Ri_dissipation_shear_length_coefficient  = 1.1,
    catke_high_Ri_dissipation_shear_length_coefficient = 0.37,
    catke_dissipation_convective_length_coefficient    = 0.88,
    catke_surface_tke_shear_flux_coefficient           = 1.1,
    catke_surface_tke_convective_flux_coefficient      = 4.0,
    catke_minimum_turbulent_kinetic_energy             = 1e-6,
    # Initial conditions
    initial_salinity                                   = 35,
    initial_surface_temperature                        = 20,
    initial_turbulent_kinetic_energy                   = 1e-6,
    # Simulation parameters
    stop_time                                          = 8days,
    time_step                                          = 10minutes,
    initial_buoyancy_frequency                         = 1e-6)

    # A single colunn grid
    FT = floating_point_type
    grid = RectilinearGrid(architecture, FT, size=Nz, z=(-Lz, 0), topology=(Flat, Flat, Bounded))

    # Surface boundary conditions
    ρ₀ = ocean_reference_density
    cₚ = ocean_heat_capacity
    Q = surface_heat_flux
    τˣ = surface_zonal_momentum_flux
    τʸ = surface_meridional_momentum_flux

    Jᵀ = Q / (ρ₀ * cₚ)
    Jᵘ = τˣ / ρ₀
    Jᵛ = τʸ / ρ₀

    Jᵀ = convert(FT, Jᵀ)
    Jᵘ = convert(FT, Jᵘ)
    Jᵛ = convert(FT, Jᵛ)

    T_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Jᵀ))
    u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Jᵘ))
    v_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Jᵛ))

    # Build CATKE
    catke_mixing_length = MixingLength(
        Cˢ   = catke_surface_distance_coefficient,
        Cᶜc  = catke_tracer_convective_mixing_length_coefficient,
        Cᶜe  = catke_tracer_convective_penetration_coefficient,
        Cᵉc  = catke_tke_convective_mixing_length_coefficient,
        Cˢᵖ  = catke_sheared_convection_coefficient,
        Cˡᵒu = catke_low_Ri_momentum_shear_mixing_coefficient,
        Cʰⁱu = catke_high_Ri_momentum_shear_mixing_coefficient,
        Cˡᵒc = catke_low_Ri_tracer_shear_mixing_coefficient,
        Cʰⁱc = catke_high_Ri_tracer_shear_mixing_coefficient,
        Cˡᵒe = catke_low_Ri_tke_shear_mixing_coefficient,
        Cʰⁱe = catke_high_Ri_tke_shear_mixing_coefficient,
        CRiᵟ = catke_stability_function_width,
        CRi⁰ = catke_stability_function_threshold_Ri,
    ) 

    catke_tke_equation = TurbulentKineticEnergyEquation(
        CˡᵒD = catke_low_Ri_dissipation_shear_length_coefficient,
        CʰⁱD = catke_high_Ri_dissipation_shear_length_coefficient,
        CᶜD  = catke_dissipation_convective_length_coefficient,
        Cᵂu★ = catke_surface_tke_shear_flux_coefficient,
        CᵂwΔ = catke_surface_tke_convective_flux_coefficient,
    )
         
    closure = CATKEVerticalDiffusivity(FT,
                                       minimum_turbulent_kinetic_energy = catke_minimum_turbulent_kinetic_energy,
                                       mixing_length = catke_mixing_length,
                                       turbulent_kinetic_energy_equation = catke_tke_equation)

    coriolis = FPlane(FT, f=coriolis_parameter)
    equation_of_state = TEOS10EquationOfState(FT, ; reference_density=ocean_reference_density)
    buoyancy = SeawaterBuoyancy(FT; equation_of_state, gravitational_acceleration)

    model = HydrostaticFreeSurfaceModel(; grid, closure, coriolis, buoyancy,
                                        tracers = (:T, :S, :e),
                                        boundary_conditions = (; T=T_bcs, u=u_bcs, v=v_bcs))
                                        
    # Initial condition
    T₀ = initial_surface_temperature
    S₀ = initial_salinity
    N² = initial_buoyancy_frequency
    α = SeawaterPolynomials.thermal_expansion(T₀, S₀, 0, equation_of_state)
    g = gravitational_acceleration

    # N² = α * g * dTdz
    dTdz = N² / (α * g)
    Tᵢ(z) = T₀ + dTdz * z
    Sᵢ(z) = S₀
    set!(model, S=Sᵢ, T=Tᵢ, e=initial_turbulent_kinetic_energy)

    simulation = Simulation(model; Δt=time_step, stop_time)

    model_fields = fields(model)
    outputs = NamedTuple(name => model_fields[name] for name in output_fields)

    simulation.output_writers[:fields] = JLD2OutputWriter(model, outputs;
                                                          schedule = output_schedule,
                                                          filename = output_filename,
                                                          overwrite_existing = true)

    progress(sim) = @info string("Iter: ", iteration(sim), " t: ", prettytime(sim))
    simulation.callbacks[:progress] = Callback(progress, IterationInterval(100))

    return simulation
end

