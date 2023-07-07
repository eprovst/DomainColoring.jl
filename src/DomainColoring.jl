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

using GLMakie, ColorTypes

export domaincolor, checkerplot

"""
    DomainColoring.shadedplot(
        f :: Complex -> Complex,
        shader :: (Complex; kwargs...) -> Color,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        kwargs...
    )

Takes a complex function and a shader and produces a Makie image plot.

# Arguments

**`f`** is the complex function to plot.

**`shader`** is the shader function to compute pixel colors.

**`axes`** are the limits of the rectangle to plot, in the format
`(min Re, max Re, min Im, max Im)`, if one or two numbers are provided
instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

**`pixels`** is the number of pixels to compute in, respectively, the
real and imaginary axis, taking the same for both if only one number is
provided.

The remaining keyword arguments are passed to the **`shader`** function.
"""
function shadedplot(
        f,
        shader,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        kwargs...
    )
    length(axes) == 1 && (axes = (-axes, axes, -axes, axes))
    length(axes) == 2 && (axes = (-axes[1], axes[1], -axes[2], axes[2]))
    length(pixels) == 1 && (pixels = (pixels,pixels))

    x = range(axes[1], axes[2], length=pixels[1])
    y = range(axes[3], axes[4], length=pixels[2])
    shade = (f, z) -> shader(f(z); kwargs...)
    image(x, y, @. shade(f, x + im*y'); axis=(aspect=DataAspect(),));
end

"""
    DomainColoring.labsweep(θ)

Maps a phase angle **`θ`** to a color in CIE L\\*a\\*b\\* space by
taking

```math
\\begin{aligned}
    L^* &= 12 \\cos(3\\theta - \\pi) + 67,\\\\
    a^* &= 46 \\cos(\\theta + .4) - 3,\\quad\\text{and}\\\\
    b^* &= 46 \\sin(\\theta + .4) - 16.
\\end{aligned}
```

See [The Phase Wheel](@ref) for more information.
"""
function labsweep(θ)
    θ = mod(θ, 2π)
    Lab(12cos(3θ - π) + 67, 46cos(θ + .4) - 3, 46sin(θ + .4) + 16)
end

"""
    DomainColoring.domaincolorshader(
        w :: Complex;
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

Takes a complex value **`w`** and shades it as in a domain coloring.

For documentation of the remaining arguments see [`domaincolor`](@ref).
"""
function domaincolorshader(
        w;
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )
    all && (abs = true; grid = true)
    logabs && (abs = true)

    # phase color
    c = labsweep(angle(w))

    # add magnitude if requested
    if abs
        m = Base.abs(w)
        logabs && (m = log(m))
        c = Lab(c.l + 20mod(m, 1) - 10, c.a, c.b)
    end

    # add integer grid if requested
    if grid
        i = Base.abs(sin(π*real(w))*sin(π*imag(w)))^0.06
        c = mapc(x -> i*x, c)
    end

    return c
end

"""
    domaincolor(
        f :: Complex -> Complex,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

Takes a complex function and produces it's domain coloring as a Makie
image plot.

!!! todo
    Document arguments.
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
    shadedplot(f, domaincolorshader, axes; pixels,
               abs, logabs, grid, all)
end


"""
    DomainColoring.checkerplotshader(
        w :: Complex;
        real = true,
        imag = true,
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
        angle = false,
        abs = false,
        polar = false,
    )
    # set defaults if no options given
    if !(angle || abs || polar || real || imag)
        real = true; imag = true
    end
    # polar checker plot
    polar && (angle = true; abs = true)

    g = 1.0
    angle && (g *= sin(15Base.angle(w)))
    abs   && (g *= sin(15log(Base.abs(w))))
    real  && (g *= sin(5π*Base.real(w)))
    imag  && (g *= sin(5π*Base.imag(w)))

    return Gray(0.9min(1, sign(g) + 1) + 0.08)
end

"""
    checkerplot(
        f :: Complex -> Complex,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = true,
        imag = true,
        angle = false,
        abs = false,
        polar = false,
    )

Takes a complex function and produces a checker plot as a Makie image.

!!! todo
    Document arguments.
"""
function checkerplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (720, 720),
        real = false,
        imag = false,
        angle = false,
        abs = false,
        polar = false,
    )
    shadedplot(f, checkerplotshader, axes; pixels,
               real, imag, angle, abs, polar)
end

end
