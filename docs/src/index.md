# DomainColoring.jl: Smooth Complex Plotting

Welcome to the documentation of `DomainColoring.jl`, a collection of various
ways to plot complex functions for research, teaching, and fun, supporting
both [Plots.jl](https://docs.juliaplots.org) and [Makie](https://makie.org).

```@raw html
<div align="center">
  <img src="assets/logo.png" width=300 />
</div>
```

In addition to the static plots provided here, interactive versions using
`GLMakie`, and various 3D visualizations, are available as part of the 
[`ComplexToys.jl` package](https://eprovst.github.io/ComplexToys.jl/).

The plots implemented here are inspired by the wonderful book by Wegert[^1], yet
using a smooth curve through Oklab space, yielding a more perceptually uniform
representation of the phase (see [The Arenberg Phase Wheel](@ref)).

[^1]:
    Elias Wegert, _Visual Complex Functions: An Introduction with Phase
    Portraits_ (Basel, 2012).

