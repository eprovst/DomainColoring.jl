# DomainColoringToy

`DomainColoringToy` is an auxiliary package building on
`DomainColoring.jl` which preloads `GLMakie` and rerenders the plot when
the user zooms in or pans around.

The exported functions and arguments are identical to
`DomainColoring.jl` with the addition of the acceptance of `:auto` in
place of an integer in the `pixels` keyword argument. A direction
which is set to `:auto` will use the viewport resolution to determine
the number of samples. Note that this can make plotting very slow.

## Installation
For the time being `DomainColoringToy` is experimental and thus not
registered. To install it, use:
```
]add https://github.com/eprovst/DomainColoring.jl#main:DomainColoringToy
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
