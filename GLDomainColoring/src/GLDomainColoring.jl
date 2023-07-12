module GLDomainColoring

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
    GLDomainColoring.interactiveshadedplot(
        f :: "Complex -> Complex",
        shader :: "Matrix{Complex} -> Image",
        axes = (-1, 1, -1, 1),
    )

Takes a complex function and a shader and produces a GLMakie image plot
with auto updating.

# Arguments

- **`f`** is the complex function to plot.

- **`shader`** is the shader function to compute the image.

- **`axes`** are the initial limits of the plot, in the format
  `(minRe, maxRe, minIm, maxIm)`, if one or two numbers are provided
  instead they are take symmetric along the real and imaginary axis.
"""
function interactiveshadedplot(
        f,
        shader,
        axes = (-1, 1, -1, 1),
    )

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

    # update loop
    function update(lims, res)
        axes = (lims.origin[1], lims.origin[1] + lims.widths[1],
                lims.origin[2], lims.origin[2] + lims.widths[2])
        xl[] = axes[1]..axes[2]
        yl[] = axes[3]..axes[4]
        img[] = DomainColoring.renderimage(
            f, shader, axes, ceil.(Integer, 1.2 .* res)
        )
    end

    lims = ax.finallimits
    res = ax.scene.camera.resolution
    update(lims[], res[])

    onany(update, lims, res)

    return fg
end

function domaincolor(
        f,
        axes = (-1, 1, -1, 1);
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
    )
end

function pdphaseplot(
        f,
        axes = (-1, 1, -1, 1),
    )
    interactiveshadedplot(f, DomainColoring.pdphaseplotshader, axes)
end

function tphaseplot(
        f,
        axes = (-1, 1, -1, 1),
    )

    interactiveshadedplot(f, DomainColoring.tphaseplotshader, axes)
end

function checkerplot(
        f,
        axes = (-1, 1, -1, 1);
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
    )
end

end
