# SPDX-License-Identifier: MIT

using Colors

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
        img::Matrix{C},
        f,
        shader,
        limits = (-1, 1, -1, 1),
    ) where C

    limits = _expandlimits(limits)
    r = range(limits[1], limits[2], length=size(img, 2))
    i = range(limits[4], limits[3], length=size(img, 1))
    shd(w) = isnan(w) ? zero(C) : convert(C, shader(w))
    broadcast!((r, i) -> shd(f(r + im*i)), img, r', i)
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
    img = Matrix{RGBA{Float64}}(undef, pixels[1], pixels[2])
    renderimage!(img, f, shader, limits)
    return img
end
