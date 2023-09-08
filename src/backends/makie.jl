using MakieCore
import MakieCore: Attributes

"""
    DomainColoring.shadedplot(
        f :: "Complex -> Complex",
        shader :: "Complex -> Color",
        limits = (-1, 1, -1, 1),
        pixels = (720, 720);
        kwargs...
    )

Takes a complex function **`f`** and a **`shader`** and produces a Makie
plot.

For documentation of the remaining arguments see [`renderimage`](@ref).

Keyword arguments are passed to Makie.
"""
shadedplot, shadedplot!

for (modifying, target) in
    ((false, ()),
     (true, ()),
     (true, (:target,)))

    fname = modifying ? :shadedplot! : :shadedplot
    hname = modifying ? :heatmap! : :heatmap

    @eval begin
        function $fname(
               $(target...),
               f :: Function,
               shader :: Function,
               limits = (-1, 1, -1, 1),
               pixels = (720, 720);
               kwargs...
            )

            limits = _expandlimits(limits)

            # parse Makie options
            defaults = Attributes(;
                interpolate = true,
                $(if modifying
                      :(()...)
                  else
                      Expr(:kw, :axis,
                           :((autolimitaspect = 1,
                              aspect = (limits[2] - limits[1]) /
                                       (limits[4] - limits[3]))))
                  end)
            )
            attr = merge(Attributes(; kwargs...), defaults)

            # images have inverted y and flip x and y in their storage
            r = [limits[1], limits[2]]
            i = [limits[4], limits[3]]
            $hname($(target...), r, i,
                   renderimage(f, shader, limits, pixels)'; attr...)
        end
    end
end

