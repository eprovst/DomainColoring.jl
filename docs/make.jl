using Pkg
cd(@__DIR__)
Pkg.activate(".")
pkg"dev .. ../DomainColoringToy"
Pkg.instantiate()
Pkg.precompile()

using Documenter, DomainColoring
import DomainColoringToy

makedocs(
  sitename = "DomainColoring.jl",
  authors = "Evert Provoost",
  pages = [
    "Home" => "index.md",
    "Usage" => [
      "usage/tutorial.md",
      "usage/general.md",
      "usage/cvd.md",
      "usage/custom.md",
    ],
    "Library" => "lib.md",
    "DomainColoringToy" => "dct.md",
    "Design Choices" => [
      "design/phasewheel.md",
    ],
  ]
)

deploydocs(
  repo = "github.com/eprovst/DomainColoring.jl.git",
  push_preview = true,
  versions = ["stable" => "v^", "v1.#", "dev" => "dev"],
)
