tmin(x) = eltype(x) <: AbstractTime ? minimum(x) : error("Element type must be of type Dates.AbstractTime")
tmax(x) = eltype(x) <: AbstractTime ? maximum(x) : error("Element type must be of type Dates.AbstractTime")
tmin(x::AbstractDimArray; query=TimeDim) = tmin(times(x; query))
tmax(x::AbstractDimArray; query=TimeDim) = tmax(times(x; query))
timerange(times) = extrema(times)
timerange(x::AbstractDimArray; query=TimeDim) = timerange(times(x; query))
timerange(x1, xs...; query=TimeDim) = common_timerange(x1, xs...; query)

"""
    common_timerange(arrays; query=timeDimType)

Get the common time range (intersection) across multiple arrays.
If there is no overlap, returns nothing.
"""
function common_timerange(x1, xs...; query=TimeDim)
    _times1 = times(x1; query)
    t0 = tmin(_times1)
    t1 = tmax(_times1)
    for x in xs
        _times = times(x; query)
        t0 = max(t0, tmin(_times))
        t1 = min(t1, tmax(_times))
        t0 > t1 && return nothing
    end
    return t0, t1
end