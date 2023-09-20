#==
 = DomainColoringToy
 =
 = Copyright (c) 2023 Evert Provoost. See LICENSE.
 =
 = Provided functionality is partially inspired by
 =
 =     Wegert, Elias. Visual Complex Functions:
 =       An Introduction with Phase Portraits.
 =       Birkhäuser Basel, 2012.
 =#

module DomainColoringToy

using Reexport
@reexport using GLMakie
import DomainColoring as DC

"""
    DomainColoringToy.shadedplot(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (480, 480);
        kwargs...
    )

Takes a complex function and a shader and produces a GLMakie plot with
auto updating.

# Arguments

- **`f`** is the complex function to plot.

- **`shader`** is the shader function to compute a pixel.

- **`limits`** are the initial limits of the plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  viewport resolution is used.

Keyword arguments are passed to GLMakie.
"""
function shadedplot(
        f,
        shader,
        limits = (-1, 1, -1, 1),
        pixels = (480, 480);
        kwargs...
    )

    # sanitize input
    pixels == :auto && (pixels = (:auto, :auto))
    length(pixels) == 1 && (pixels = (pixels, pixels))
    limits = DC._expandlimits(limits)

    # parse Makie options
    defaults = Attributes(
        interpolate = true,
        axis = (autolimitaspect = 1,)
    )
    attr = merge(Attributes(; kwargs...), defaults)

    # setup observables to be used by update
    img = Observable(
        # tiny render to catch errors and setup type
        DC.renderimage(f, shader, limits, (2, 2))
    )
    xl = Observable([limits[1], limits[2]])
    yl = Observable([limits[3], limits[4]])

    # setup plot
    # transpose as x and y are swapped in images
    # reverse as y is reversed in images
    plt = heatmap(xl, lift(reverse, yl), lift(adjoint, img);
                  attr...)

    # set default limits
    xlims!(plt.axis, limits[1], limits[2])
    ylims!(plt.axis, limits[3], limits[4])

    # update loop
    function update(lims, res)
        # set render limits to viewport
        axs = (lims.origin[1], lims.origin[1] + lims.widths[1],
               lims.origin[2], lims.origin[2] + lims.widths[2])
        xl[] = [axs[1], axs[2]]
        yl[] = [axs[3], axs[4]]

        # get resolution if needed
        px = map((p, r) -> p == :auto ? ceil(Int, 1.1r) : p,
                 pixels, tuple(res...))

        # render new image reusing buffer if possible
        if size(img.val) != px
            img.val = DC.renderimage(f, shader, axs, px)
        else
            DC.renderimage!(img.val, f, shader, axs)
        end
        notify(img)
    end

    # initial render
    lims = plt.axis.finallimits
    res = plt.axis.scene.camera.resolution
    update(lims[], res[])

    # observe updates
    onany(update, lims, res)

    return plt
end


"""
    DomainColoringToy.@shadedplot(
        basename,
        shaderkwargs,
        shader
    )

Macro emitting an implementation of **`fname`** in a similar fashion to
the other plotting routines in this library, see for instance
[`domaincolor`](@ref).

**`shaderkwargs`** is a named tuple setting keyword arguments used in
the expression **`shader`**. The result of **`shader`** should be a
function `Complex -> Color` and is used to shade the resulting plot.

See the source for examples.
"""
macro shadedplot(fname, shaderkwargs, shader)
    # interpret shaderkwargs as keyword arguments
    skwargs = [Expr(:kw, p...) for
               p in pairs(__module__.eval(shaderkwargs))]

    @eval __module__ begin
        function $fname(
                f :: Function,
                limits = (-1, 1, -1, 1);
                pixels = (480, 480),
                $(skwargs...),
                kwargs...
            )

            DomainColoringToy.shadedplot(
                f, $shader, limits, pixels; kwargs...)
        end
    end
end

export domaincolor

