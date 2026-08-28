# SPDX-License-Identifier: MIT

using ColorSchemes
using Colors

"""
    DomainColoring.arenberg(θ; print = false)

Maps a phase angle **`θ`** to a color in Oklab space by
taking

```math
\\begin{aligned}
    L &= .72 - .1 \\cos(3\\theta), \\\\
    a &= .12 \\cos(\\theta + .4), \\quad\\text{and} \\\\
    b &= .12 \\sin(\\theta + .4) + .02.
\\end{aligned}
```

If `print` is set to true, a desaturated version is used which is more
easily reproduced on consumer grade printers.

See [The Arenberg Phase Wheel](@ref) for more information.
"""
function arenberg(θ; print = false)
    θ = mod(θ, 2π)
    c = Oklab(0.72 - 0.1cos(3θ) ,
              0.12cos(θ + .4),
              0.12sin(θ + .4) + 0.02)
    print ? Oklab(c.l + 0.025, .7c.a, .7c.b) : c
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
    elseif polar isa Function
        angle = true
        abs = polar
    elseif length(polar) > 1
        angle = polar[1]
        abs = polar[2]
    else
        angle = 2max(round(π/log(polar)), 4)
        abs = polar
    end

    # set defaults
    (real ≡ true) && (real = 1)
    (imag ≡ true) && (imag = 1)
    (angle ≡ true) && (angle = 8)
    (abs ≡ true) && (abs = ℯ)

    # set the transform
    saw(x) = mod(x, 1)
    if type == SawGrid
        trf = saw
    else
        trf = sinpi
    end

    g = 1.0
    if real > 0
        r = Base.real(w) / real
        isfinite(r) && (g *= trf(r))
    end
    if imag > 0
        i = Base.imag(w) / imag
        isfinite(i) && (g *= trf(i))
    end
    if angle > 0
        @assert mod(angle, 1) ≈ 0 "Rate of angle has to be an integer."
        angle = round(angle)
        (type == CheckerGrid) && @assert iseven(angle) "Rate of angle has to be even."

        a = angle * Base.angle(w) / 2π
        isfinite(a) && (g *= trf(a))
    end
    if abs isa Function
        m = abs(Base.abs(w))
        isfinite(m) && (g *= trf(m))
    elseif abs > 0
        m = log(abs, Base.abs(w))
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

_grid(type, w, arg) = _grid(type, w; rect=arg)

# Implements the angle coloring logic for shaders.
_color_angle(w, arg::Bool)::Oklab{Float64} = arg ? arenberg(angle(w)) : Oklab(.8, 0, 0)

_color_angle(w, ::Val{:print})::Oklab{Float64} = arenberg(angle(w); print=true)

function _color_angle(w, arg::Function)::Oklab{Float64}
    θ = angle(w)
    arg(ifelse(θ < 0, θ + 2π, θ))
end

function _color_angle(w, arg::ColorScheme{C,S1,S2})::Oklab{Float64} where {C,S1,S2}
    _color_angle(w, θ -> get(arg, θ / 2π))
end

function shifthalf(arr)
    hi = div(length(arr), 2)
    [arr[hi+1:end]; arr[1:hi]]
end
const CBC1 = ColorScheme(convert.(
    Oklab{Float64},
    shifthalf(reverse(ColorSchemes.cyclic_protanopic_deuteranopic_bwyk_16_96_c31_n256.colors))
))
const CBTC1 = ColorScheme(convert.(
    Oklab{Float64},
    shifthalf(reverse(ColorSchemes.cyclic_tritanopic_cwrk_40_100_c20_n256.colors))
))

function _color_angle(w, arg::Symbol)::Oklab{Float64}
    if arg == :print
      _color_angle(w, Val{:print})
    elseif arg == :CBC1 || arg == :pd
      _color_angle(w, CBC1)
    elseif arg == :CBTC1 || arg == :t
      _color_angle(w, CBTC1)
    else
      _color_angle(w, ColorSchemes.colorschemes[arg])
    end
end

# utility to optimize the passed argument before a hot loop
_preprocess_color(arg) = arg

function _preprocess_color(arg::Symbol)
    if arg == :print
      Val(:print)
    elseif arg == :CBC1 || arg == :pd
      CBC1
    elseif arg == :CBTC1 || arg == :t
      CBTC1
    else
      ColorScheme(convert.(Oklab{Float64}, ColorSchemes.colorschemes[arg]))
    end
end

