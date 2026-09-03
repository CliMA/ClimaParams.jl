using Test

import ClimaParams as CP
import TOML

# Structural conventions for the default parameter file, documented in
# docs/src/contributing.md. These catch the drift that accumulates when
# parameters are added by many people over time.

const PARAMETERS_TOML = joinpath(pkgdir(CP), "src", "parameters.toml")
const DEFAULTS = TOML.parsefile(PARAMETERS_TOML)
const VALID_TYPES = ("float", "integer", "string", "bool", "datetime")

@testset "Default file: required attributes" begin
    for (name, entry) in DEFAULTS
        @test haskey(entry, "value")
        @test haskey(entry, "type")
        @test entry["type"] in VALID_TYPES
        @test haskey(entry, "description")
        @test !isempty(strip(entry["description"]))
    end
end

@testset "Default file: description conventions" begin
    for (name, entry) in DEFAULTS
        description = entry["description"]
        # A description is prose, so it ends in a period.
        @test endswith(description, ".")
        # Inline math is delimited by matched `$`.
        @test iseven(count(==('$'), description))
        # Dimensionless quantities are marked `(unitless)`.
        @test !occursin(r"\(-\)|\[-\]|[Dd]imensionless", description)
        # Units use SI notation with spaces and superscripts, not slashes.
        # Only short parentheticals are treated as unit annotations, and math
        # spans are exempt, since a slash there is division.
        prose = replace(description, r"\$[^$]*\$" => "")
        for unit in eachmatch(r"\(([^()]{1,20})\)", prose)
            @test !occursin(r"[a-zA-Z]/[a-zA-Z]", unit.captures[1])
            # `mol-1` rather than `mol⁻¹`.
            @test !occursin(r"\b[a-zA-Z]+-\d\b", unit.captures[1])
        end
        # A stray tab means a LaTeX command lost its escape: `"$\tau$"` is
        # parsed by TOML as `$` + TAB + `au$`. Backslashes must be doubled.
        @test !any(c -> iscntrl(c), description)
        # A citation names its source, not just a DOI.
        @test !occursin("Source: DOI:", description)
        # A `|` inside math cannot be both escaped for the parameter table and
        # left alone for KaTeX, which reads `\\|` as the norm delimiter.
        for math in eachmatch(r"\$[^$]*\$", description)
            @test !occursin('|', math.match)
        end
    end
end

@testset "Default file: no stray attributes" begin
    # Attributes ClimaParams reads, plus those carried through for
    # EnsembleKalmanProcesses.jl. `used_in` is written by the logger, not by
    # hand.
    known = Set([
        "value",
        "type",
        "description",
        "tag",
        "prior",
        "constraint",
        "L1",
        "L2",
    ])
    for (name, entry) in DEFAULTS
        unknown = setdiff(keys(entry), known)
        @test isempty(unknown)
    end
    # Calibration metadata is experiment-specific and belongs in override files.
    for (name, entry) in DEFAULTS
        @test !haskey(entry, "prior")
        @test !haskey(entry, "constraint")
    end
end

@testset "Default file: section structure" begin
    # `##` comments mark top-level groups, `#` comments their subsections. Every
    # parameter must fall under some section, and the file must open with one.
    lines = readlines(PARAMETERS_TOML)
    first_header = findfirst(line -> startswith(strip(line), "#"), lines)
    first_table = findfirst(line -> startswith(strip(line), "["), lines)
    @test !isnothing(first_header)
    @test first_header < first_table

    top_level = count(line -> startswith(strip(line), "## "), lines)
    @test top_level > 0
end

@testset "Default file: loads at both precisions" begin
    for FT in (Float32, Float64)
        toml_dict = CP.create_toml_dict(FT)
        # Every entry converts to its declared type without error.
        for name in keys(DEFAULTS)
            @test !isnothing(toml_dict[name])
        end
    end
end
