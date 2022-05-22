using Test
import CLIMAParameters
const CP = CLIMAParameters

@testset "Singleton" begin
    Base.@kwdef struct Singleton end
    @test CP.required_kw_fieldnames(Singleton) == NTuple{0, Symbol}()
end

@testset "ParameterizedSingleton" begin
    Base.@kwdef struct ParameterizedSingleton{T} end
    @test CP.required_kw_fieldnames(ParameterizedSingleton) ==
          NTuple{0, Symbol}()
end

@testset "Parameterized struct" begin
    Base.@kwdef struct Foo{T}
        a::T
        b::T = a
        c::T
        d::T = b + a
    end
    @test CP.required_kw_fieldnames(Foo) == (:a, :c)
end

@testset "Missing Base.@kwdef" begin
    struct Bar{T}
        a::T
        b::T
        c::T
        d::T
    end
    @test_throws AssertionError(
        string(
            "Constructor `Bar` must be callable with ",
            "`Bar(;Pair.(fieldnames(Bar), 1)...)`Perhaps Bar's ",
            "definition is missing `Base.@kwdef`.",
        ),
    ) CP.required_kw_fieldnames(Bar)

end

@testset "Bad valid_elem" begin
    Base.@kwdef struct Baz{T <: AbstractFloat}
        a::T
        b::T
        c::T
        d::T
    end
    @test_throws MethodError CP.required_kw_fieldnames(Baz, Real(1))
end
