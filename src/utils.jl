function mean_relerr(itr)
    x_mean = mean(itr)
    relerrs = abs.(extrema(itr) .- x_mean) ./ x_mean
    relerr = maximum(relerrs)
    return x_mean, relerr
end

function prioritized_get(c, keys, default)
    values = get.(Ref(c), keys, nothing)
    something(values..., default)
end

prioritized_get(c::AbstractDimArray, keys, default) = prioritized_get(c.metadata, keys, default)

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

function Base.rename(da::AbstractDimArray, new_name)
    rebuild(da; name=new_name)
end

f2time(x, t0) = string(Millisecond(round(x)) + t0)

xs(ta::DimArray, t0) = (dims(ta, 1).val.data .- t0) ./ Millisecond(1)
ys(ta::DimArray) = ustrip(ta.data)
ys(ta::DimMatrix) = permutedims(ustrip(ta.data))
vs(ta::DimMatrix) = ustrip(ta.data)

"""
Convert angular frequency to frequency

Reference: https://www.wikiwand.com/en/articles/Angular_frequency
"""
ω2f(ω) = uconvert(u"Hz", ω, Periodic())

"""
Convert x to DateTime

Reference:
- https://docs.makie.org/dev/explanations/dim-converts#Makie.DateTimeConversion
- https://github.com/MakieOrg/Makie.jl/issues/442
- https://github.com/MakieOrg/Makie.jl/blob/master/src/dim-converts/dates-integration.jl
"""
x2t(x::Millisecond) = DateTime(Dates.UTM(x))
x2t(x::Float64) = DateTime(Dates.UTM(round(Int64, x)))

t2x(t::DateTime) = Dates.value(t)
t2x(da::AbstractDimArray) = t2x.(dims(da, 1).val.data)

"""Return the angle between two vectors."""
Base.angle(v1::AbstractVector, v2::AbstractVector) = acosd(v1 ⋅ v2 / (norm(v1) * norm(v2)))