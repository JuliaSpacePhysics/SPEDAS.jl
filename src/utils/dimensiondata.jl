using DimensionalData.Lookups

const timeDimType = (Dim{:time}, Ti)

meta(da::AbstractDimArray) = metadata(da)

function standardize(x::AbstractDimArray; floatify=true)
    # Convert integer values to floats
    floatify && eltype(x) <: Integer && (x = modify(float, x))
    # Check if any of the dimensions match our time dimension types
    x = any(d -> d isa Dim{:time}, dims(x)) ? set(x, Dim{:time} => Ti) : x
end
tdim(t) = Ti(t)
tdim(t::DD.Dimension) = t

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
modify_meta(da::AbstractDimArray, args...; kwargs...) = rebuild(da; metadata=_new_metadata(da.metadata, args...; kwargs...))
modify_meta(args...; kwargs...) = da -> modify_meta(da, args...; kwargs...)

"""
    amap(f, a, b)

Apply a function `f` to the intersection of `a` and `b`.

https://github.com/rafaqz/DimensionalData.jl/issues/914
"""
function amap(f, a::AbstractDimArray, b::AbstractDimArray)
    shared_selectors = DimSelectors(a)[DimSelectors(b)]
    f(a[shared_selectors], b[shared_selectors])
end