# https://github.com/JuliaIntervals
# https://github.com/JuliaIntervals/IntervalArithmetic.jl
# https://github.com/invenia/Intervals.jl
# https://github.com/JuliaMath/IntervalSets.jl

# Iterable but not broadcastable
using Intervals: Bound, AbstractInterval, Closed

struct TimeRange{T, L <: Bound, R <: Bound} <: AbstractInterval{T, L, R}
    first::T
    last::T
end

TimeRange{T}(f, l) where {T} = TimeRange{T, Closed, Closed}(f, l)
TimeRange(f::T, l::T) where {T} = TimeRange{T}(f, l)

function Base.iterate(S::TimeRange, state = 1)
    state > 2 && return nothing
    state == 1 && return S.first, 2
    return state == 2 && return S.last, 3
end
Base.size(S::TimeRange) = (2,)
Base.length(S::TimeRange) = 2
function Base.getindex(S::TimeRange, i::Int)
    i == 1 && return S.first
    i == 2 && return S.last
    throw(BoundsError(S, i))
end
Base.lastindex(S::TimeRange) = 2

timerange(t0::AbstractTime, t1::AbstractTime) = minmax(t0, t1)
timerange(t0::AbstractString, t1::AbstractString) = timerange(t0, DateTime(t1))
timerange(t0::AbstractString, t1) = timerange(DateTime(t0), t1)
timerange(t0, t1::AbstractString) = timerange(t0, DateTime(t1))

function _find_continuous_timeranges(times, max_dt)
    # Initialize variables
    ranges = NTuple{2, eltype(times)}[]
    range_start = times[1]

    for i in 2:length(times)
        current_time = times[i]
        prev_time = times[i - 1]
        # If gap is too large, end the current range and start a new one
        if current_time - prev_time > max_dt
            push!(ranges, (range_start, prev_time))
            range_start = current_time
        end
    end
    # Add the last range
    push!(ranges, (range_start, times[end]))
    return ranges
end

"""
    find_continuous_timeranges(x, max_dt)

Find continuous time ranges for `x` (e.g. times or `DimArray`). `max_dt` is the maximum time gap between consecutive times.
"""
function find_continuous_timeranges(x, max_dt)
    isempty(x) && return []
    ts = eltype(x) <: AbstractTime ? x : times(x)
    return issorted(ts) ?
           _find_continuous_timeranges(ts, max_dt) :
           _find_continuous_timeranges(sort(ts), max_dt)
end
