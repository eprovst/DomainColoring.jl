# SPDX-License-Identifier: MIT

using Colors
using FunctionWrappers

const ComplexFunction{T} = FunctionWrappers.FunctionWrapper{Complex{T}, Tuple{Complex{T}}}

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
        limits = (-1, 1, -1, 1);
        aa = true,
    )

# Arguments

- **`out`** is the output image buffer.

- **`f`** is the complex function to turn into an image.

- **`shader`** is the shader function to compute a pixel.

- **`limits`** are the limits of the rectangle to render, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

# Keyword Arguments

- **`aa`** controls anti-aliasing. Possible values are `true` (default),
  `false`, `2`, and `4`. A single sample is used per pixel for `false`, two for
  `2`, and four for `4`. When set to `true` an appropriate value is
  automatically chosen (`2` when single threaded, `4` when multiple threads are
  available, and `false` if there is reason to expect anti-aliassing to result
  in an error).
"""
function renderimage!(
    img::Matrix{C},
    f,
    shader,
    limits=(-1, 1, -1, 1);
    aa=true,
) where {C}
    renderimage!(img, ComplexFunction{typeof(real(f(0.0)))}(f), shader, limits; aa)
end

function renderimage!(
    img::Matrix{C},
    f::ComplexFunction,
    shader,
    limits=(-1, 1, -1, 1);
    aa=true,
) where {C}
    limits = _expandlimits(limits)
    rs = range(limits[1], limits[2], length=size(img, 2))
    is = range(limits[4], limits[3], length=size(img, 1))

    if aa ≡ true
        if !(eltype(C) in (Float16, Float32, Float64))
            @warn "$C might be incompatible with anti-aliasing, assuming 'aa=1'"
            _renderimage_single!(img, f, shader, rs, is)
        elseif Threads.nthreads() > 1
            _renderimage_rgss!(img, f, shader, rs, is)
        else
            _renderimage_flipquad!(img, f, shader, rs, is)
        end
    elseif aa == 2 || aa == :flipquad
        _renderimage_flipquad!(img, f, shader, rs, is)
    elseif aa == 4 || aa == :rgss
        _renderimage_rgss!(img, f, shader, rs, is)
    elseif aa ≡ false || aa == 1
        _renderimage_single!(img, f, shader, rs, is)
    else
        @error "invalid anti-aliasing option: '$aa'"
    end
end

@inline function _sample(f::ComplexFunction, r, i, shader::S, ::Type{C}) where {C,S}
    w = f(complex(r, i))
    isnan(w) ? zero(C) : convert(C, shader(w))
end

function _renderimage_single!(
    img::Matrix{C}, f::ComplexFunction, shader::S, rs, is
) where {C,S}
    if Threads.nthreads() == 1
        broadcast!(_sample, img, Ref(f), rs', is, shader, C)
    else
        Threads.@threads :static for k in axes(img, 2)
            @inbounds begin
                r = rs[k]
                for j in axes(img, 1)
                    img[j, k] = _sample(f, r, is[j], shader, C)
                end
            end
        end
    end
end

function _renderimage_rgss!(
    img::Matrix{C}, f::ComplexFunction, shader::S, rs, is
) where {C,S}
    if !(eltype(C) in (Float16, Float32, Float64))
        @warn "$C might be incompatible with anti-aliasing"
    end
    dr, di = step(rs), step(is)
    Threads.@threads :static for k in axes(img, 2)
        @inbounds begin
            r = rs[k]
            for j in axes(img, 1)
                c = zero(C)
                i = is[j]
                for (ro, io) in ((1/8, 3/8), (3/8, -1/8), (-1/8, -3/8), (-3/8, 1/8))
                    s = _sample(f, r + ro*dr, i + io*di, shader, C)
                    c = mapc((c, s) -> c + .25s, c, s)
                end
                img[j, k] = c
            end
        end
    end
end

function _renderimage_flipquad!(
    img::Matrix{C}, f::ComplexFunction, shader::S, rs, is
) where {C,S}
    if !(eltype(C) in (Float16, Float32, Float64))
        @warn "$C might be incompatible with anti-aliasing"
    end
    (Threads.nthreads() > 1) && @warn "FLIPQUAD anti-aliasing has no multithreaded implementation"

    dr, di = step(rs), step(is)
    ni, nr = size(img)
    fill!(img, zero(C))

    @inline addq!(img, j, k, s) = (img[j,k] = mapc((c, s) -> c + .25*s, img[j, k], s))
    for k in 1:(nr+1)
        r = k <= nr ? rs[k] - dr/2 : rs[nr] + dr/2
        for j in 1:(ni+1)
            i = j <= ni ? is[j] - di/2 : is[ni] + di/2
            te = _sample(f, r + ifelse(iseven(j + k), 1/3, 2/3) * dr, i, shader, C)
            le = _sample(f, r, i + ifelse(iseven(j + k), 2/3, 1/3) * di, shader, C)
            j > 1 && k <= nr && addq!(img, j-1, k, te)
            j <= ni && k <= nr && addq!(img, j, k, mapc(+, te, le))
            j <= ni && k > 1 && addq!(img, j, k-1, le)
        end
    end
end

"""
    DomainColoring.renderimage(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (720, 720);
        aa = true,
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

# Keyword Arguments

- **`aa`** controls anti-aliasing. Possible values are `true` (default),
  `false`, `2`, and `4`. A single sample is used per pixel for `false`, two for
  `2`, and four for `4`. When set to `true` an appropriate value is
  automatically chosen (`2` when single threaded, `4` when multiple threads are
  available, and `false` if there is reason to expect anti-aliassing to result
  in an error).
"""
function renderimage(
    f,
    shader,
    limits=(-1, 1, -1, 1),
    pixels=(720, 720);
    aa=true,
)

    length(pixels) == 1 && (pixels = (pixels, pixels))
    coltype = typeof(coloralpha(shader(0.0im)))
    img = Matrix{coltype}(undef, pixels[1], pixels[2])
    renderimage!(img, f, shader, limits; aa)
    return img
end
