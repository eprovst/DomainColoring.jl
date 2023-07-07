# The Phase Wheel

Creating a perceptually uniform color wheel is in general a difficult
task. There has been quite some work by Peter Kovesi on this topic, much
of which is for Julia implemented in his package
[PerceptualColourMaps.jl](https://github.com/peterkovesi/PerceptualColourMaps.jl).

In this library we chose to maximize perceptual uniformity even more (at
the cost at somewhat dull colors) by using a carefully selected
analytical sweep through CIE L\*a\*b\* space

```math
\begin{aligned}
    L^* &= 12 \cos(3\theta - \pi) + 67,\\
    a^* &= 46 \cos(\theta + .4) - 3,\quad\text{and}\\
    b^* &= 46 \sin(\theta + .4) - 16.
\end{aligned}
```

Where we made sure to have only slight clipping in sRGB space when
adding the lightness variations used to show magnitude changes in
[`domaincolor`](@ref).

This is implemented by the internal function [`DomainColoring.labsweep`](@ref), giving
the following phase wheel.
```@example
using DomainColoring, Colors #hide
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false #hide
DomainColoring.labsweep.(0:.01:2π)
```
