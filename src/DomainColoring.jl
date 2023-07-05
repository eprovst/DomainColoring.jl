# DomainColoring.jl
#
# Copyright (c) 2023 Evert Provoost. See LICENSE.
#
#
# Provided functionality is partially inspired by
#
#   Wegert, Elias. Visual Complex Functions: An Introduction with
#   Phase Portraits. Birkhäuser Basel, 2012.
#

module DomainColoring

using GLMakie, ColorTypes

export domaincolor, checkerplot


function shadedplot(f, shader, axes=(-1, 1, -1, 1); pixels=(720, 720), kwargs...)
    length(axes) == 1 && (axes = (-axes, axes, -axes, axes))
    length(axes) == 2 && (axes = (-axes[1], axes[1], -axes[2], axes[2]))
    length(pixels) == 1 && (pixels = (pixels,pixels))

    x = range(axes[1], axes[2], length=pixels[1])
    y = range(axes[3], axes[4], length=pixels[2])
    shade = (f, z) -> shader(f(z); kwargs...)
    image(x, y, @. shade(f, x + im*y'); axis=(autolimitaspect=1,));
end


function domaincolor_shader(w; abs=false, logabs=false, grid=false, all=false)
    all && (abs = true; grid = true)
    logabs && (abs = true)

    a = mod(angle(w), 2π)

    # phase color using a custom sweep through CIE Lab space
    c = Lab(12cos(3a - π) + 67, 46cos(a + .4) - 3, 46sin(a + .4) + 16)

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

domaincolor(f, axes=(-1,1,-1,1); kwargs...) = shadedplot(f, domaincolor_shader, axes; kwargs...)


function checkerplot_shader(w; angle=false, abs=false, rect=false, real=false, imag=false)
    # set defaults if no options given
    !(angle || abs || rect || real || imag) && (angle = true; abs = true)
    # rectangual grid
    rect && (real = true; imag = true)

    g = 1.0
    angle && (g *= sin(15Base.angle(w)))
    abs   && (g *= sin(15log(Base.abs(w))))
    real  && (g *= sin(5π*Base.real(w)))
    imag  && (g *= sin(5π*Base.imag(w)))

    return Gray(0.9min(1, sign(g) + 1) + 0.08)
end

checkerplot(f, axes=(-1,1,-1,1); kwargs...) = shadedplot(f, checkerplot_shader, axes; kwargs...)

end