# Implements the magnitude logic for `domaincolorshader`
# isnothing(transform) gives the default log, and saves us
# from compiling an anonymous function each call. See `domaincolor`
# for further argument description.
function _add_magnitude(
        w,
        c::Oklab;
        base = ℯ,
        transform = nothing,
        alpha = nothing,
    )

    # add magnitude if requested
    if base > 0
        if isfinite(base) && isnothing(alpha)
            if isnothing(transform)
                m = log(base, abs(w))
            else
                m = transform(abs(w))
            end
            isfinite(m) && (c = Oklab(c.l + .2mod(m, 1) - .1, c.a, c.b))
        else
            isnothing(alpha) && (alpha = 1)
            @assert alpha > 0 "alpha must be a positive value."
            m = abs(w)
            r = m^alpha / (m^alpha + 1)
            isfinite(r) || (r = 1.0)
            t = 1 - abs(1 - 2r)
            c = Oklab((1 - t)*(r > 0.5) + t*c.l, t*c.a, t*c.b)
        end
    end
    return c
end

_add_magnitude(w, c::Oklab, args::NamedTuple) = _add_magnitude(w, c; args...)

_add_magnitude(w, c::Oklab, arg::Bool) = arg ? _add_magnitude(w, c) : c

_add_magnitude(w, c::Oklab, arg::Function) = _add_magnitude(w, c; transform=arg)

_add_magnitude(w, c::Oklab, arg) = _add_magnitude(w, c; base=arg)

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

# domain function
function _add_box(w, c::C, (f, s)::Tuple{<:Function, <:Color}) where C <: Color
    f(w) ? convert(C, s) : c
end

function _add_box(w, c::C, (f, s)::Tuple{<:Function, <:Any}) where C <: Color
    _add_box(w, c, (f, parse(C, s)))
end

# normal box
function _add_box(w, c::C, (a, b, s)::Tuple{<:Number, <:Number, <:Color}) where C <: Color
    mr, Mr = minmax(real(a), real(b))
    mi, Mi = minmax(imag(a), imag(b))
    r, i = reim(w)
    (mr <= r <= Mr) && (mi <= i <= Mi) ? convert(C, s) : c
end

function _add_box(w, c::C, (a, b, s)::Tuple{<:Number, <:Number, <:Any}) where C <: Color
    _add_box(w, c, (a, b, parse(C, s)))
end

# utility to optimize the passed argument before a hot loop
function _preprocess_box(sqs)
    if isnothing(sqs)
        nothing
    else
        map(_preprocess_box, sqs)
    end
end
_preprocess_box((f, s)::Tuple{<:Function, <:Color}) = (f, convert(Oklab{Float64}, s))
_preprocess_box((f, s)::Tuple{<:Function, <:Any}) = (f, parse(Oklab{Float64}, s))
_preprocess_box((a, b, s)::Tuple{<:Number, <:Number, <:Color}) = (a, b, convert(Oklab{Float64}, s))
_preprocess_box((a, b, s)::Tuple{<:Number, <:Number, <:Any}) = (a, b, parse(Oklab{Float64}, s))

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

    c = _color_angle(w, color)
    c = _add_magnitude(w, c, abs)
    # add integer grid if requested
    if !(grid isa Bool) || grid
        # slightly overattenuate to compensate global darkening
        g = 1.08_grid(LineGrid, w, grid)
        c = mapc(x -> g*x, c)
    end
    _add_box(w, c, box)
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
    c = hicontrast ? Oklab(g, 0, 0) : Oklab(0.9g + 0.08, 0, 0)
    _add_box(w, c, box)
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
    c = if color ≡ false
        Oklab(0.6g + 0.3, 0, 0)
    else
        b = _color_angle(w, color)
        Oklab(b.l + .2g - .1, b.a, b.b)
    end
    _add_box(w, c, box)
end

# Former color schemes

"""
    DomainColoring.arenberg_cielab(θ; print = false)

Superseded by the Oklab version: [arenberg](@ref).

Maps a phase angle **`θ`** to a color in CIE L\\*a\\*b\\* space by
taking

```math
\\begin{aligned}
    L^* &= 67 - 12 \\cos(3\\theta), \\\\
    a^* &= 46 \\cos(\\theta + .4) - 3, \\quad\\text{and} \\\\
    b^* &= 46 \\sin(\\theta + .4) - 16.
\\end{aligned}
```

If `print` is set to true, a desaturated version is used which is more
easily reproduced on consumer grade printers.
"""
function arenberg_cielab(θ; print = false)
    θ = mod(θ, 2π)
    c = Lab(67 - 12cos(3θ),
            46cos(θ + .4) - 3,
            46sin(θ + .4) + 16)
    print ? Lab(c.l + 5, .7c.a, .7c.b) : c
end

@deprecate labsweep(θ) arenberg_cielab(θ)
