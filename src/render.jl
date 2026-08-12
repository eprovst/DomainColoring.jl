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

- **`aa`** toggles anti-aliasing. Quadruples computation time, but
  reduces jaggedness of some edges.
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
    r = range(limits[1], limits[2], length=size(img, 2))
    i = range(limits[4], limits[3], length=size(img, 1))
    dr, di = step(r), step(i)

    trns = coloralpha(shader(0.0im), 0)
    shd(w) = isnan(w) ? trns : coloralpha(shader(w))
    ssmp(f, r, i) = shd(f(r + im * i))
    aasmp(f, r, i) = weighted_color_mean(
        (0.25, 0.25, 0.25, 0.25),
        ssmp(f, r + or * dr, i + oi * di)
            for (or, oi) in ((-0.2, 0.3), (0.3, 0.2), (0.2, -0.3), (-0.3, -0.2))
    )
    smp = aa ? aasmp : ssmp
    if Threads.nthreads() == 1
        broadcast!(smp, img, Ref(f), r', i)
    else
        Threads.@threads :static for x in axes(img, 2)
            rx = r[x]
            for y in axes(img, 1)
                @inbounds img[y, x] = smp(f, rx, i[y])
            end
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

- **`aa`** toggles anti-aliasing. Quadruples computation time, but
  reduces jaggedness of some edges.
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
