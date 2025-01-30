# The Arenberg Phase Wheel

Creating a perceptually smooth color wheel is in general a difficult
task, and comes with inherent compromises. This document serves to list
the design decisions taken for the phase wheel, which we call Arenberg,
used in our implementation of domain coloring. We carefully selected the
following sweep through CIE L\*a\*b\* space:

```math
\begin{aligned}
    L^* &= 67 - 12 \cos(3\theta),\\
    a^* &= 46 \cos(\theta + .4) - 3,\quad\text{and}\\
    b^* &= 46 \sin(\theta + .4) - 16.
\end{aligned}
```

This is implemented by the internal function [`DomainColoring.arenberg`](@ref),
giving the following phase wheel.
```@example
using DomainColoring, Colors #hide
showable(::MIME"text/plain", ::AbstractVector{C}) where {C<:Colorant} = false #hide
DomainColoring.arenberg.(0:.01:2π)
```

The main issue of the typically used HSV map that we try to prevent here
is the overall variability of the lightness which creates false detail,
making certain parts of the phase look longer than others, etc. Unlike
the HSV map our peaks and troughs are equispaced and of equal height/depth.
Furthermore, the lightness is smooth everywhere.

Lightnesswise the entire range is separated into six equal parts. For
data analysis it would be better to minimise the number of oscillations,
however, for our purposes the turning points serve as visual anchors dividing
the phase range. Note that some lightness variation is wanted, as our eyes
mainly rely on lightness to discern higher frequency information[^1].

The target color space is sRGB, including dips in lightness near its red,
green, and blue primaries buys us more range in additional lightness variation
to show magnitude in more complicated plots. This way we have only slight
clipping in sRGB space when adding the lightness variations used to show
magnitude changes in [`domaincolor`](@ref).

Of course, different contexts require different compromises, hence why
[`domaincolor`](@ref) provides the `color` keyword argument to replace
Arenberg by a color scheme of your choice.

[^1]:
     Peter Kovesi, "Good colour maps: How to design them",
     [arXiv:1509.03700](https://arxiv.org/abs/1509.03700) (2015).
