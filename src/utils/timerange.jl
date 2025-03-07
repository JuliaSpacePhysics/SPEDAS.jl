# https://github.com/JuliaIntervals
# https://github.com/JuliaIntervals/IntervalArithmetic.jl
# https://github.com/invenia/Intervals.jl
# https://github.com/JuliaMath/IntervalSets.jl


# Iterable but not broadcastable
using Intervals: Bound, AbstractInterval, Closed

struct TimeRange{T,L<:Bound,R<:Bound} <: AbstractInterval{T,L,R}
    first::T
    last::T
end

TimeRange{T}(f, l) where {T} = TimeRange{T,Closed,Closed}(f, l)
TimeRange(f::T, l::T) where {T} = TimeRange{T}(f, l)

function Base.iterate(S::TimeRange, state=1)
    state > 2 && return nothing
    state == 1 && return S.first, 2
    state == 2 && return S.last, 3
end
Base.size(S::TimeRange) = (2,)
Base.length(S::TimeRange) = 2
function Base.getindex(S::TimeRange, i::Int)
    i == 1 && return S.first
    i == 2 && return S.last
    throw(BoundsError(S, i))
end
Base.lastindex(S::TimeRange) = 2

timerange(first, last) = Interval(first, last)
timerange(first::AbstractString, last::AbstractString) = Interval(DateTime(first), DateTime(last))
timerange(trange) = timerange(first(trange), last(trange))