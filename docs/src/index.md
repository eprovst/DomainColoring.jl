# DomainColoring.jl: Smooth Complex Plotting

Welcome to the documentation of the `DomainColoring.jl` package, a small
collection of various ways to plot complex functions, built on
`GLMakie.jl`.

```@raw html
<div align="center">
  <img src="assets/logo.png" width=300 />
</div>
```

Currently the functionality here is focussed on interactive work,
however it should not be too difficult to expose the underlying shading
techniques to other plotting libraries.

The plots implemented here are inspired by the wonderful book by
Wegert[^1], yet using a smooth (technically analytic) curve
through CIE L\*a\*b\* space, yielding a more perceptually uniform
representation of the phase (see [The Phase Wheel](@ref)).

[^1]:
    Wegert, Elias. Visual Complex Functions: An Introduction with Phase
    Portraits. Birkhäuser Basel, 2012.

