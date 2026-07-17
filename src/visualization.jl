#=
visualization.jl
    Create a visualization of simulation output
=#
using Oceananigans, GLMakie, Printf

filename = "Ri05.jld2"  # "Ri09.jld2"

# Read simulation data
fds = FieldDataset(filename; backend=OnDisk())
u_fts = fds.u
b_fts = fds.b
c_fts = fds.c 
p = fds.metadata["parameters"]

# Parameters
L = p.L
H = p.H
Nx = p.Nx
Nz = p.Nz

# Prepare coordinates
x_u = xnodes(u_fts)
z_u = znodes(u_fts)

x_b = xnodes(b_fts)
z_b = znodes(b_fts)

x_c = xnodes(c_fts)
z_c = znodes(c_fts)

times = u_fts.times

# Index to plot
n = length(times)

# Data to plot
b₀ = [p.N² * z + p.f * p.S * x for x in x_b, z in z_b]
u = interior(u_fts[n], :, 1, :)
b = interior(b_fts[n], :, 1, :) .+ b₀
# c₀ = [z for z in z_c] 
c = interior(c_fts[n], :, 1, :) #.+ c₀ 

# Time in hours
time_string = let 
    t = times[n] / 3600
    t_str = @sprintf "%.1f" t
    L"t = %$t_str \, \text{hr}"
end

fig = Figure(;
    size = (1200, 500),
    fontsize = 16
)

# Time label
Label(fig[1, 1:2], time_string)

# Plot of the across-front velocity
ax_u = Axis(fig[2, 1]; 
    title = L"u / \text{m}\,\text{s}^{-1}",
    xlabel = L"x / \text{m}",
    ylabel = L"z / \text{m}",
    limits = (0, L, 0, H),  # -H, 0)
    yreversed=true
)

ht_u = heatmap!(ax_u, x_u, z_u, u;
    colormap = :balance,  # ,
    colorrange = (-0.03, 0.03)
)

Colorbar(fig[2, 2], ht_u)

# Exercise 1: plot of the passive tracer
ax_c = Axis(fig[3, 1]; 
    title = L"c",
    xlabel = L"x / \text{m}",
    ylabel = L"z / \text{m}",
    limits = (0, L, 0, H),
    yreversed=true
)

ht_c = heatmap!(ax_c, x_c, z_c, c;
    colormap = :deep  # ,
    # colorrange = (0, 1)
)

Colorbar(fig[3, 2], ht_c)

# Add some black buoyancy contours to each
contour!(ax_u, x_b, z_b, b;
    color = :black,
    levels = range(-2e-5, 2e-5, 20)
)

contour!(ax_c, x_b, z_b, b;
    color = :black,
    levels = range(-2e-5, 2e-5, 20)
)

# Save figure object
save("exercise4-1.png", fig)

# Exercise 2: create video

fig = Figure(;
    size = (1200, 500),
    fontsize = 16
)

# Index
n = Observable(1)

# Get field interior
u = @lift interior(u_fts, :, 1, :, $n)

# Save figure object
N = length(u_fts.times)
record(fig, "../videos/exercise4-2.mp4", 1:N) do i
    n[] = i 
    print("$i / $N\r")
end