"""
    domaincolor(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
        abs = false,
        grid = false,
        color = true,
        all = false,
        box = nothing,
        kwargs...
    )

Takes a complex function and produces it's domain coloring plot as an
interactive GLMakie plot.

Red corresponds to phase ``0``, yellow to ``\\frac{\\pi}{3}``, green
to ``\\frac{2\\pi}{3}``, cyan to ``\\pi``, blue to
``\\frac{4\\pi}{3}``, and magenta to ``\\frac{5\\pi}{3}``.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  viewport resolution is used.

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
  If set to `:print` a desaturated version of the default is used.

- **`all`** is a shortcut for `abs = true`, `grid = true`, and
  `color = true`.

- **`box`** if set to `(a, b, s)` shades the area where the output is
  within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to the plotting backend.
"""
domaincolor

@shadedplot(domaincolor,
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
        w -> DC.domaincolorshader(w; abs, grid, color, all, box)
    end)

export checkerplot

"""
    checkerplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
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

Takes a complex function and produces a checker plot as an interactive
GLMakie plot.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  viewport resolution is used.

If none of the below options are set, the plot defaults to `rect = true`.

- **`real`** plots black and white stripes orthogonal to the real axis
  at a rate of one stripe per unit increase. If set to a number this
  will be used as width instead.

- **`imag`** plots black and white stripes orthogonal to the imaginary
  axis at a rate of one stripe per unit increase. If set to a number
  this will be used as width instead.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`angle`** plots black and white stripes orthogonal to the phase
  angle at a rate of eight stripes per full rotation. Can be set to an
  integer to specify a different rate.

- **`abs`** plots black and white stripes at a rate of one stripe per
  unit increase of the natural logarithm of the magnitude. If set to
  a number this is used as the base of the logarithm. When set to a
  function, unit increases of its output are used instead.

- **`polar`** is a shortcut for `angle = true` and `abs = true`. Can
  also be set to the basis to use for `abs`, then a suitable rate for
  `angle` will be selected.

- **`box`** if set to `(a, b, s)` shades the area where the output is
  within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

- **`hicontrast`** uses black and white instead of the softer defaults.

Remaining keyword arguments are passed to the plotting backend.
"""
checkerplot

@shadedplot(checkerplot,
    (real = false,
     imag = false,
     rect = false,
     angle = false,
     abs = false,
     polar = false,
     box = nothing,
     hicontrast = false),
    begin
        # set carthesian grid if no options given
        if all(b -> b isa Bool && !b,
               (real, imag, rect, angle, abs, polar))
            rect = true
        end
        w -> DC.checkerplotshader(
            w; real, imag, rect, angle, abs, polar, box, hicontrast
        )
    end)

export sawplot

"""
    sawplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
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

Takes a complex function and produces a saw plot as an interactive
GLMakie plot.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  viewport resolution is used.

If none of the below options are set, the plot defaults to `rect = true`.

- **`real`** plots black to white ramps orthogonal to the real axis at a
  rate of one ramp per unit increase. If set to a number this will be
  used as width instead.

- **`imag`** plots black to white ramps orthogonal to the imaginary axis
  at a rate of one ramp per unit increase. If set to a number this will
  be used as width instead.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`angle`** plots black to white ramps orthogonal to the phase angle
  at a rate of eight ramps per full rotation. Can be set to an integer
  to specify a different rate.

- **`abs`** plots black to white ramps at a rate of one ramp per unit
  increase of the natural logarithm of the magnitude. If set to a number
  this is used as the base of the logarithm. When set to a function,
  unit increases of its output are used instead.

- **`polar`** is a shortcut for `angle = true` and `abs = true`. Can
  also be set to the basis to use for `abs`, then a suitable rate for
  `angle` will be selected.

- **`color`** toggles coloring of the phase angle. Can also be set to
  either the name of, or a `ColorScheme`, or a function `θ -> Color`.
  If set to `:print` a desaturated version of the default is used.

- **`box`** if set to `(a, b, s)` shades the area where the output is
  within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to the plotting backend.
"""
sawplot

