# SPDX-License-Identifier: MIT

"""
    DomainColoring.shadedplot(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (720, 720);
        aa = true,
        kwargs...
    )

Takes a complex function **`f`** and a **`shader`** and produces a plot.

For documentation of the remaining arguments see [`renderimage`](@ref).

Keyword arguments are passed to the backend.
"""
shadedplot, shadedplot!

shadedplot(args...; kwargs...) = @error "`shadedplot` is used in an unusual way; did you load a backend?"
shadedplot!(args...; kwargs...) = @error "`shadedplot!` is used in an unusual way; did you load a backend?"
