using Oceananigans  
using Oceananigans.Units
using SeawaterPolynomials
using SeawaterPolynomials.TEOS10: TEOS10EquationOfState

using Printf

using Oceananigans.TurbulenceClosures.CATKEVerticalDiffusivities:
    CATKEVerticalDiffusivity
    # MixingLength,
    # TurbulentKineticEnergy
    
function single_column_simulation(;
    # Grid / domain parameters
    architecture = CPU(),
    Nz = 64,
    Lz = 256,
    # Output
    output_fields = (:u, :v, :T, :S, :e),
    output_schedule  = TimeInterval(10minutes),
    output_filename  = "single_column_simulation.jld2",
    # Boundary conditions
    surface_heat_flux                = 200,
    surface_momentum_flux            = -0.2,
    # Ocean physical parameters
    ocean_reference_density          = 1020,
    ocean_heat_capacity              = 3991,
    gravitational_acceleration       = 9.81,
    coriolis_parameter               = 1e-4,
    # Initial conditions
    initial_salinity                 = 35,
    initial_surface_temperature      = 20,
    initial_turbulent_kinetic_energy = -2e-4,
    # Simulation parameters
    stop_time                        = 8days,
    time_step                        = 10minutes,
    initial_buoyancy_frequency       = 1e-6)

    grid = RectilinearGrid(architecture, size=Nz, z=(-Lz, 0), topology=(Flat, Flat, Bounded))
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

    equation_of_state = TEOS10EquationOfState(; reference_density=ocean_reference_density)
    buoyancy = SeawaterBuoyancy(; equation_of_state, gravitational_acceleration)

    model = HydrostaticFreeSurfaceModel(; grid, closure, coriolis, buoyancy,
                                        tracers = (:T, :S, :e),
                                        boundary_conditions = (; T=T_bcs, u=u_bcs))
                                        
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

