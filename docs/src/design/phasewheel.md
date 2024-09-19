# Phase Wheel

Creating a perceptually smooth color wheel is in general a difficult
task, and comes with inherent compromises. This document serves to list
the design decisions taken for the phase wheel, which we call Arenberg,
used in our implementation of domain coloring. We carefully selected the
following analytical sweep through CIE L\*a\*b\* space:

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

The main problem in the usually used HSV map is the erratic nature of everything,
creating false detail, making certain parts of the phase look longer than others,
etc. Unlike, HSV our peaks and troughs are equispaced, and smooth.

Lightnesswise the entire range is separated into six equal parts. For usual
data analysis it would be better to minimise the number of oscillations,
however for our purposes the turning points serve as visual anchors dividing
the phase range. Note that some lightness variation is wanted, as our eyes
mainly rely on lightness to discern higher frequency information[^1].

The target color space is sRGB, so adding dips in lightness near its red,
green, and blue primaries buys us more range in additional lightness variation
to show magnitude in more complicated plots. This way we have only slight
clipping in sRGB space when adding the lightness variations used to show
magnitude changes in [`domaincolor`](@ref).

[^1]:
     Kovesi, Peter. (2015). "Good Colour Maps: How to Design Them."
     arXiv:abs/1509.03700.
