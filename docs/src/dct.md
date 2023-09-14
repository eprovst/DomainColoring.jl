# DomainColoringToy

`DomainColoringToy` is an auxiliary package building on
`DomainColoring.jl` which preloads `GLMakie` and rerenders the plot when
the user zooms in or pans around.

The exported functions and arguments are identical to
`DomainColoring.jl` with the addition of the acceptance of `:auto` in
place of an integer in the `pixels` keyword argument. A direction
which is set to `:auto` will use the viewport resolution to determine
the number of samples. Note that this can make plotting very slow.

Finally, in a similar fashion to `DomainColoring.@shadedplot`, one can
use `DomainColoringToy.@shadedplot` to create custom plots.

## Installation
`DomainColoringToy` is a different package and hence has to be installed
separately. Installation is as usual:
```
]add DomainColoringToy
```

## Library
### Public Interface

```@autodocs
Modules = [DomainColoringToy]
Private = false
```

### Package Internals

```@autodocs
Modules = [DomainColoringToy]
Public = false
```
