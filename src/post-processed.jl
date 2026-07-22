#=
post-processed.jl
    The action of the instability: increasing the Richardson 
    number to a stable state, growth of kinetic energy and 
    destruction of tracer gradients
=#
using Oceananigans, GLMakie, Printf

filenames = [
    "Ri03-pp.jld2",
    "Ri05-pp.jld2",
    "Ri07-pp.jld2",
    "Ri09-pp.jld2",
]

datasets = [FieldDataset(filename; backend=OnDisk()) for filename in filenames]

# Data to plot
fig = Figure(;
    size = (1200, 300),
    fontsize = 18
)

# Plot of logarithm of kinetic energy
ax_KE = Axis(fig[1, 1]; 
    ylabel = L"\ln \text{KE}",
    xlabel = L"t / \text{hr}",
    limits = (nothing, nothing, nothing, nothing)
)

# Plot of the growth rate
ax_σ = Axis(fig[1, 2]; 
    ylabel = L"\sigma / \text{hr}^{-1}",
    xlabel = L"t / \text{hr}",
    limits = (nothing, nothing, nothing, nothing)
)

# Plot of the Richardson number
ax_Ri = Axis(fig[1, 3]; 
    ylabel = L"\text{Ri}_b",
    xlabel = L"t / \text{hr}",
    limits = (nothing, nothing, nothing, nothing)
)


lns = map(enumerate(datasets)) do (i, dataset)
    t = dataset.Rib.times / 3600

    KE = [dataset.KE[n][1] for n in 1:length(t)]
    Rib = [dataset.Rib[n][1] for n in 1:length(t)]
    σ = 0.5 .* diff(log.(KE)) ./ diff(t)

    lines!(ax_KE, t, log.(KE))
    lines!(ax_σ, (t[2:end] .+ t[1:end-1]) ./ 2, σ)
    lines!(ax_Ri, t, Rib)
end


labels = map([0.3, 0.5, 0.7, 0.9]) do Ri
    @sprintf "%.1f" Ri
end
Legend(fig[1, 4], lns, labels, L"\text{Ri}")

save("post-processed_jul22.png", fig; px_per_unit=2)
fig
