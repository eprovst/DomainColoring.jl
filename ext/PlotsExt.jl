module PlotsExt

import DomainColoring as DC
import Plots

# Plots.jl specific version of `shadedplot` and `shadedplot!`
for (modifying, target) in
    ((false, ()),
     (true, ()),
     (true, (:target,)))

    fname = modifying ? :shadedplot! : :shadedplot
    pname = modifying ? :plot! : :plot

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
            r = [limits[1], limits[2]]
            i = [limits[3], limits[4]]

            # set attributes
            $(if !modifying
                  :(attr = merge((yflip=false, xlims=r, ylims=i),
                                 kwargs))
              else
                  :(attr = kwargs)
              end)

            Plots.$pname($(target...), r, i,
                reverse(DC.renderimage(f, shader, limits, pixels),
                        dims=1);
                attr...)
        end
    end
end

end
