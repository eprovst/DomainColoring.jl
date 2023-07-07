var documenterSearchIndex = {"docs":
[{"location":"lib/internals/#Package-Internals","page":"Package Internals","title":"Package Internals","text":"","category":"section"},{"location":"lib/internals/","page":"Package Internals","title":"Package Internals","text":"Modules = [DomainColoring]\nPublic = false","category":"page"},{"location":"lib/internals/#DomainColoring.checkerplotshader-Tuple{Any}","page":"Package Internals","title":"DomainColoring.checkerplotshader","text":"DomainColoring.checkerplotshader(\n    w :: Complex;\n    real = true,\n    imag = true,\n    angle = false,\n    abs = false,\n    polar = false,\n)\n\nTakes a complex value w and shades it as in a checker plot.\n\nFor documentation of the remaining arguments see checkerplot.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#DomainColoring.domaincolorshader-Tuple{Any}","page":"Package Internals","title":"DomainColoring.domaincolorshader","text":"DomainColoring.domaincolorshader(\n    w :: Complex;\n    abs = false,\n    logabs = false,\n    grid = false,\n    all = false,\n)\n\nTakes a complex value w and shades it as in a domain coloring.\n\nFor documentation of the remaining arguments see domaincolor.\n\n\n\n\n\n","category":"method"},{"location":"lib/internals/#DomainColoring.shadedplot","page":"Package Internals","title":"DomainColoring.shadedplot","text":"DomainColoring.shadedplot(\n    f :: Complex -> Complex,\n    shader :: (Complex; kwargs...) -> Color,\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n    kwargs...\n)\n\nTakes a complex function and a shader and produces a Makie image plot.\n\nArguments\n\nf is the complex function to plot.\n\nshader is the shader function to compute pixel colors.\n\naxes are the limits of the rectangle to plot, in the format (min Re, max Re, min Im, max Im), if one or two numbers are provided instead they are take symmetric along the real and imaginary axis.\n\nKeyword Arguments\n\npixels is the number of pixels to compute in, respectively, the real and imaginary axis, taking the same for both if only one number is provided.\n\nThe remaining keyword arguments are passed to the shader function.\n\n\n\n\n\n","category":"function"},{"location":"lib/public/#Public-Interface","page":"Public Interface","title":"Public Interface","text":"","category":"section"},{"location":"lib/public/","page":"Public Interface","title":"Public Interface","text":"Modules = [DomainColoring]\nPrivate = false","category":"page"},{"location":"lib/public/#DomainColoring.checkerplot","page":"Public Interface","title":"DomainColoring.checkerplot","text":"checkerplot(\n    f :: Complex -> Complex,\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n    real = true,\n    imag = true,\n    angle = false,\n    abs = false,\n    polar = false,\n)\n\nTakes a complex function and produces a checker plot as a Makie image.\n\ntodo: Todo\nDocument arguments.\n\n\n\n\n\n","category":"function"},{"location":"lib/public/#DomainColoring.domaincolor","page":"Public Interface","title":"DomainColoring.domaincolor","text":"domaincolor(\n    f :: Complex -> Complex,\n    axes = (-1, 1, -1, 1);\n    pixels = (720, 720),\n    abs = false,\n    logabs = false,\n    grid = false,\n    all = false,\n)\n\nTakes a complex function and produces it's domain coloring as a Makie image plot.\n\ntodo: Todo\nDocument arguments.\n\n\n\n\n\n","category":"function"},{"location":"#DomainColoring.jl:-Smooth-Complex-Plotting","page":"Home","title":"DomainColoring.jl: Smooth Complex Plotting","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the documentation of the DomainColoring.jl package, a small collection of various ways to plot complex functions, built on GLMakie.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Currently the functionality here is focussed on interactive work, however it should not be too difficult to expose the underlying shading techniques to other plotting libraries.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The plots implemented here are inspired by the wonderful book by Wegert[1], yet using a smooth (technically analytic) curve through CIE L*a*b* space, yielding a more perceptually uniform representation of the phase.","category":"page"},{"location":"","page":"Home","title":"Home","text":"[1]: Wegert, Elias. Visual Complex Functions: An Introduction with Phase Portraits. Birkhäuser Basel, 2012.","category":"page"}]
}
