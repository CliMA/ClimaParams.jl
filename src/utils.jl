"""
    required_kw_fieldnames(::Type, valid_elem = 1)

Returns a tuple of symbols that are required
(do not have default values) for the _keyword_
constructor for type `T`.

This method is generally intended for types that
fields that all have the same element type.

If the element type is restricted, `valid_elem`
may be passed, however, for following constructor
must be allowed:

`T(;Pair.(fieldnames(T), (valid_elem))...)`
"""
function required_kw_fieldnames(::Type{T}, valid_elem = 1) where {T}
    all_fieldnames = fieldnames(T)
    rkfn = Symbol[]
    isempty(all_fieldnames) && return NTuple{0, Symbol}()

    @assert hasmethod(T, Tuple{}, all_fieldnames) string(
        "Constructor `$T` must be callable with ",
        "`$T(;Pair.(fieldnames($T), $(valid_elem))...)`",
        "Perhaps $T's definition is missing `Base.@kwdef`.",
    )
    try
        T(; Pair.(all_fieldnames, valid_elem)...)
    catch err
        @error string(
            "\nFailed to construct `$T` with ",
            "`$T(;Pair.(fieldnames($T), valid_elem)...)`, where\n",
            "valid_elem = $valid_elem\n",
            "typeof(valid_elem) = $(typeof(valid_elem))\n",
        )
        rethrow(err)
    end

    for fn in all_fieldnames
        all_but_fn = map(filter(x -> x ≠ fn, all_fieldnames)) do fn′
            Pair(fn′, valid_elem)
        end
        callable_method = try
            T(; all_but_fn...)
            true
        catch
            false
        end
        callable_method && continue
        push!(rkfn, fn)
    end
    return tuple(rkfn...)
end
