# https://github.com/JuliaData/DataFrames.jl/issues/2738
# https://github.com/JuliaAPlavin/FlexiJoins.jl

"""
    fill_gaps(times, data; resolution, margin)

Given a sorted vector of time stamps `times` and corresponding data `values`,
this function inserts missing time stamps with a value of `NaN` if the gap between
consecutive time stamps is larger than `resolution + margin`.

- If the gap is only slightly larger (within `margin` of the resolution),
  no gap is inserted.
- The function supports numeric times or DateTime (with appropriate resolution types).

# Arguments
- `times`: Sorted vector of time stamps.
- `resolution`: The expected time difference between consecutive time stamps.
- `margin`: Allowed deviation from `resolution` before inserting missing time stamps.

# Returns
A tuple `(full_times, full_values)` where:
- `full_times` is a vector containing all time stamps (original and inserted).
- `full_values` is a vector of data values with `NaN` for inserted gaps.

# References
- https://pyspedas.readthedocs.io/en/latest/_modules/pytplot/tplot_math/degap.html
"""
function fill_gaps(times::AbstractVector{T}, values; resolution=resolution(times), margin=div(resolution, 20)) where {T}
    # Ensure times are sorted. If not, sort them along with values.
    sorted_idx = sortperm(times)
    times = times[sorted_idx]
    values = values[sorted_idx]

    full_times = T[]
    full_values = Float64[]

    # Start with the first time stamp.
    push!(full_times, times[1])
    push!(full_values, values[1])
    last_time = times[1]

    # Iterate over the remaining time stamps.
    for (t, v) in zip(times[2:end], values[2:end])
        # Insert gap values if the gap is larger than resolution + margin.
        while t > last_time + resolution + margin
            gap_time = last_time + resolution
            push!(full_times, gap_time)
            push!(full_values, NaN)
            last_time = gap_time
        end
        # Append the actual recorded time and value.
        push!(full_times, t)
        push!(full_values, v)
        last_time = t
    end
    return full_times, full_values
end


fill_gaps(da::AbstractDimArray) = fill_gaps(times(da), da.data)