@shadedplot(sawplot,
    (real = false,
     imag = false,
     rect = false,
     angle = false,
     abs = false,
     polar = false,
     color = false,
     box = nothing),
    begin
        # set carthesian grid if no options given
        if all(b -> b isa Bool && !b,
               (real, imag, rect, angle, abs, polar))
            rect = true
        end
        w -> DC.sawplotshader(
            w; real, imag, rect, angle, abs, polar, color, box
        )
    end)

export pdphaseplot

"""
    pdphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
        box = nothing,
        kwargs...
    )

Takes a complex valued function and produces a phase plot using
[ColorCET](https://colorcet.com)'s CBC1 cyclic color map for protanopic
and deuteranopic viewers as an interactive GLMakie plot.

Yellow corresponds to phase ``0``, white to ``\\frac{\\pi}{2}``, blue
to ``\\pi``, and black to ``\\frac{3\\pi}{2}``.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  viewport resolution is used.

- **`real`** plots black to white ramps orthogonal to the real axis at a
  rate of one ramp per unit increase. If set to a number this will be
  used as width instead.

- **`imag`** plots black to white ramps orthogonal to the imaginary axis
  at a rate of one ramp per unit increase. If set to a number this will
  be used as width instead.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`angle`** plots black to white ramps orthogonal to the phase angle
  at a rate of eight ramps per full rotation. Can be set to an integer
  to specify a different rate.

- **`abs`** plots black to white ramps at a rate of one ramp per unit
  increase of the natural logarithm of the magnitude. If set to a number
  this is used as the base of the logarithm. When set to a function,
  unit increases of its output are used instead.

- **`polar`** is a shortcut for `angle = true` and `abs = true`. Can
  also be set to the basis to use for `abs`, then a suitable rate for
  `angle` will be selected.

- **`box`** if set to `(a, b, s)` shades the area where the output is
  within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to the plotting backend.
"""
pdphaseplot

@shadedplot(pdphaseplot,
    (real = false,
     imag = false,
     rect = false,
     angle = false,
     abs = false,
     polar = false,
     box = nothing),
    w -> DC.sawplotshader(
        w; real, imag, rect, angle, abs, polar, color=:CBC1, box
    ))

export tphaseplot

"""
    tphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
        box = nothing,
        kwargs...
    )

Takes a complex valued function and produces a phase plot using
[ColorCET](https://colorcet.com)'s CBTC1 cyclic color map for titranopic
viewers as an interactive GLMakie plot.

Red corresponds to phase ``0``, white to ``\\frac{\\pi}{2}``, cyan to
``\\pi``, and black to ``\\frac{3\\pi}{2}``.

# Arguments

- **`f`** is the complex function to plot.

- **`limits`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  viewport resolution is used.

- **`real`** plots black to white ramps orthogonal to the real axis at a
  rate of one ramp per unit increase. If set to a number this will be
  used as width instead.

- **`imag`** plots black to white ramps orthogonal to the imaginary axis
  at a rate of one ramp per unit increase. If set to a number this will
  be used as width instead.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`angle`** plots black to white ramps orthogonal to the phase angle
  at a rate of eight ramps per full rotation. Can be set to an integer
  to specify a different rate.

- **`abs`** plots black to white ramps at a rate of one ramp per unit
  increase of the natural logarithm of the magnitude. If set to a number
  this is used as the base of the logarithm. When set to a function,
  unit increases of its output are used instead.

- **`polar`** is a shortcut for `angle = true` and `abs = true`. Can
  also be set to the basis to use for `abs`, then a suitable rate for
  `angle` will be selected.

- **`box`** if set to `(a, b, s)` shades the area where the output is
  within the box `a` and `b` in the color `s`. Can also be a list of
  multiple boxes.

Remaining keyword arguments are passed to the plotting backend.
"""
tphaseplot

@shadedplot(tphaseplot,
    (real = false,
     imag = false,
     rect = false,
     angle = false,
     abs = false,
     polar = false,
     box = nothing),
    w -> DC.sawplotshader(
        w; real, imag, rect, angle, abs, polar, color=:CBTC1, box
    ))

end
