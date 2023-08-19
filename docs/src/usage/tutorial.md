# Basic Tutorial

!!! note
    If you're experienced with Julia and phase plots, this document
    might be fairly basic. Continue to the [General Overview](@ref)
    instead.

## Installation, loading and Makie

`DomainColoring.jl` provides plotting routines for complex functions.
These build on the [Makie](https://makie.org/) plotting library. Makie
supports multiple backends, one of which has to be loaded to display the
resulting plot. There are two main options:

- `GLMakie` for interactive plots, and
- `CairoMakie` for publication quality plots.

In this tutorial we will use `CairoMakie` to provide output for the
documentation, but whilst following along you might want to use
`GLMakie` instead.

To install `DomainColoring.jl` and either of these packages, enter
```
]add DomainColoring GLMakie
```
or
```
]add DomainColoring CairoMakie
```
into the Julia REPL. (To return to the Julia REPL after this, simply
press backspace.)

After installation your session should in general start with either
```julia
using GLMakie, DomainColoring
```
for interactive work, or for publication graphics with
```julia
using CairoMakie, DomainColoring
```

## Plotting our first few phase plots

Julia supports the passing of functions as arguments, even better, it
supports the creation of so called 'anonymous' functions. We can for
instance write the function that maps an argument ``z`` to ``2z + 1`` as
```julia
z -> 2z + 1
```

Let us now see how the phase of this function behaves in the complex
plane. First, if you haven't already, we need to load
`DomainColoring.jl` and an appropriate Makie backend (our suggestion is
`GLMakie` if you're experimenting from the Julia REPL):
```@example
using CairoMakie, DomainColoring
```

Then a simple phase plot can be made using
```@example
using CairoMakie, DomainColoring # hide
domaincolor(z -> 2z + 1)
resize!(current_figure(), 620, 600) #hide
save("simplephaseexample.png", current_figure()) # hide
nothing # hide
```
![](simplephaseexample.png)

As expected we see a zero of multiplicity one at ``-0.5``,
furthermore we see that `domaincolor` defaults to unit axis limits in
each direction.

Something useful to know about phase plots, the order of the colors
tells you more about the thing you are seeing:

- red, green and blue (anticlockwise) is a zero; and
- red, blue and green is a pole.

The number of times you go through these colors gives you the
multiplicity. A pole of multiplicity two gives for instance:
```@example
using CairoMakie, DomainColoring # hide
domaincolor(z -> 1 / z^2)
resize!(current_figure(), 620, 600) #hide
save("simplepoleexample.png", current_figure()) # hide
nothing # hide
```
![](simplepoleexample.png)

We've now looked at poles and zeroes, another interesting effect to see
on a phase plot are
[branch cuts](https://en.wikipedia.org/wiki/Branch_point). Julia's
implementation of the square root has a branch cut on the negative real
axis, as we can see on the following figure.
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sqrt, [-10, 2, -2, 2])
resize!(current_figure(), 620, 250) #hide
save("sqrtexample.png", current_figure()) # hide
nothing # hide
```
![](sqrtexample.png)

There are a couple of things of note here. First, Julia allows us to
simply pass `sqrt`, which here is equivalent to `z -> sqrt(z)`. Second,
`domaincolor` accepts axis limits as an optional second argument
(for those familiar with Julia: any indexable object will work).
Finally, branch cuts give discontinuities in the phase plot (identifying
these is greatly helped by the perceptual uniformity of the
[Phase Wheel](@ref) used).

We conclude by mentioning that you do not always need to specify all
limits explicitly. If you want to take the same limit in all four
directions you can simply pass that number. When you pass a vector with
only two elements, these will be taken symmetric in the real and
imaginary direction respectively. This way we can zoom in on the beauty
of the essential singularity of ``e^\frac{1}{z}``.
```@example
using CairoMakie, DomainColoring # hide
domaincolor(z -> exp(1/z), 0.5)
resize!(current_figure(), 620, 600) #hide
save("essentialsingexample.png", current_figure()) # hide
nothing # hide
```
![](essentialsingexample.png)

## Plotting the `DomainColoring.jl` logo

As a final example, let us show off a few more capabilities of the
[`domaincolor`](@ref) function by plotting the `DomainColoring.jl` logo.

This is a plot of ``f(z) = z^3i - 1`` with level curves of the logarithm
of the magnitude and an integer grid. You can continue by reading the
[General Overview](@ref) to learn more about these and other additional
options, and the other provided plotting function [`checkerplot`](@ref).

```@example
using CairoMakie, DomainColoring # hide
domaincolor(z -> im*z^3-1, 2.5, all=true)
resize!(current_figure(), 620, 600) #hide
save("logoexample.png", current_figure()) # hide
nothing # hide
```
![](logoexample.png)
