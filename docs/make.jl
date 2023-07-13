using Documenter, DomainColoring

makedocs(
  sitename = "DomainColoring.jl",
  authors = "Evert Provoost",
  pages = [
    "Home" => "index.md",
    "Usage" => [
      "usage/tutorial.md",
      "usage/general.md",
      "usage/cvd.md",
    ],
    "Library" => [
      "lib/public.md",
      "lib/internals.md",
    ],
    "Design Choices" => [
      "design/phasewheel.md",
    ],
  ]
)

deploydocs(
  repo = "github.com/eprovst/DomainColoring.jl.git",
  push_preview = true,
)
