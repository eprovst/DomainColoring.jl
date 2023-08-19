using CairoMakie, DomainColoring

fig = Figure(resolution=(500, 500), figure_padding=0)
axs = Axis(fig[1, 1])

domaincolor!(axs, z -> im*(z+.1im)^3-1, 2.5, all=true)

hidedecorations!(axs)
tightlimits!(axs)
save("logo.png", fig)