export current_density

include("current_density.jl")

export tlingradest

# Check if all time series have identical timestamps.
function have_same_timestamps(data...)
    length(data) <= 1 && return true
    ref_times = times(first(data))
    return all(d -> times(d) == ref_times, data[2:end])
end

"""
    tlingradest(fields, positions)

Interpolate and Compute spatial derivatives such as grad, div, curl and curvature using reciprocal vector technique.
"""
function tlingradest(fields, positions; flatten = true, kw...)
    all_data = (fields..., positions...)

    return have_same_timestamps(all_data...) ?
        lingradest(all_data...; flatten, kw...) :
        lingradest(tsync(all_data...)...; flatten, kw...)
end
