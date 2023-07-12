var documenterSearchIndex = {"docs":
[{"location":"lib/internals/#Package-Internals","page":"Package Internals","title":"Package Internals","text":"","category":"section"},{"location":"lib/internals/","page":"Package Internals","title":"Package Internals","text":"Modules = [DomainColoring]\nPublic = false","category":"page"},{"location":"lib/internals/#DomainColoring.checkerplotpixelshader-Tuple{Any}","page":"Package Internals","title":"DomainColoring.checkerplotpixelshader","text":"DomainColoring.checkerplotpixelshader(\n    w :: Complex;\n    real = false,\n    imag = false,\n    angle = false,\n    abs = false,\n)\n\nTakes a complex value w and shades it as in a checker plot.\n\nFor documentation of the remaining arguments see checkerplot.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#DomainColoring.domaincolorpixelshader-Tuple{Any}","page":"Package Internals","title":"DomainColoring.domaincolorpixelshader","text":"DomainColoring.domaincolorpixelshader(\n    w :: Complex;\n    abs = false,\n    logabs = false,\n    grid = false,\n    all = false,\n)\n\nTakes a complex value w and shades it as in a domain coloring.\n\nFor documentation of the remaining arguments see domaincolor.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#DomainColoring.labsweep-Tuple{Any}","page":"Package Internals","title":"DomainColoring.labsweep","text":"DomainColoring.labsweep(θ)\n\nMaps a phase angle θ to a color in CIE L*a*b* space by taking\n\nbeginaligned\n      L^* = 12 cos(3theta - pi) + 67 \n      a^* = 46 cos(theta + 4) - 3 quadtextand \n      b^* = 46 sin(theta + 4) - 16\n  endaligned\n\nSee Phase Wheel for more information.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#DomainColoring.shadedplot","page":"Package Internals","title":"DomainColoring.shadedplot","text":"DomainColoring.shadedplot(\n    f :: \"Complex -> Complex\",\n    shader :: \"(Matrix{Complex}; kwargs...) -> Image\",\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n    kwargs...\n)\n\nTakes a complex function and a shader and produces a Makie image plot.\n\nArguments\n\nf is the complex function to plot.\nshader is the shader function to compute the image.\naxes are the limits of the rectangle to plot, in the format (minRe, maxRe, minIm, maxIm), if one or two numbers are provided instead they are take symmetric along the real and imaginary axis.\n\nKeyword Arguments\n\npixels is the number of pixels to compute in, respectively, the real and imaginary axis, taking the same for both if only one number is provided.\n\n\n\n\n\n","category":"function"},{"location":"design/phasewheel/#Phase-Wheel","page":"Phase Wheel","title":"Phase Wheel","text":"","category":"section"},{"location":"design/phasewheel/","page":"Phase Wheel","title":"Phase Wheel","text":"Creating a perceptually uniform color wheel is in general a difficult task. There has been quite some work by Peter Kovesi on this topic, much of which is for Julia implemented in his package PerceptualColourMaps.jl.","category":"page"},{"location":"design/phasewheel/","page":"Phase Wheel","title":"Phase Wheel","text":"In this library we chose to maximize perceptual uniformity even more (at the cost at somewhat dull colors) by using a carefully selected analytical sweep through CIE L*a*b* space","category":"page"},{"location":"design/phasewheel/","page":"Phase Wheel","title":"Phase Wheel","text":"beginaligned\n    L^* = 12 cos(3theta - pi) + 67\n    a^* = 46 cos(theta + 4) - 3quadtextand\n    b^* = 46 sin(theta + 4) - 16\nendaligned","category":"page"},{"location":"design/phasewheel/","page":"Phase Wheel","title":"Phase Wheel","text":"Where we made sure to have only slight clipping in sRGB space when adding the lightness variations used to show magnitude changes in domaincolor.","category":"page"},{"location":"design/phasewheel/","page":"Phase Wheel","title":"Phase Wheel","text":"This is implemented by the internal function DomainColoring.labsweep, giving the following phase wheel.","category":"page"},{"location":"design/phasewheel/","page":"Phase Wheel","title":"Phase Wheel","text":"using DomainColoring, Colors #hide\nshowable(::MIME\"text/plain\", ::AbstractVector{C}) where {C<:Colorant} = false #hide\nDomainColoring.labsweep.(0:.01:2π)","category":"page"},{"location":"usage/tutorial/#Basic-Tutorial","page":"Basic Tutorial","title":"Basic Tutorial","text":"","category":"section"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"note: Note\nIf you're experienced with Julia and phase plots, this document might be fairly basic. Continue to the Public Interface documentation instead.","category":"page"},{"location":"usage/tutorial/#Installation,-loading-and-Makie","page":"Basic Tutorial","title":"Installation, loading and Makie","text":"","category":"section"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"DomainColoring.jl provides plotting routines for complex functions. These build on the Makie plotting library. Makie supports multiple backends, one of which has to be loaded to display the resulting plot. There are two main options:","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"GLMakie for interactive plots, and\nCairoMakie for publication quality plots.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"In this tutorial we will use CairoMakie to provide output for the documentation, but whilst following along you might want to use GLMakie instead.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"To install DomainColoring.jl and either of these packages, enter","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"]add DomainColoring GLMakie","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"or","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"]add DomainColoring CairoMakie","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"into the Julia REPL. (To return to the Julia REPL after this, simply press backspace.)","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"After installation your session should in general start with either","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using GLMakie, DomainColoring","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"for interactive work, or for publication graphics with","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring","category":"page"},{"location":"usage/tutorial/#Plotting-our-first-few-phase-plots","page":"Basic Tutorial","title":"Plotting our first few phase plots","text":"","category":"section"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"Julia supports the passing of functions as arguments, even better, it supports the creation of so called 'anonymous' functions. We can for instance write the function that maps an argument z to 2z + 1 as","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"z -> 2z + 1","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"Let us now see how the phase of this function behaves in the complex plane. First, if you haven't already, we need to load DomainColoring.jl and an appropriate Makie backend (our suggestion is GLMakie if you're experimenting from the Julia REPL):","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"Then a simple phase plot can be made using","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring # hide\ndomaincolor(z -> 2z + 1)\nsave(\"simplephaseexample.png\", current_figure()) # hide\nnothing # hide","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"(Image: )","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"As expected we see a zero of multiplicity one at -05, furthermore we see that domaincolor defaults to unit axis limits in each direction.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"Something useful to know about phase plots, the order of the colors tells you more about the thing you are seeing:","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"red, green and blue (anticlockwise) is a zero; and\nred, blue and green is a pole.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"The number of times you go through these colors gives you the multiplicity. A pole of multiplicity two gives for instance:","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring # hide\ndomaincolor(z -> 1 / z^2)\nsave(\"simplepoleexample.png\", current_figure()) # hide\nnothing # hide","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"(Image: )","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"We've now looked at poles and zeroes, another interesting effect to see on a phase plot are branch cuts. Julia's implementation of the square root has a branch cut on the negative real axis, as we can see on the following figure.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring # hide\ndomaincolor(sqrt, [-10, 2, -2, 2])\nsave(\"sqrtexample.png\", current_figure()) # hide\nnothing # hide","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"(Image: )","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"There are a couple of things of note here. First, Julia allows us to simply pass sqrt, which here is equivalent to z -> sqrt(z). Second, domaincolor accepts axis limits as an optional second argument (for those familiar with Julia: any indexable object will work). Finally, branch cuts give discontinuities in the phase plot (identifying these is greatly helped by the perceptual uniformity of the Phase Wheel used).","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"We conclude by mentioning that you do not always need to specify all limits explicitly. If you want to take the same limit in all four directions you can simply pass that number. When you pass a vector with only two elements, these will be taken symmetric in the real and imaginary direction respectively. This way we can zoom in on the beauty of the essential singularity of e^frac1z.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring # hide\ndomaincolor(z -> exp(1/z), 0.5)\nsave(\"essentialsingexample.png\", current_figure()) # hide\nnothing # hide","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"(Image: )","category":"page"},{"location":"usage/tutorial/#Plotting-the-DomainColoring.jl-logo","page":"Basic Tutorial","title":"Plotting the DomainColoring.jl logo","text":"","category":"section"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"As a final example, let us show off a few more capabilities of the domaincolor function by plotting the DomainColoring.jl logo.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"This is a plot of f(z) = z^3i - 1 with level curves of the logarithm of the magnitude and an integer grid. You can continue by reading the Public Interface documentation to learn more about these and other additional options, and the other provided plotting function checkerplot.","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"using CairoMakie, DomainColoring # hide\ndomaincolor(z -> im*z^3-1, 2.5, logabs=true, grid=true)\nsave(\"logoexample.png\", current_figure()) # hide\nnothing # hide","category":"page"},{"location":"usage/tutorial/","page":"Basic Tutorial","title":"Basic Tutorial","text":"(Image: )","category":"page"},{"location":"lib/public/#Public-Interface","page":"Public Interface","title":"Public Interface","text":"","category":"section"},{"location":"lib/public/","page":"Public Interface","title":"Public Interface","text":"Modules = [DomainColoring]\nPrivate = false","category":"page"},{"location":"lib/public/#DomainColoring.checkerplot","page":"Public Interface","title":"DomainColoring.checkerplot","text":"checkerplot(\n    f :: \"Complex -> Complex\",\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n    real = false,\n    imag = false,\n    rect = false,\n    angle = false,\n    abs = false,\n    polar = false,\n)\n\nTakes a complex function and produces a checker plot as a Makie image.\n\nArguments\n\nf is the complex function to plot.\naxes are the limits of the rectangle to plot, in the format (minRe, maxRe, minIm, maxIm), if one or two numbers are provided instead they are take symmetric along the real and imaginary axis.\n\nKeyword Arguments\n\npixels is the number of pixels to compute in, respectively, the real and imaginary axis, taking the same for both if only one number is provided.\n\nIf none of the below options are set, the plot defaults to rect = true.\n\nreal plots black and white stripes orthogonal to the real axis at a rate of 5 stripes per unit.\nimag plots black and white stripes orthogonal to the imaginary axis at a rate of 5 stripes per unit.\nrect is a shortcut for real = true and imag = true.\nphase is a shortcut for angle = true and abs = true.\nangle plots black and white stripes orthogonal to the phase angle at a rate of 32 stripes per full rotation.\nabs plots black and white stripes at a rate of 5 stripes per unit increase of the natural logarithm of the magnitude.\nphase is a shortcut for angle = true and abs = true.\n\n\n\n\n\n","category":"function"},{"location":"lib/public/#DomainColoring.domaincolor","page":"Public Interface","title":"DomainColoring.domaincolor","text":"domaincolor(\n    f :: \"Complex -> Complex\",\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n    abs = false,\n    logabs = false,\n    grid = false,\n    all = false,\n)\n\nTakes a complex function and produces it's domain coloring as a Makie image plot.\n\nRed corresponds to phase 0, yellow to fracpi3, green to frac2pi3, cyan to pi, blue to frac4pi3, and magenta to frac5pi3.\n\nArguments\n\nf is the complex function to plot.\naxes are the limits of the rectangle to plot, in the format (minRe, maxRe, minIm, maxIm), if one or two numbers are provided instead they are take symmetric along the real and imaginary axis.\n\nKeyword Arguments\n\npixels is the number of pixels to compute in, respectively, the real and imaginary axis, taking the same for both if only one number is provided.\nabs toggles the plotting of the magnitude as lightness ramps between level curves.\nlogabs is similar to abs but shows the natural logarithm of the magnitude instead. This option takes precedence over abs.\ngrid plots points with integer real or imaginary part as black dots.\nall is a shortcut for abs = true and grid = true.\n\n\n\n\n\n","category":"function"},{"location":"lib/public/#DomainColoring.pdphaseplot","page":"Public Interface","title":"DomainColoring.pdphaseplot","text":"pdphaseplot(\n    f :: \"Complex -> Complex\",\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n)\n\nTakes a complex valued function and produces a phase plot as a Makie image plot using ColorCET's CBC1 cyclic color map for protanopic and deuteranopic viewers.\n\nYellow corresponds to phase 0, white to fracpi2, blue to pi, and black to frac3pi2.\n\nArguments\n\nf is the complex function to plot.\naxes are the limits of the rectangle to plot, in the format (minRe, maxRe, minIm, maxIm), if one or two numbers are provided instead they are take symmetric along the real and imaginary axis.\n\nKeyword Arguments\n\npixels is the number of pixels to compute in, respectively, the real and imaginary axis, taking the same for both if only one number is provided.\n\n\n\n\n\n","category":"function"},{"location":"lib/public/#DomainColoring.tphaseplot","page":"Public Interface","title":"DomainColoring.tphaseplot","text":"tphaseplot(\n    f :: \"Complex -> Complex\",\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n)\n\nTakes a complex valued function and produces a phase plot as a Makie image plot using ColorCET's CBTC1 cyclic color map for titranopic viewers.\n\nRed corresponds to phase 0, white to fracpi2, cyan to pi, and black to frac3pi2.\n\nArguments\n\nf is the complex function to plot.\naxes are the limits of the rectangle to plot, in the format (minRe, maxRe, minIm, maxIm), if one or two numbers are provided instead they are take symmetric along the real and imaginary axis.\n\nKeyword Arguments\n\npixels is the number of pixels to compute in, respectively, the real and imaginary axis, taking the same for both if only one number is provided.\n\n\n\n\n\n","category":"function"},{"location":"#DomainColoring.jl:-Smooth-Complex-Plotting","page":"Home","title":"DomainColoring.jl: Smooth Complex Plotting","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation of the DomainColoring.jl package, a small collection of various ways to plot complex functions, built on Makie.","category":"page"},{"location":"","page":"Home","title":"Home","text":"<div align=\"center\">\n  <img src=\"assets/logo.png\" width=300 />\n</div>","category":"page"},{"location":"","page":"Home","title":"Home","text":"The plots implemented here are inspired by the wonderful book by Wegert[1], yet using a smooth (technically analytic) curve through CIE L*a*b* space, yielding a more perceptually uniform representation of the phase (see Phase Wheel).","category":"page"},{"location":"","page":"Home","title":"Home","text":"[1]: Wegert, Elias. Visual Complex Functions: An Introduction with Phase Portraits. Birkhäuser Basel, 2012.","category":"page"}]
}
