# https://github.com/JuliaIntervals
# https://github.com/JuliaIntervals/IntervalArithmetic.jl
# https://github.com/invenia/Intervals.jl
# https://github.com/JuliaMath/IntervalSets.jl

timerange(first, last) = Interval(first, last)
timerange(first::AbstractString, last::AbstractString) = Interval(DateTime(first), DateTime(last))
timerange(trange) = timerange(first(trange), last(trange))