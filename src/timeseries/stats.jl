# Reference: 
# - [NaNStatistics.jl](https://github.com/brenhinkeller/NaNStatistics.jl)
# - [VectorizedStatistics.jl](https://github.com/JuliaSIMD/VectorizedStatistics.jl)
# - [Average of Dates · Issue · JuliaLang/julia](https://github.com/JuliaLang/julia/issues/54542)

@inline function stat1d(f, x, index, dt, dim)
    group_idx, idxs = groupby_dynamic(index, dt)
    out = mapslices(x; dims = dim) do slice
        map(group_idx) do idx
            f(view(slice, idx))
        end
    end
    return out, idxs
end


"""
    tstat(f, x, [dt]; dim = nothing)

Calculate the statistic `f` of `x` along the `dim` dimension, optionally grouped by `dt`.

See also: [`groupby_dynamic`](@ref)
"""
function tstat end

function tstat(f, x; dim = nothing, query = nothing)
    dim = @something dim dimnum(x, something(query, TimeDim))
    return ndims(x) == 1 ? f(x) : f(x; dim)
end

function tstat(f, x, dt; dim = nothing, query = nothing)
    dim = @something dim dimnum(x, something(query, TimeDim))
    tdim = dims(x, dim)
    out, idxs = stat1d(f, parent(x), tdim, dt, dim)
    newdims = ntuple(ndims(x)) do i
        i == dim ? basetypeof(tdim)(idxs) : dims(x, i)
    end
    return DimArray(out, newdims; metadata = metadata(x))
    # alternative slower method
    # f.(groupby(x, Dim => gfunc); dim = dimnum(x, query))
end

function tstat(f, ds::DimStack, args...; query = nothing, dim = nothing)
    dim = @something dim dimnum(ds, something(query, TimeDim))
    return maplayers(ds) do layer
        tstat(f, layer, args...; dim)
    end
end


tstat_doc(sym, desc = sym) = """
    $(Symbol(:t, sym))(x; dim=nothing, query=nothing)

Calculate the $desc of `x` along the `dim` dimension.

It returns a value if `x` is a vector along the `dim` dimension, otherwise returns a `DimArray` with the specified dimension dropped.

If `dim` is not specified, it defaults to the `query` dimension (dimension of type `TimeDim` by default).
"""


for (sym, desc) in (
        (:sum, "sum"),
        (:mean, "arithmetic mean"),
        (:median, "median"),
        (:var, "variance"),
        (:std, "standard deviation"),
        (:sem, "standard error of the mean"),
    )

    nanfunc = Symbol(:nan, sym)
    tfunc = Symbol(:t, sym)
    doc = tstat_doc(sym, desc)
    @eval @doc $doc $tfunc(x, arg...; kw...) = tstat($nanfunc, x, arg...; kw...)
end
