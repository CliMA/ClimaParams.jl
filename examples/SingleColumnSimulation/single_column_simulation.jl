using Oceananigans  
using Oceananigans.Units
using SeawaterPolynomials.TEOS10: TEOS10EquationOfState

using Printf

using Oceananigans.TurbulenceClosures.CATKEVerticalDiffusivities:
    CATKEVerticalDiffusivity,
    MixingLength,
    TurbulentKineticEnergy
    
function single_column_simulation(;
    surface_heat_flux = 200,
    surface_momentum_flux = -2e-4,
    ocean_reference_density = 1020,
    ocean_heat_capacity = 3991,
    initial_turbulent_kinetic_energy = -2e-4,
    gravitational_acceleration = 9.81,
    coriolis_parameter = 1e-4,
    stop_time = 8days,
    constant_salinity = 35,
    surface_temperature = 20,
    time_step = 10minutes,
    initial_buoyancy_frequency = 1e-6)

    grid = RectilinearGrid(size=64, z=(-256, 0), topology=(Flat, Flat, Bounded))
    coriolis = FPlane(f=coriolis_parameter)

    ρ₀ = ocean_reference_density
    cₚ = ocean_heat_capacity
    Q = surface_heat_flux
    τˣ = surface_momentum_flux

    Qᵀ = Q / (ρ₀ * cₚ)
    Qᵘ = τˣ / ρ₀

    T_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵀ))
    u_bcs = FieldBoundaryConditions(top = FluxBoundaryCondition(Qᵘ))

    closure = CATKEVerticalDiffusivity()

    equation_of_state = TEOS10EquationOfState(; reference_density)
    buoyancy = SeawaterBuoyancy(; equation_of_state, gravitational_acceleration)

    model = HydrostaticFreeSurfaceModel(; grid, closure, coriolis, buoyancy,
                                        tracers = (:T, :S, :e),
                                        boundary_conditions = (; T=T_bcs, u=u_bcs))
                                        
    # Initial condition
    T₀ = surface_temperature
    S₀ = constant_salinity
    N² = initial_buoyancy_frequency
    α = SeawaterPolynomials.thermal_expansion(T₀, S₀, 0)
    g = gravitational_acceleration

    # N² = α * g * dTdz
    dTdz = N² / (α * g)
    Tᵢ(z) = T₀ + dTdz * z
    Sᵢ(z) = S₀
    set!(model, S=Sᵢ, T=Tᵢ, e=initial_turbulent_kinetic_energy)

    simulation = Simulation(model; Δt=time_step, stop_time)

    outputs = merge(model.velocities, model.tracers)

    simulation.output_writers[:fields] =
        JLD2OutputWriter(model, outputs,
                         schedule = TimeInterval(10minutes),
                         filename = "single_column_simulation.jld2"
                         overwrite_existing = true)

    progress(sim) = @info string("Iter: ", iteration(sim), " t: ", prettytime(sim))
    simulation.callbacks[:progress] = Callback(progress, IterationInterval(100))

    run!(simulation)

    return nothing
end

