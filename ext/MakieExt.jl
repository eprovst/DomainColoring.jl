# SPDX-License-Identifier: MIT

module MakieExt

import DomainColoring as DC
import Makie

# Makie specific version of `shadedplot` and `shadedplot!`
for (modifying, target) in
    ((false, ()),
     (true, ()),
     (true, (:target,)))

    fname = modifying ? :shadedplot! : :shadedplot
    hname = modifying ? :heatmap! : :heatmap

    @eval begin
        function DC.$fname(
               $(target...),
               f :: Function,
               shader :: Function,
               limits = (-1, 1, -1, 1),
               pixels = (720, 720);
               kwargs...
            )

            limits = DC._expandlimits(limits)

            # parse Makie options
            $(if !modifying
                  :(defaults = Makie.Attributes(;
                      interpolate = true,
                      axis = (autolimitaspect = 1,
                              aspect = (limits[2] - limits[1]) /
                                       (limits[4] - limits[3]))))
              else
                  :(defaults = Makie.Attributes(; interpolate = true))
              end)

            attr = merge(Makie.Attributes(; kwargs...), defaults)

            # images have inverted y and flip x and y in their storage
            r = [limits[1], limits[2]]
            i = [limits[4], limits[3]]
            Makie.$hname($(target...), r, i,
                      DC.renderimage(f, shader, limits, pixels)';
                      attr...)
        end
    end
end

end
