tmin(x) = eltype(x) <: AbstractTime ? minimum(x) : error("Element type must be of type Dates.AbstractTime")
tmax(x) = eltype(x) <: AbstractTime ? maximum(x) : error("Element type must be of type Dates.AbstractTime")
tmin(x::AbstractDimArray; query=TimeDim) = tmin(times(x; query))
tmax(x::AbstractDimArray; query=TimeDim) = tmax(times(x; query))


timerange(times) = _extrema(times)

_extrema(x) = extrema(x)
function _extrema(x::Array{T}) where {T <: Union{Date, DateTime, Int}}
    return reinterpret.(T, vextrema(reinterpret(Int, x)))
end

timerange(times::DimensionalData.Sampled) = timerange(parent(times))
timerange(times::Dimension) = timerange(parent(times))
timerange(x::AbstractDimArray) = timerange(times(x))
timerange(x1, xs...) = common_timerange(x1, xs...)

"""
    common_timerange(arrays)

Get the common time range (intersection) across multiple arrays.
If there is no overlap, returns nothing.
"""
function common_timerange(x1, xs...)
    t0, t1= timerange(x1)
    for x in xs
        _t0, _t1 = timerange(x)
        t0 = max(t0, _t0)
        t1 = min(t1, _t1)
        t0 > t1 && return nothing
    end
    return t0, t1
end