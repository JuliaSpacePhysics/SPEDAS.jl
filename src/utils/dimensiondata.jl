"""
    amap(f, a, b)

Apply a function `f` to the intersection of `a` and `b`.

https://github.com/rafaqz/DimensionalData.jl/issues/914
"""
function amap(f, a::AbstractDimArray, b::AbstractDimArray)
    shared_selectors = DimSelectors(a)[DimSelectors(b)]
    f(a[shared_selectors], b[shared_selectors])
end