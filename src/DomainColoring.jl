#==
 = DomainColoring.jl
 =
 = Copyright (c) 2023 Evert Provoost. See LICENSE.
 =
 = Provided functionality is partially inspired by
 =
 =     Wegert, Elias. Visual Complex Functions:
 =       An Introduction with Phase Portraits.
 =       Birkhäuser Basel, 2012.
 =#

module DomainColoring

using MakieCore, ColorTypes, ColorSchemes

export domaincolor, checkerplot, pdphaseplot, tphaseplot

# Implements the `limits` expansion typical of the functions in this
# module, additionally normalizes to tuples.
function _expandlimits(limits)
    if length(limits) == 1
        return Float64.(tuple(-limits, limits, -limits, limits))
    elseif length(limits) == 2
        return Float64.(tuple(-limits[1], limits[1], -limits[2], limits[2]))
    else
        return Float64.(Tuple(limits))
    end
end

"""
    DomainColoring.renderimage!(
        out :: Matrix{<: Color},
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
    )

# Arguments

- **`out`** is the output image buffer.

- **`f`** is the complex function to turn into an image.

- **`shader`** is the shader function to compute a pixel.

- **`limits`** are the limits of the rectangle to render, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.
"""
function renderimage!(
        img,
        f,
        shader,
        limits = (-1, 1, -1, 1),
    )

    limits = _expandlimits(limits)
    r = range(limits[1], limits[2], length=size(img, 2))
    i = range(limits[4], limits[3], length=size(img, 1))
    broadcast!((r, i) -> shader(f(r + im*i)), img, r', i)
end

"""
    DomainColoring.renderimage(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

# Arguments

- **`f`** is the complex function to turn into an image.

- **`shader`** is the shader function to compute a pixel.

- **`limits`** are the limits of the rectangle to render, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided.
"""
function renderimage(
        f,
        shader,
        limits = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

    length(pixels) == 1 && (pixels = (pixels, pixels))
    img = Matrix{RGB{Float64}}(undef, pixels[1], pixels[2])
    renderimage!(img, f, shader, limits)
    return img
end

"""
    DomainColoring.shadedplot(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

Takes a complex function **`f`** and a **`shader`** and produces a Makie
plot.

For documentation of the remaining arguments see [`renderimage`](@ref).
"""
function shadedplot(
        f,
        shader,
        limits = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

    limits = _expandlimits(limits)

    # images have inverted y and flip x and y in their storage
    r = [limits[1], limits[2]]
    i = [limits[4], limits[3]]
    heatmap(r, i, renderimage(f, shader, limits, pixels)';
            interpolate=true, axis=(autolimitaspect=1,),)
end

"""
    DomainColoring.labsweep(θ)

Maps a phase angle **`θ`** to a color in CIE L\\*a\\*b\\* space by
taking

```math
\\begin{aligned}
      L^* &= 67 - 12 \\cos(3\\theta), \\\\
      a^* &= 46 \\cos(\\theta + .4) - 3, \\quad\\text{and} \\\\
      b^* &= 46 \\sin(\\theta + .4) - 16.
  \\end{aligned}
```

See [Phase Wheel](@ref) for more information.
"""
function labsweep(θ)
    θ = mod(θ, 2π)
    Lab(67 - 12cos(3θ),
        46cos(θ + .4) - 3,
        46sin(θ + .4) + 16)
end

# Grid types supported by _grid
@enum GridType begin
    CheckerGrid
    LineGrid
end

# Logic for grid like plotting elements, somewhat ugly, but it works.
# `w` is the complex value, `type` is the type of grid to make
# `checkerplot`.
function _grid(
        type,
        w;
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    # set carthesian grid if no options given
    if all(b -> b isa Bool && !b,
           [real, imag, rect, angle, abs, polar])
        rect = true
    end

    # carthesian checker plot
    if rect isa Bool
        if rect
            real = true
            imag = true
        end
    elseif length(rect) > 1
        real = rect[1]
        imag = rect[2]
    else
        real = rect
        imag = rect
    end

    # polar checker plot
    if polar isa Bool
        if polar
            angle = true
            abs = true
        end
    elseif length(polar) > 1
        angle = polar[1]
        abs = polar[2]
    else
        angle = 2round(π*polar)
        abs = polar
    end

    # set defaults
    (real  isa Bool && real)  && (real = 1)
    (imag  isa Bool && imag)  && (imag = 1)
    (angle isa Bool && angle) && (angle = 6)
    (abs   isa Bool && abs)   && (abs = 1)

    g = 1.0
    if real > 0
        r = real * π * Base.real(w)
        isfinite(r) && (g *= sin(r))
    end
    if imag > 0
        i = imag * π * Base.imag(w)
        isfinite(i) && (g *= sin(i))
    end
    if angle > 0
        @assert mod(angle, 1) ≈ 0 "Rate of angle has to be an integer."
        angle = round(angle)
        (type == CheckerGrid) && @assert iseven(angle) "Rate of angle has to be even."

        a = angle / 2 * Base.angle(w)
        isfinite(a) && (g *= sin(a))
    end
    if abs > 0
        m = abs * π * log(Base.abs(w))
        isfinite(m) && (g *= sin(m))
    end

    if type == CheckerGrid
        float(g > 0)
    elseif type == LineGrid
        Base.abs(g)^0.06
    end
end

_grid(type, w, args::NamedTuple) = _grid(type, w; args...)

_grid(type, w, arg::Bool) = arg ? _grid(type, w) : 1.0

_grid(type, w, arg) = _grid(type, w; rect=arg)

# Implements the angle coloring logic for shaders.
_color_angle(w, arg::Bool) = arg ? labsweep(angle(w)) : Lab(80.0, 0.0, 0.0)

_color_angle(w, arg::Function) = arg(mod(angle(w), 2π))

_color_angle(w, arg::ColorScheme) = get(arg, mod(angle(w) / 2π, 1))

_color_angle(w, arg::Symbol) = _color_angle(w, ColorSchemes.colorschemes[arg])

# Implements the magnitude logic for `domaincolorshader`
# isnothing(transform) gives the default log, and saves us
# from compiling an anonymous function each call. See `domaincolor`
# for further argument description.
function _add_magnitude(
        w,
        c;
        base = ℯ,
        transform = nothing,
        sigma = nothing,
    )

    # add magnitude if requested
    if base > 0
        if isfinite(base) && isnothing(sigma)
            if isnothing(transform)
                m = log(base, abs(w))
            else
                m = transform(abs(w))
            end
            isfinite(m) && (c = Lab(c.l + 20mod(m, 1) - 10, c.a, c.b))
        else
            isnothing(sigma) && (sigma = 0.02)
            m = log(abs(w))
            t = isfinite(m) ? exp(-sigma*m^2) : 0.0
            g = 100.0(m > 0)
            c = Lab((1 - t)g + t*c.l, t*c.a, t*c.b)
        end
    end
    return c
end

_add_magnitude(w, c, args::NamedTuple) = _add_magnitude(w, c; args...)

_add_magnitude(w, c, arg::Bool) = arg ? _add_magnitude(w, c) : c

_add_magnitude(w, c, arg::Function) = _add_magnitude(w, c; transform=arg)

_add_magnitude(w, c, arg) = _add_magnitude(w, c; base=arg)

"""
    DomainColoring.domaincolorshader(
        w :: Complex;
        angle = true,
        abs = false,
        grid = false,
        all = false,
    )

Takes a complex value **`w`** and shades it as in a domain coloring.

For documentation of the remaining arguments see [`domaincolor`](@ref).
"""
function domaincolorshader(
        w;
        angle = true,
        abs = false,
        grid = false,
        all = false,
    )

    # user wants full domain coloring
    if all
        (angle isa Bool) && (angle = true)
        (abs   isa Bool) && (abs   = true)
        (grid  isa Bool) && (grid  = true)
    end

    # short circuit conversions
    if (abs isa Bool) && !abs && (grid isa Bool) && !grid
        return _color_angle(w, angle)
    end

    # phase color
    c = convert(Lab, _color_angle(w, angle))

    # add magnitude
    c = _add_magnitude(w, c, abs)

    # add integer grid if requested
    if !(grid isa Bool) || grid
        # slightly overattenuate to compensate global darkening
        g = 1.06_grid(LineGrid, w, grid)
        c = mapc(x -> g*x, c)
    end

    return c
end

"""
    domaincolor(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        angle = true,
        abs = false,
        grid = false,
        all = false,
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
  rate at which zeros and poles are colored and implies `base = Inf`.

- **`grid`** plots points with integer real or imaginary part as black
  dots. More complicated arguments can be passed as a named tuple in a
  similar fashion to [`checkerplot`](@ref).

- **`all`** is a shortcut for `abs = true` and `grid = true`.
"""
function domaincolor(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        angle = true,
        abs = false,
        grid = false,
        all = false,
    )

    # issue warning if everything is inactive
    if Base.all(b -> b isa Bool && !b, [angle, abs, grid, all])
        @warn "angle, abs, and grid are all false, domain coloring will be a constant color."
    end

    shadedplot(f, w -> domaincolorshader(
                    w; angle, abs, grid, all
                  ), limits, pixels)
end

"""
    DomainColoring.pdphaseplotshader(w :: Complex)

Shades a complex value **`w`** as a phase plot using
[ColorCET](https://colorcet.com)'s CBC1 cyclic color map for
protanopic and deuteranopic viewers.

See [`pdphaseplot`](@ref) for more information.
"""
function pdphaseplotshader(w)
    get(ColorSchemes.cyclic_protanopic_deuteranopic_bwyk_16_96_c31_n256,
        mod(-angle(w) / 2π + .5, 1))
end

"""
    pdphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
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
"""
function pdphaseplot(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

    shadedplot(f, pdphaseplotshader, limits, pixels)
end

"""
    DomainColoring.tphaseplotshader(w :: Complex)

Shades a complex value **`w`** as a phase plot using
[ColorCET](https://colorcet.com)'s CBTC1 cyclic color map for
titranopic viewers.

See [`tphaseplot`](@ref) for more information.
"""
function tphaseplotshader(w)
    get(ColorSchemes.cyclic_tritanopic_cwrk_40_100_c20_n256,
        mod(-angle(w) / 2π + .5, 1))
end

"""
    tphaseplot(
        f :: "Complex -> Complex",
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
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
"""
function tphaseplot(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

    shadedplot(f, tphaseplotshader, limits, pixels)
end

"""
    DomainColoring.checkerplotshader(
        w :: Complex;
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

Takes a complex value **`w`** and shades it as in a checker plot.

For documentation of the remaining arguments see [`checkerplot`](@ref).
"""
function checkerplotshader(
        w;
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    g = _grid(CheckerGrid, w; real, imag, rect, angle, abs, polar)
    return Gray(0.9g + 0.08)
end

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
"""
function checkerplot(
        f,
        limits = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    shadedplot(f, w -> checkerplotshader(
                    w; real, imag, rect, angle, abs, polar
                  ), limits, pixels)
end

end
