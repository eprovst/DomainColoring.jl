# General Overview

!!! note
    `DomainColoring.jl` provides plots on top of the
    [Makie](https://makie.org) framework, thus a user will have to
    additionally install and load a Makie backend such as `CairoMakie`
    or `GLMakie`.

## Common options

All plotting functions require a function ``\mathbb{C} \to \mathbb{C}``
as first argument and accept optionally axis limits as a second.

If no limits are provided by default unit length is taken in all four
directions. If a list of two numbers is provided the first is used as
both limit in the real direction and the second in the imaginary
direction. A list of four elements are interpreted as
``({\rm Re}_{\rm min}, {\rm Re}_{\rm max}, {\rm Im}_{\rm min},
{\rm Im}_{\rm max})``.

Finally all plots have a keyword argument `pixels` by which one can
specify the number of samples in respectively the real and imaginary
direction. If only one number is provided it is used for both.

The remainder of this page gives a quick overview of the main plotting
functions of `DomainColoring.jl`.

## The [`domaincolor`](@ref) function

!!! note
    The phase output of [`domaincolor`](@ref) is generally not suited
    for those with color vision deficiency, refer to [Plotting for Color
    Vision Deficiency](@ref) instead.

By default [`domaincolor`](@ref) produces a phase plot such as the
following.
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sinc, (3, 1.5))
save("dcsincphase.png", current_figure()) # hide
nothing # hide
```
![](dcsincphase.png)

One can additionally superimpose contour lines of the magnitude as
sweeps of increasing lightness by setting `abs = true`. Where this
increase of lightness is taken proportional to the fractional part of
``\log|f(z)|``.
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sinc, (3, 1.5), abs=true)
save("dcsincabs.png", current_figure()) # hide
nothing # hide
```
![](dcsincabs.png)

Finally, one can also add a dark grid where the imaginary or real part
of ``f(z)`` is integer by setting `grid = true`.
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sinc, (3, 1.5), grid=true)
save("dcsincgrid.png", current_figure()) # hide
nothing # hide
```
![](dcsincgrid.png)

Of course these options can be combined, the common combination of
`abs = true` and `grid = true` even has an abbreviation `all = true`.
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sinc, (3, 1.5), all=true)
save("dcsincall.png", current_figure()) # hide
nothing # hide
```
![](dcsincall.png)

The argument interface contains many further options, but we will delay
their discussion until after introducing the [`checkerplot`](@ref)
function.

## The [`checkerplot`](@ref) function

A checker plot shows limited information and is useful to detect
patterns in certain contexts. By default a checker board pattern is used
with one stripe for an unit increase in either direction. A
checkerplot of the identity function makes this clearer.
```@example
using CairoMakie, DomainColoring # hide
checkerplot(z -> z, 5)
save("cprect.png", current_figure()) # hide
nothing # hide
```
![](cprect.png)

You can limit the stripes to only show increase in the real or imaginary
part by setting `real = true` or `imag = true`, respectively. Again the
previous example.
```@example
using CairoMakie, DomainColoring # hide
checkerplot(z -> z, 5, real=true)
save("cpreal.png", current_figure()) # hide
nothing # hide
```
![](cpreal.png)

Setting `real = true` and `imag = true` can be abbreviated to
`rect = true`, which is identical to the default behaviour.

Alternatively one can also display a polar grid by setting
`polar = true`, giving one band per unit increase of ``\log|f(z)|`` and
six bands per ``2\pi`` increase of ``\arg(f(z))``.
```@example
using CairoMakie, DomainColoring # hide
checkerplot(z -> z, 5, polar=true)
save("cppolar.png", current_figure()) # hide
nothing # hide
```
![](cppolar.png)

As with `rect = true`, `polar = true` is an abbreviation for
`abs = true` and `angle = true`, showing magnitude and phase
respectively. Now is a good time to mention that most arguments
discussed so far also accept numbers, modifying the rate of the stripes.
For example, we get for magnitude:
```@example
using CairoMakie, DomainColoring # hide
checkerplot(z -> z, 5, abs=5)
save("cpabs.png", current_figure()) # hide
nothing # hide
```
![](cpabs.png)
and for phase:
```@example
using CairoMakie, DomainColoring # hide
checkerplot(z -> z, 5, angle=10)
save("cpangle.png", current_figure()) # hide
nothing # hide
```
![](cpangle.png)

Note, that for the latter we need to provide an even number. If we set
`phase` to a number, this will be used for `abs` and a suitable integer
rate will be chosen for `angle`, for instance:
```@example
using CairoMakie, DomainColoring # hide
checkerplot(sin, (5, 2), polar=4)
save("cppolarsin.png", current_figure()) # hide
nothing # hide
```
![](cppolarsin.png)

## The [`domaincolor`](@ref) function, revisited

Like [`checkerplot`](@ref), `abs` and `grid` also accept numbers.
Respectively, changing the basis of the used logarithm and the rate of
the grid. Additionally, we can pass named tuples to open up even more
options.

For `grid` these options are identical to `checkerplot`, for example an
analogous example to the final one of last section, is given by:
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sin, (5, 2), grid=(polar=4,))
save("dcpolarsin.png", current_figure()) # hide
nothing # hide
```
![](dcpolarsin.png)
(Note: unlike before, the rate of `angle` need not be even for grids.)

The `abs` argument accepts a different basis from the default ``e``, if
we for instance wanted to see orders of magnitude, we could look at:
```@example
using CairoMakie, DomainColoring # hide
domaincolor(z -> z^3, 5, abs=10)
save("dcordermag.png", current_figure()) # hide
nothing # hide
```
![](dcordermag.png)

If one does not want to look at the logarithm of the magnitude, but the
magnitude itself, they can use the `transform` option, or pass a
function directly to `abs`, for instance:
```@example
using CairoMakie, DomainColoring # hide
domaincolor(sqrt, (-1, 20, -5, 5), abs=z->z)
save("dclinmag.png", current_figure()) # hide
nothing # hide
```
![](dclinmag.png)

Finally, if we set the base to `Inf`, the magnitude is colored from
black at zero to white at infinity, which we can use to illustrate the
Casorati–Weierstrass theorem:
```@example
using CairoMakie, DomainColoring # hide
domaincolor(z -> exp(1/z), .1, abs=Inf)
save("cwthm.png", current_figure()) # hide
nothing # hide
```
![](cwthm.png)

The harshness of these white an black areas can be changed using the
`sigma` parameter, try for instance:
```julia
domaincolor(z -> exp(1/z), .1, abs=(sigma=0.001,))
```

If one wants to change the coloring of the phase angle, they can pass a
`ColorScheme` (as an object or by name, see [their
documentation](https://juliagraphics.github.io/ColorSchemes.jl/stable/catalogue/))
or a function `θ -> Color`, to `angle`. As an example of the latter, we
can add a discretization effect:
```@example
using CairoMakie, DomainColoring # hide
discrangle(θ) = DomainColoring.labsweep(π/10 * floor(10/π * θ))
domaincolor(tan, angle=discrangle)
save("dscangle.png", current_figure()) # hide
nothing # hide
```
![](dscangle.png)

Finally, if no coloring of the phase is wanted, we can set
`angle = false`.
