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

using GLMakie
import DomainColoring as DC

export domaincolor, checkerplot, pdphaseplot, tphaseplot

"""
    DomainColoringToy.interactiveshadedplot(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (480, 480),
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
"""
function interactiveshadedplot(
        f,
        shader,
        limits = (-1, 1, -1, 1),
        pixels = (480, 480),
    )

    # sanitize input
    pixels == :auto && (pixels = (:auto, :auto))
    length(pixels) == 1 && (pixels = (pixels, pixels))
    limits = DC._expandlimits(limits)

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
    fg, ax = heatmap(xl, lift(reverse, yl), lift(adjoint, img);
                     interpolate=true, axis=(autolimitaspect=1,))

    # set default limits
    xlims!(ax, limits[1], limits[2])
    ylims!(ax, limits[3], limits[4])

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
    lims = ax.finallimits
    res = ax.scene.camera.resolution
    update(lims[], res[])

    # observe updates
    onany(update, lims, res)

    return fg
end

"""
    domaincolor(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
        angle = true,
        abs = false,
        grid = false,
        all = false,
    )

Takes a complex function and produces it's domain coloring as an
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

- **`angle`** toggles coloring of the phase angle. Can also be set to
  either the name of, or a `ColorScheme`, or a function `θ -> Color`.

- **`abs`** toggles the plotting of the natural logarithm of the
  magnitude as lightness ramps between level curves. If set to a number,
  this will be used as base of the logarithm instead, if set to `Inf`,
  zero magnitude will be colored black and poles white. Further granular
  control can be achieved by passing a named tuple with any of the
  parameters `base`, `transform`, or `sigma`. `base` changes the base of
  the logarithm, as before. `transform` is the function applied to the
  magnitude (`m -> log(base, m)` by default), and `sigma` changes the
  rate at which zeros and poles are colored when `base = Inf`.

- **`grid`** plots points with integer real or imaginary part as black
  dots. More complicated arguments can be passed as a named tuple in a
  similar fashion to [`checkerplot`](@ref).

- **`all`** is a shortcut for `abs = true` and `grid = true`.
"""
function domaincolor(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
        angle = true,
        abs = false,
        grid = false,
        all = false,
    )

    # issue warning if everything is inactive
    if Base.all(b -> b isa Bool && !b, [angle, abs, grid, all])
        @warn "angle, abs, and grid are all false, domain coloring will be a constant color."
    end

    interactiveshadedplot(
        f, w -> DC.domaincolorshader(w; angle, abs, grid, all),
        limits, pixels)
end

"""
    pdphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
    )

Takes a complex valued function and produces a phase plot as an
interactive GLMakie plot using [ColorCET](https://colorcet.com)'s CBC1
cyclic color map for protanopic and deuteranopic viewers.

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
"""
function pdphaseplot(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
    )

    interactiveshadedplot(f, DC.pdphaseplotshader, limits, pixels)
end

"""
    tphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
    )

Takes a complex valued function and produces a phase plot as an
interactive GLMakie plot using [ColorCET](https://colorcet.com)'s CBTC1
cyclic color map for titranopic viewers.

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
"""
function tphaseplot(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
    )

    interactiveshadedplot(f, DC.tphaseplotshader, limits, pixels)
end

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
"""
function checkerplot(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (480, 480),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    interactiveshadedplot(f, w -> DC.checkerplotshader(
            w; real, imag, rect, angle, abs, polar
        ), limits, pixels,
    )
end

end
