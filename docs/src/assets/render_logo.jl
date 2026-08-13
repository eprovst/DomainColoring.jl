using Images
using DomainColoring

save("logo.png", domaincolorimg(z -> im*(z+.1im)^3-1, 2.5; all=true))
