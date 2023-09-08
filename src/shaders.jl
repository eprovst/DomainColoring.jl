using ColorTypes, ColorSchemes

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
    SawGrid
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
           (real, imag, rect, angle, abs, polar))
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

    # set the transform
    saw(x) = mod(x, 1)
    if type == SawGrid
        trf = saw
    else
        trf = sinpi
    end

    g = 1.0
    if real > 0
        r = real * Base.real(w)
        isfinite(r) && (g *= trf(r))
    end
    if imag > 0
        i = imag * Base.imag(w)
        isfinite(i) && (g *= trf(i))
    end
    if angle > 0
        @assert mod(angle, 1) ≈ 0 "Rate of angle has to be an integer."
        angle = round(angle)
        (type == CheckerGrid) && @assert iseven(angle) "Rate of angle has to be even."

        a = angle * Base.angle(w) / 2π
        isfinite(a) && (g *= trf(a))
    end
    if abs > 0
        m = abs * log(Base.abs(w))
        isfinite(m) && (g *= trf(m))
    end

    if type == CheckerGrid
        float(g > 0)
    elseif type == LineGrid
        Base.abs(g)^0.06
    else
        g
    end
end

_grid(type, w, args::NamedTuple) = _grid(type, w; args...)

_grid(type, w, arg::Bool) = arg ? _grid(type, w) : 1.0

_grid(type, w, arg) = _grid(type, w; rect=arg)

# Implements the angle coloring logic for shaders.
_color_angle(w, arg::Bool) = arg ? labsweep(angle(w)) : Lab(80.0, 0.0, 0.0)

_color_angle(w, arg::Function) = arg(mod(angle(w), 2π))

_color_angle(w, arg::ColorScheme) = get(arg, mod(angle(w) / 2π, 1))

function _color_angle(w, arg::Symbol)
    if arg == :CBC1 || arg == :pd
      get(ColorSchemes.cyclic_protanopic_deuteranopic_bwyk_16_96_c31_n256,
          mod(-angle(w) / 2π + .5, 1))
    elseif arg == :CBTC1 || arg == :t
      get(ColorSchemes.cyclic_tritanopic_cwrk_40_100_c20_n256,
          mod(-angle(w) / 2π + .5, 1))
    else
      _color_angle(w, ColorSchemes.colorschemes[arg])
    end
end

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

# draw a colored box in a specified area
function _add_box(w, c, sqs)
    if isnothing(sqs)
        return c
    end

    for sq in sqs
        c = _add_box(w, c, sq)
    end
    return c
end

function _add_box(w, c::C, sq::Tuple{<:Any, <:Any, <:Color}) where C <: Color
    a, b, s = sq
    r, i = reim(w)
    mr, Mr = minmax(real(a), real(b))
    mi, Mi = minmax(imag(a), imag(b))
    (mr <= r <= Mr) && (mi <= i <= Mi) ? convert(C, s) : c
end

function _add_box(w, c::C, sq::Tuple{<:Any, <:Any, <:Any}) where C <: Color
    a, b, s = sq
    _add_box(w, c, (a, b, parse(C, s)))
end

"""
    DomainColoring.domaincolorshader(
        w :: Complex;
        abs = false,
        grid = false,
        color = true,
        all = false,
        box = nothing,
    )

Takes a complex value **`w`** and shades it as in a domain coloring.

For documentation of the remaining arguments see [`domaincolor`](@ref).
"""
function domaincolorshader(
        w;
        abs = false,
        grid = false,
        color = true,
        all = false,
        box = nothing,
    )

    # user wants full domain coloring
    if all
        (abs   isa Bool) && (abs   = true)
        (grid  isa Bool) && (grid  = true)
        (color isa Bool) && (color = true)
    end

    # short circuit conversions
    if (abs isa Bool) && !abs && (grid isa Bool) && !grid
        return _add_box(w, _color_angle(w, color), box)
    end

    # phase color
    c = convert(Lab, _color_angle(w, color))

    # add magnitude
    c = _add_magnitude(w, c, abs)

    # add integer grid if requested
    if !(grid isa Bool) || grid
        # slightly overattenuate to compensate global darkening
        g = 1.06_grid(LineGrid, w, grid)
        c = mapc(x -> g*x, c)
    end

    # add boxs
    c = _add_box(w, c, box)

    return c
end

"""
    DomainColoring.pdphaseplotshader(
        w :: Complex;
        box = nothing,
    )

Shades a complex value **`w`** as a phase plot using
[ColorCET](https://colorcet.com)'s CBC1 cyclic color map for
protanopic and deuteranopic viewers.

See [`pdphaseplot`](@ref) for more information.
"""
function pdphaseplotshader(
        w;
        box = nothing,
    )

    _add_box(w, _color_angle(w, :CBC1), box)
end

"""
    DomainColoring.tphaseplotshader(
        w :: Complex;
        box = nothing,
    )

Shades a complex value **`w`** as a phase plot using
[ColorCET](https://colorcet.com)'s CBTC1 cyclic color map for
titranopic viewers.

See [`tphaseplot`](@ref) for more information.
"""
function tphaseplotshader(
        w;
        box = nothing,
    )

    _add_box(w, _color_angle(w, :CBTC1), box)
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
        box = nothing,
        hicontrast = false,
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
        box = nothing,
        hicontrast = false,
    )

    g = _grid(CheckerGrid, w; real, imag, rect, angle, abs, polar)

    if hicontrast
        c = Gray(g)
    else
        c = Gray(0.9g + 0.08)
    end

    # add boxs
    isnothing(box) ? c : _add_box(w, convert(RGB, c), box)
end

"""
    DomainColoring.sawplotshader(
        w :: Complex;
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
        color = false,
        box = nothing,
    )

Takes a complex value **`w`** and shades it as in a saw plot.

For documentation of the remaining arguments see [`sawplot`](@ref).
"""
function sawplotshader(
        w;
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
        color = false,
        box = nothing,
    )

    g = _grid(SawGrid, w; real, imag, rect, angle, abs, polar)

    if color isa Bool && !color
        c = Gray(0.6g + 0.3)
        isnothing(box) ? c : _add_box(w, convert(RGB, c), box)
    else
        c = convert(Lab, _color_angle(w, color))
        c = Lab(c.l + 20g - 10, c.a, c.b)
        _add_box(w, c, box)
    end
end
