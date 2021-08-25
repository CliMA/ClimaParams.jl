using CLIMAParameters, Documenter

pages = Any[
    "Home" => "index.md",
    "API" => "API.md",
]

mathengine = MathJax(Dict(
    :TeX => Dict(
        :equationNumbers => Dict(:autoNumber => "AMS"),
        :Macros => Dict(),
    ),
))

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1,
)

makedocs(
    sitename = "CLIMAParameters.jl",
    format = format,
    clean = true,
    strict = true,
    modules = [CLIMAParameters],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/CLIMAParameters.jl.git",
    target = "build",
    push_preview = true,
    devbranch = "main",
    forcepush = true,
)

