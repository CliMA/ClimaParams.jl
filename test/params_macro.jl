using Test
using ClimaParams

abstract type AbstractFoo{T} end

"""    Foo1(; a, [b], [c])    """
@params struct Foo1{T1, T2 <: Real} <: AbstractFoo{T1}
    "a: required scalar"
    a::T1
    "b: optional tuple"
    b::Tuple{T2} = (1.0,)
    "c: optional scalar"
    c::T1 = 1
end
@params struct Foo2{N}
    a::Int
    b::Tuple{Real} = (1.0,)
    c::Integer = 1
end
@params struct Foo3 <: AbstractFoo{Any}
    a
    b = (1.0,)
    c = 1
end

val_getproperty(foo, ::Val{name}) where {name} = Val(getproperty(foo, name))

@testset "@params macro" begin
    @test_throws "Mutable structs" @macroexpand @params mutable struct Foo end
    @test_throws "Inner constructors" @macroexpand @params struct Foo
        Foo() = new()
    end

    @test occursin("Foo1(; a, [b], [c])", string(@doc Foo1))
    @test fieldnames(Foo1) == (:a, :b, :c)
    @test propertynames(Foo1(; a = 2)) == (:a, :b, :c)
    @test Foo1(; a = 2) isa AbstractFoo{Int}
    @test_throws MethodError Foo1(; a = 2.0)
    @test Foo1(; a = 2.0, c = 2.0) isa AbstractFoo{Float64}
    @test_throws "Only isbits values" Foo1(; a = [2], c = [2])

    @test Foo1(; a = 2) ==
          Foo1(2, (1.0,), 1) ==
          Foo1{Int, Float64}(; a = 2.0) ==
          Foo1{Int, Float64}(2.0, (1,), 1.0)
    @test Foo1(2, (1.0,), 1) isa Foo1{Int, Float64, (2, (1.0,), 1)}
    @test Foo2{2}(; a = 2) == Foo2{2}(2, (1.0,), 1)
    @test Foo2{2}(2, (1.0,), 1) isa Foo2{2, (2, (1.0,), 1)}
    @test Foo3(; a = 2) == Foo3(2, (1.0,), 1)
    @test Foo3(2, (1.0,), 1) isa Foo3{(2, (1.0,), 1)}

    @test Foo1(; a = 2.0, b = (2,), c = 2.0) ==
          Foo1(2.0, (2,), 2.0) ==
          Foo1{Float64, Int}(; a = 2, b = (2.0,), c = 2) ==
          Foo1{Float64, Int}(2, (2.0,), 2)
    @test Foo1(2.0, (2,), 2.0) isa Foo1{Float64, Int, (2.0, (2,), 2.0)}
    @test Foo2{2}(; a = 2.0, b = (2,), c = 2.0) == Foo2{2}(2.0, (2,), 2.0)
    @test Foo2{2}(2.0, (2,), 2.0) isa Foo2{2, (2, (2,), 2)}
    @test Foo3(; a = 2.0, b = (2,), c = 2.0) == Foo3(2.0, (2,), 2.0)
    @test Foo3(2.0, (2,), 2.0) isa Foo3{(2.0, (2,), 2.0)}

    @inferred Val{2.0} val_getproperty(Foo1(; a = 2.0, c = 2.0), Val(:a))
    @inferred Val{2} val_getproperty(Foo2{2}(; a = 2.0, c = 2.0), Val(:a))
    @inferred Val{2.0} val_getproperty(Foo3(; a = 2.0, c = 2.0), Val(:a))
end
