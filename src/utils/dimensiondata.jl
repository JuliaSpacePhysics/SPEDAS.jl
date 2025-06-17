using DimensionalData.Lookups
using HybridArrays

const timeDimType = (DimensionalData.TimeDim, Dim{:time})

function hybridify(A, dims)
    sizes = ntuple(ndims(A)) do i
        i in dims ? StaticArrays.Dynamic() : size(A, i)
    end
    HybridArray{Tuple{sizes...}}(A)
end

function hybridify(A::AbstractDimArray, dim)
    rebuild(A, hybridify(parent(A), dim))
end

hybridify(A; query=nothing) = 
    hybridify(A, dimnum(A, something(query, TimeDim)))

function standardize(x::AbstractDimArray; floatify=true)
    # Convert integer values to floats
    floatify && eltype(x) <: Integer && (x = modify(float, x))
    # Check if any of the dimensions match our time dimension types
    x = any(d -> d isa Dim{:time}, dims(x)) ? set(x, Dim{:time} => Ti) : x
end
tdim(t) = Ti(t)
tdim(t::DD.Dimension) = t

function tvec(A::AbstractDimArray; query=nothing)
    dim = timedim(A, query)
    DimArray(vec(parent(A)), dim; metadata=meta(A), name=name(A))
end

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

"""
    dimarrayify(x)

Convert `x` or values of `x` to `DimArray(s)`.
"""
dimarrayify(x::AbstractDimArray) = x
dimarrayify(x) = DimArray(x)
dimarrayify(nt::NamedTuple{keys}) where {keys} = NamedTuple{keys}(DimArray.(values(nt)))
dimarrayify(d::Dict) = Dict(k => DimArray(v) for (k, v) in d)


function rename(da::AbstractDimArray, new_name)
    rebuild(da; name=new_name)
end

function _new_metadata(meta, args::Pair...; kwargs...)
    # Create a dictionary from both positional pair arguments and keyword arguments
    added_meta = merge(Dict(args...), kwargs)
    meta isa NoMetadata ? added_meta : merge(meta, added_meta)
end

modify_meta!(da; kwargs...) = (da.metadata = _new_metadata(da.metadata; kwargs))
function modify_meta(da::Union{AbstractDimArray,AbstractDimStack}, args...; kwargs...)
    rebuild(da; metadata=_new_metadata(meta(da), args...; kwargs...))
end
modify_meta(args...; kwargs...) = da -> modify_meta(da, args...; kwargs...)

# similar to DataAPI.metadata!
function set_meta!(d::AbstractDict, args::Pair...; kwargs...)
    for (k, v) in args
        d[k] = v
    end
    merge!(d, kwargs)
end

set_meta!(x::AbstractDimArray, args...; kwargs...) = (set_meta!(meta(x), args...; kwargs...); x)
set_meta!(args...; kwargs...) = x -> set_meta!(x, args...; kwargs...)
const set_meta = modify_meta
    
"""
    amap(f, a, b)

Apply a function `f` to the intersection of `a` and `b`.

https://github.com/rafaqz/DimensionalData.jl/issues/914
"""
function amap(f, a::AbstractDimArray, b::AbstractDimArray)
    shared_selectors = DimSelectors(a)[DimSelectors(b)]
    f(a[shared_selectors], b[shared_selectors])
end