using ClimaParameters, Documenter

pages = Any[
    "Home" => "index.md",
    "TOML file interface" => "toml.md",
    "Parameter retrieval" => "param_retrieval.md",
    "API" => "API.md",
]

mathengine = MathJax(
    Dict(
        :TeX => Dict(
            :equationNumbers => Dict(:autoNumber => "AMS"),
            :Macros => Dict(),
        ),
    ),
)

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1,
)

makedocs(
    sitename = "ClimaParameters.jl",
    format = format,
    clean = true,
    checkdocs = :exports,
    strict = true,
    modules = [ClimaParameters],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/ClimaParameters.jl.git",
    target = "build",
    push_preview = true,
    devbranch = "main",
    forcepush = true,
)
