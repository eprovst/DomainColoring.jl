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

module DomainColoringToy

using GLMakie
import DomainColoring

export domaincolor, checkerplot, pdphaseplot, tphaseplot

# TEMP: reuse DomainColoring docstrings
# TODO: rewrite them as they do not line up entirely
@doc (@doc DomainColoring.domaincolor) domaincolor
@doc (@doc DomainColoring.checkerplot) checkerplot
@doc (@doc DomainColoring.pdphaseplot) pdphaseplot
@doc (@doc DomainColoring.tphaseplot) tphaseplot

"""
    DomainColoringToy.interactiveshadedplot(
        f :: "Complex -> Complex",
        shader :: "Matrix{Complex} -> Image",
        axes = (-1, 1, -1, 1),
        pixels = (480, 480),
    )

Takes a complex function and a shader and produces a GLMakie image plot
with auto updating.

# Arguments

- **`f`** is the complex function to plot.

- **`shader`** is the shader function to compute the image.

- **`axes`** are the initial limits of the plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.

- **`pixels`** is the size of the output in pixels, respectively, the
  number of pixels along the real and imaginary axis, taking the same
  for both if only one number is provided. If either is `:auto`, the
  screen resolution is used.
"""
function interactiveshadedplot(
        f,
        shader,
        axes = (-1, 1, -1, 1),
        pixels = (480, 480),
    )

    # sanitize input
    pixels == :auto && (pixels = (:auto, :auto))
    length(pixels) == 1 && (pixels = (pixels, pixels))
    axes = DomainColoring.expandaxes(axes)

    # setup buffers
    img = Observable(
        DomainColoring.renderimage(f, shader, axes, (2, 2))
    )
    xl = Observable(axes[1]..axes[2])
    yl = Observable(axes[3]..axes[4])

    # setup plot
    fg, ax = image(xl, yl, img; axis=(autolimitaspect=1,))

    # set default limits
    xlims!(ax, axes[1], axes[2])
    ylims!(ax, axes[3], axes[4])

    # keep reference to resolution
    res = ax.scene.camera.resolution

    # update loop
    function update(lims)
        axs = (lims.origin[1], lims.origin[1] + lims.widths[1],
               lims.origin[2], lims.origin[2] + lims.widths[2])
        xl[] = axs[1]..axs[2]
        yl[] = axs[3]..axs[4]

        # set resolution if requested
        px = pixels
        if pixels[1] == :auto
            px = (ceil(Int, 1.2res[][1]), px[2])
        end
        if pixels[2] == :auto
            px = (px[1], ceil(Int, 1.2res[][2]))
        end

        img[] = DomainColoring.renderimage(
            f, shader, axs, px
        )
    end

    # initial render
    lims = ax.finallimits
    update(lims[])

    # observe the limits
    on(update, lims)

    return fg
end

function domaincolor(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (480, 480),
        abs = false,
        logabs = false,
        grid = false,
        all = false,
    )

    interactiveshadedplot(
        f,
        W -> DomainColoring.domaincolorpixelshader.(
            W; abs, logabs, grid, all
        ),
        axes,
        pixels,
    )
end

function pdphaseplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (480, 480),
    )

    interactiveshadedplot(
        f, DomainColoring.pdphaseplotshader, axes, pixels
    )
end

function tphaseplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (480, 480),
    )

    interactiveshadedplot(
        f, DomainColoring.tphaseplotshader, axes, pixels
    )
end

function checkerplot(
        f,
        axes = (-1, 1, -1, 1);
        pixels = (480, 480),
        real = false,
        imag = false,
        rect = false,
        angle = false,
        abs = false,
        polar = false,
    )

    interactiveshadedplot(
        f,
        W -> DomainColoring.checkerplotpixelshader.(
            W; real, imag, rect, angle, abs, polar
        ),
        axes,
        pixels,
    )
end

end
