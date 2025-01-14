using Images
import DomainColoring as DC


fig = DC.renderimage(z -> im*(z+.1im)^3-1,
                     w -> DC.domaincolorshader(w; all=true), 2.5)

save("logo.png", fig)
