using ClimaParams, Documenter

include(joinpath(@__DIR__, "generate_parameter_table.jl"))

pages = Any[
    "Home" => "index.md",
    "Parameter retrieval" => "param_retrieval.md",
    "TOML file interface" => "toml.md",
    "Calibration metadata" => "calibration.md",
    "Parameter list" => "parameters.md",
    "Adding and changing parameters" => "contributing.md",
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
    # The generated parameter list is one large reference table by design. Every
    # other page keeps the default size limits.
    size_threshold_ignore = ["parameters.md"],
)

makedocs(
    sitename = "ClimaParams.jl",
    format = format,
    clean = true,
    checkdocs = :exports,
    modules = [ClimaParams],
    pages = pages,
)

deploydocs(
    repo = "github.com/CliMA/ClimaParams.jl.git",
    target = "build",
    push_preview = all(
        !isempty,
        (get(ENV, "GITHUB_TOKEN", ""), get(ENV, "DOCUMENTER_KEY", "")),
    ),
    devbranch = "main",
    forcepush = true,
)
