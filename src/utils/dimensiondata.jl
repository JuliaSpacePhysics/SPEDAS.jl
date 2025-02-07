"""
    nt2ds(nt_arr, dim; fields=propertynames(first(nt_arr)))

Convert a NamedTuple array to a DimStack of DimArrays.
"""
function nt2ds(nt_arr, dim; fields=propertynames(first(nt_arr)))
    DimStack([
        DimArray(getfield.(nt_arr, field), dim; name=field)
        for field in fields
    ])
end

function nt2ds(nt_arr; sym=:time)
    dim = Dim{sym}(getfield.(nt_arr, sym))
    # filter the time dimension
    fields = propertynames(first(nt_arr))
    fields = filter(field -> field != sym, fields)
    nt2ds(nt_arr, dim; fields)
end

function rename(da::AbstractDimArray, new_name)
    rebuild(da; name=new_name)
end

function modify_meta(da; kwargs...)
    new_meta = merge(da.metadata, kwargs)
    rebuild(da; metadata=new_meta)
end

"""
    amap(f, a, b)

Apply a function `f` to the intersection of `a` and `b`.

https://github.com/rafaqz/DimensionalData.jl/issues/914
"""
function amap(f, a::AbstractDimArray, b::AbstractDimArray)
    shared_selectors = DimSelectors(a)[DimSelectors(b)]
    f(a[shared_selectors], b[shared_selectors])
end