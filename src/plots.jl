"""
    DomainColoring.@shadedplot(basename, shaderkwargs, shader)

Macro emitting implementations of **`basename`** and **`basename!`** in
a similar fashion to the other plotting routines in this library, see
for instance [`domaincolor`](@ref) and [`domaincolor!`](@ref).

**`shaderkwargs`** is a named tuple setting keyword arguments used in
the expression **`shader`**. The result of **`shader`** should be a
function `Complex -> Color` and is used to shade the resulting plot.

See the source for examples.
"""
macro shadedplot(basename, shaderkwargs, shader)
    modifname = Symbol(basename, '!')
    # interpret sargs as keyword arguments
    skwargs = [Expr(:kw, p...) for
               p in pairs(__module__.eval(shaderkwargs))]

    for (fname, sname, target) in
        ((basename,  :shadedplot,  ()),
         (modifname, :shadedplot!, ()),
         (modifname, :shadedplot!, (:target,)))
        @eval __module__ begin
            function $fname(
                    $(target...),
                    f :: Function,
                    limits = (-1, 1, -1, 1);
                    pixels = (720, 720),
                    $(skwargs...),
                    kwargs...
                )

                DomainColoring.$sname($(target...), f, $shader,
                                      limits, pixels; kwargs...)
            end
        end
    end
end

export domaincolor, domaincolor!

"""
    domaincolor(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        abs = false,
        grid = false,
        color = true,
        all = false,
        box = nothing,
        kwargs...
    )

Takes a complex function and produces it's domain coloring as a Makie
plot.

Red corresponds to phase ``0``, yellow to ``\\frac{\\pi}{3}``, green
to ``\\frac{2\\pi}{3}``, cyan to ``\\pi``, blue to
``\\frac{4\\pi}{3}``, and magenta to ``\\frac{5\\pi}{3}``.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

- **`abs`** toggles the plotting of the natural logarithm of the
  magnitude as lightness ramps between level curves. If set to a number,
  this will be used as base of the logarithm instead, if set to `Inf`,
  zero magnitude will be colored black and poles white. Further granular
  control can be achieved by passing a named tuple with any of the
  parameters `base`, `transform`, or `sigma`. `base` changes the base of
  the logarithm, as before. `transform` is the function applied to the
  magnitude (`m -> log(base, m)` by default), and `sigma` changes the
  rate at which zeros and poles are colored and implies `base = Inf`.

- **`grid`** plots points with integer real or imaginary part as black
  dots. More complicated arguments can be passed as a named tuple in a
  similar fashion to [`checkerplot`](@ref).

- **`color`** toggles coloring of the phase angle. Can also be set to
  either the name of, or a `ColorScheme`, or a function `θ -> Color`.

- **`all`** is a shortcut for `abs = true`, `grid = true`, and
  `color = true`.

- **`box`** if set to `(a, b, s)` shades the area where the the output
  is within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to Makie.
"""
domaincolor, domaincolor!

@shadedplot(
    domaincolor,
    (abs = false,
     grid = false,
     color = true,
     all = false,
     box = nothing),
    begin
        # issue warning if everything is inactive
        if Base.all(b -> b isa Bool && !b, (abs, grid, color, all))
            @warn "angle, abs, and grid are all false, domain coloring will be a constant color."
        end
        w -> domaincolorshader(w; abs, grid, color, all, box)
    end)

export pdphaseplot, pdphaseplot!

"""
    pdphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        box = nothing,
        kwargs...
    )

Takes a complex valued function and produces a phase plot as a Makie
plot using [ColorCET](https://colorcet.com)'s CBC1 cyclic color map for
protanopic and deuteranopic viewers.

Yellow corresponds to phase ``0``, white to ``\\frac{\\pi}{2}``, blue
to ``\\pi``, and black to ``\\frac{3\\pi}{2}``.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

- **`box`** if set to `(a, b, s)` shades the area where the the output
  is within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to Makie.
"""
pdphaseplot, pdphaseplot!

@shadedplot(pdphaseplot,
    (box = nothing,),
    w -> pdphaseplotshader(w; box))

export tphaseplot, tphaseplot!

"""
    tphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        box = nothing,
        kwargs...
    )

Takes a complex valued function and produces a phase plot as a Makie
plot using [ColorCET](https://colorcet.com)'s CBTC1 cyclic color map for
titranopic viewers.

Red corresponds to phase ``0``, white to ``\\frac{\\pi}{2}``, cyan to
``\\pi``, and black to ``\\frac{3\\pi}{2}``.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

- **`box`** if set to `(a, b, s)` shades the area where the the output
  is within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to Makie.
"""
tphaseplot, tphaseplot!

@shadedplot(tphaseplot,
    (box = nothing,),
    w -> tphaseplotshader(w; box))

export checkerplot, checkerplot!

"""
    checkerplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
        box = nothing,
        hicontrast = false,
        kwargs...
    )

Takes a complex function and produces a checker plot as a Makie plot.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

If none of the below options are set, the plot defaults to `rect = true`.
Numbers can be provided instead of booleans to override the default rates.

- **`real`** plots black and white stripes orthogonal to the real axis
  at a rate of one stripe per unit.

- **`imag`** plots black and white stripes orthogonal to the imaginary
  axis at a rate of one stripe per unit.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`angle`** plots black and white stripes orthogonal to the phase
  angle at a rate of six stripes per full rotation.

- **`abs`** plots black and white stripes at a rate of one stripe per
  unit increase of the natural logarithm of the magnitude.

- **`phase`** is a shortcut for `angle = true` and `abs = true`.

- **`box`** if set to `(a, b, s)` shades the area where the the output
  is within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

- **`hicontrast`** uses black and white instead of the softer defaults.

Remaining keyword arguments are passed to Makie.
"""
checkerplot, checkerplot!

@shadedplot(checkerplot,
    (real = false,
     imag = false,
     rect = false,
     angle = false,
     abs = false,
     polar = false,
     box = nothing,
     hicontrast = false),
    w -> checkerplotshader(
        w; real, imag, rect, angle, abs, polar, box, hicontrast
    ))

export sawplot, sawplot!

"""
    sawplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
        color = false,
        box = nothing,
        kwargs...
    )

Takes a complex function and produces a saw plot as a Makie plot.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

If none of the below options are set, the plot defaults to `rect = true`.
Numbers can be provided instead of booleans to override the default rates.

- **`real`** plots black to white ramps orthogonal to the real axis at a
  rate of one ramp per unit.

- **`imag`** plots black to white ramps orthogonal to the imaginary axis
  at a rate of one ramp per unit.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`angle`** plots black to white ramps orthogonal to the phase angle
  at a rate of six ramps per full rotation.

- **`abs`** plots black to white ramps at a rate of one ramp per unit
  increase of the natural logarithm of the magnitude.

- **`phase`** is a shortcut for `angle = true` and `abs = true`.

- **`color`** toggles coloring of the phase angle. Can also be set to
  either the name of, or a `ColorScheme`, or a function `θ -> Color`.

- **`box`** if set to `(a, b, s)` shades the area where the the output
  is within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to Makie.
"""
sawplot, sawplot!

@shadedplot(sawplot,
    (real = false,
     imag = false,
     rect = false,
     angle = false,
     abs = false,
     polar = false,
     color = false,
     box = nothing),
    w -> sawplotshader(
        w; real, imag, rect, angle, abs, polar, color, box
    ))
