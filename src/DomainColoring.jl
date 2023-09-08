#==
 = DomainColoring.jl
 =
 = Copyright (c) 2023 Evert Provoost. See LICENSE.
 =
 = Provided functionality is partially inspired by
 =
 =     Wegert, Elias. Visual Complex Functions:
 =       An Introduction with Phase Portraits.
 =       Birkhäuser Basel, 2012.
 =#

module DomainColoring

using Requires

# load relevant backend
include("backends/stub.jl")
function __init__()
    @require MakieCore="20f20a25-4f0e-4fdf-b5d1-57303727442b" include("backends/makie.jl")
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("backends/plots.jl")
end

include("render.jl")
include("shaders.jl")
include("plots.jl")

end
