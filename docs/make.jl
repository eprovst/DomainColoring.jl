using Pkg
cd(@__DIR__)
Pkg.activate(".")
Pkg.develop(path="..")
Pkg.develop(path="../DomainColoringToy")
Pkg.instantiate()
Pkg.precompile()

using Documenter, DomainColoring
import DomainColoringToy

makedocs(
  sitename = "DomainColoring.jl",
  authors = "Evert Provoost",
  repo="https://github.com/eprovst/DomainColoring.jl/blob/{commit}{path}#{line}",
  format=Documenter.HTML(
    repolink="https://github.com/eprovst/DomainColoring.jl/",
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://eprovst.github.io/DomainColoring.jl",
    assets=["assets/style.css",]
  ),
  pages = [
    hide("Home" => "index.md"),
    "Usage" => [
      "usage/tutorial.md",
      "usage/general.md",
      "usage/cvd.md",
      "usage/custom.md",
    ],
    "Library" => "lib.md",
    "DomainColoringToy" => "dct.md",
    "Arenberg Phase Wheel" => "arenberg.md",
  ]
)

deploydocs(
  repo = "github.com/eprovst/DomainColoring.jl.git",
  push_preview = true,
  versions = ["stable" => "v^", "v1.#", "dev" => "dev"],
)
