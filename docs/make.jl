using Documenter, DomainColoring

makedocs(
  sitename = "DomainColoring.jl",
  authors = "Evert Provoost",
  pages = [
    "Home" => "index.md",
    "Library" => [
      "lib/public.md",
      "lib/internals.md",
    ]
  ]
)

deploydocs(
  repo = "github.com/eprovst/DomainColoring.jl.git",
  push_preview = true,
)
