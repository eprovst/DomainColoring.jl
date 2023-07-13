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

"""
    DomainColoring.expandaxes(axes)

Implements the **`axes`** expansion typical of the functions in this
module, additionally normalizes to tuples.

See e.g. [`renderimage`](@ref) for a description of the expansion.
"""
function expandaxes(axes)
    if length(axes) == 1
        return Float64.(tuple(-axes, axes, -axes, axes))
    elseif length(axes) == 2
        return Float64.(tuple(-axes[1], axes[1], -axes[2], axes[2]))
    else
        return Float64.(tuple(axes...))
    end
end

"""
    DomainColoring.renderimage(
        f,
        shader,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

# Arguments

- **`f`** is the complex function to turn into an image.

- **`shader`** is the shader function to compute the image.

- **`axes`** are the limits of the rectangle to render, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided.
"""
function renderimage(
        f,
        shader,
        axes = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

    axes = expandaxes(axes)
    length(pixels) == 1 && (pixels = (pixels, pixels))

    x = range(axes[1], axes[2], length=pixels[1])
    y = range(axes[3], axes[4], length=pixels[2])
    shader(@. f(x + im*y'))
end

"""
    DomainColoring.shadedplot(
        f :: "Complex -> Complex",
        shader :: "Matrix{Complex} -> Image",
        axes = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

Takes a complex function **`f`** and a **`shader`** and produces a Makie
image plot.

For documentation of the remaining arguments see [`renderimage`](@ref).
"""
function shadedplot(
        f,
        shader,
        axes = (-1, 1, -1, 1),
        pixels = (720, 720),
    )

    axes = expandaxes(axes)

    x = range(axes[1], axes[2], length=2)
    y = range(axes[3], axes[4], length=2)
    image(x, y, renderimage(f, shader, axes, pixels);
          axis=(autolimitaspect=1,))
end

"""
    DomainColoring.labsweep(θ)

Maps a phase angle **`θ`** to a color in CIE L\\*a\\*b\\* space by
taking

```math
\\begin{aligned}
      L^* &= 12 \\cos(3\\theta - \\pi) + 67, \\\\
      a^* &= 46 \\cos(\\theta + .4) - 3, \\quad\\text{and} \\\\
      b^* &= 46 \\sin(\\theta + .4) - 16.
  \\end{aligned}
```

See [Phase Wheel](@ref) for more information.
"""
function labsweep(θ)
    θ = mod(θ, 2π)
    Lab(12cos(3θ - π) + 67, 46cos(θ + .4) - 3, 46sin(θ + .4) + 16)
end

"""
    DomainColoring.domaincolorpixelshader(
        w :: Complex;
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

Takes a complex value **`w`** and shades it as in a domain coloring.

For documentation of the remaining arguments see [`domaincolor`](@ref).
"""
function domaincolorpixelshader(
        w;
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

    # user wants full domain coloring
    if all
        abs = true
        grid = true
    end

    # phase color
    c = labsweep(angle(w))

    # add magnitude if requested
    if abs || logabs
        m = Base.abs(w)
        logabs && (m = log(m))
        if isfinite(m)
            c = Lab(c.l + 20mod(m, 1) - 10, c.a, c.b)
        end
    end

    # add integer grid if requested
    if grid
        r, i = reim(w)
        if isfinite(4r) && isfinite(4i)
            it = Base.abs(sin(π*r)*sin(π*i))^0.06
            c = mapc(x -> it*x, c)
        end
    end

    return c
end

"""
    domaincolor(
        f :: "Complex -> Complex",
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

Takes a complex function and produces it's domain coloring as a Makie
image plot.

Red corresponds to phase ``0``, yellow to ``\\frac{\\pi}{3}``, green
to ``\\frac{2\\pi}{3}``, cyan to ``\\pi``, blue to
``\\frac{4\\pi}{3}``, and magenta to ``\\frac{5\\pi}{3}``.

# Arguments

- **`f`** is the complex function to plot.

- **`axes`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

- **`abs`** toggles the plotting of the magnitude as lightness ramps
  between level curves.

- **`logabs`** is similar to `abs` but shows the natural logarithm of
  the magnitude instead. This option takes precedence over `abs`.

- **`grid`** plots points with integer real or imaginary part as black
  dots.

- **`all`** is a shortcut for `abs = true` and `grid = true`.
"""
function domaincolor(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

    shadedplot(f, W -> domaincolorpixelshader.(
                    W; abs, logabs, grid
                  ), axes, pixels)
end

"""
    DomainColoring.pdphaseplotshader(W :: Matrix{Complex})

Shades a matrix **`W`** of complex values as a phase plot using
[ColorCET](https://colorcet.com)'s CBC1 cyclic color map for
protanopic and deuteranopic viewers.

See [pdphaseplot](@ref) for more information.
"""
function pdphaseplotshader(W)
    get(ColorSchemes.cyclic_protanopic_deuteranopic_bwyk_16_96_c31_n256,
        @. mod(-angle(W) / 2π + .5, 1))
end

"""
    pdphaseplot(
        f :: "Complex -> Complex",
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

Takes a complex valued function and produces a phase plot as a Makie
image plot using [ColorCET](https://colorcet.com)'s CBC1 cyclic color
map for protanopic and deuteranopic viewers.

Yellow corresponds to phase ``0``, white to ``\\frac{\\pi}{2}``, blue
to ``\\pi``, and black to ``\\frac{3\\pi}{2}``.

# Arguments

- **`f`** is the complex function to plot.

- **`axes`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.
"""
function pdphaseplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

    shadedplot(f, pdphaseplotshader, axes, pixels)
end

"""
    DomainColoring.tphaseplotshader(W :: Matrix{Complex})

Shades a matrix **`W`** of complex values as a phase plot using
[ColorCET](https://colorcet.com)'s CBTC1 cyclic color map for
titranopic viewers.

See [tphaseplot](@ref) for more information.
"""
function tphaseplotshader(W)
    get(ColorSchemes.cyclic_tritanopic_cwrk_40_100_c20_n256,
        @. mod(-angle(W) / 2π + .5, 1))
end

"""
    tphaseplot(
        f :: "Complex -> Complex",
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

Takes a complex valued function and produces a phase plot as a Makie
image plot using [ColorCET](https://colorcet.com)'s CBTC1 cyclic color
map for titranopic viewers.

Red corresponds to phase ``0``, white to ``\\frac{\\pi}{2}``, cyan to
``\\pi``, and black to ``\\frac{3\\pi}{2}``.

# Arguments

- **`f`** is the complex function to plot.

- **`axes`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.
"""
function tphaseplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
    )

    shadedplot(f, tphaseplotshader, axes, pixels)
end

"""
    DomainColoring.checkerplotpixelshader(
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
function checkerplotpixelshader(
        w;
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    # set defaults if no options given
    if !(real || imag || rect || angle || abs || polar)
        rect = true
    end

    # carthesian checker plot
    if rect
        real = true
        imag = true
    end

    # polar checker plot
    if polar
        angle = true
        abs = true
    end

    g = 1.0
    real  && (g *= sin(5π*Base.real(w)))
    imag  && (g *= sin(5π*Base.imag(w)))
    angle && (g *= sin(16*Base.angle(w)))
    abs   && (g *= sin(5π*log(Base.abs(w))))

    return Gray(0.9min(1, sign(g) + 1) + 0.08)
end

"""
    checkerplot(
        f :: "Complex -> Complex",
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

Takes a complex function and produces a checker plot as a Makie image.

# Arguments

- **`f`** is the complex function to plot.

- **`axes`** are the limits of the rectangle to plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`pixels`** is the number of pixels to compute in, respectively, the
  real and imaginary axis, taking the same for both if only one number
  is provided.

If none of the below options are set, the plot defaults to `rect = true`.

- **`real`** plots black and white stripes orthogonal to the real axis
  at a rate of 5 stripes per unit.

- **`imag`** plots black and white stripes orthogonal to the imaginary
  axis at a rate of 5 stripes per unit.

- **`rect`** is a shortcut for `real = true` and `imag = true`.

- **`phase`** is a shortcut for `angle = true` and `abs = true`.

- **`angle`** plots black and white stripes orthogonal to the phase
  angle at a rate of 32 stripes per full rotation.

- **`abs`** plots black and white stripes at a rate of 5 stripes per
  unit increase of the natural logarithm of the magnitude.

- **`phase`** is a shortcut for `angle = true` and `abs = true`.
"""
function checkerplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    shadedplot(f, W -> checkerplotpixelshader.(
                    W; real, imag, angle, abs
                  ), axes, pixels)
end

end
