using Oceananigans
using CairoMakie

output_filename = "single_column_simulation.jld2"

ut = FieldTimeSeries(output_filename, "u")
vt = FieldTimeSeries(output_filename, "v")
Tt = FieldTimeSeries(output_filename, "T")
et = FieldTimeSeries(output_filename, "e")
times = ut.times

z = znodes(ut)

fig = Figure()
axu = Axis(fig[2, 1], xlabel = "Velocities (m s⁻¹)", ylabel = "z (m)")
axT = Axis(fig[2, 2], xlabel = "Temperature (ᵒC)", ylabel = "z (m)")
axe = Axis(
    fig[2, 3],
    xlabel = "Turbulent kinetic energy (m² s⁻²)",
    ylabel = "z (m)",
)

Nt = length(times)
n = Observable(Nt)

title = @lift string("Single column simulation at ", prettytime(times[$n]))
Label(fig[1, 1:3], title)

un = @lift interior(ut[$n], 1, 1, :)
vn = @lift interior(vt[$n], 1, 1, :)
Tn = @lift interior(Tt[$n], 1, 1, :)
en = @lift interior(et[$n], 1, 1, :)

lines!(axu, un, z, label = "u")
lines!(axu, vn, z, label = "v")
lines!(axT, Tn, z)
lines!(axe, en, z)

xlims!(axu, -0.1, 0.1)
xlims!(axT, 19, 20)
xlims!(axe, -1e-5, 4e-4)

record(fig, "single_column_simulation.mp4", 1:Nt, framerate = 24) do nn
    n[] = nn
end
