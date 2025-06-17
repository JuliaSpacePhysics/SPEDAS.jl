# https://dataframes.juliadata.org/stable/man/split_apply_combine/
# https://github.com/JuliaData/SplitApplyCombine.jl

# https://docs.pola.rs/api/python/stable/reference/dataframe/api/polars.DataFrame.group_by_dynamic.html
"""
Group `x` into windows based on `every` and `period`.
"""
function groupby_dynamic(x, every, period = every, start_by = :window)
    min, max = timerange(x)
    group_idx = Vector{UnitRange{Int}}()
    starts = Vector{eltype(x)}()
    current_start = ifelse(start_by == :window, min - mod(min, every), min)
    while current_start <= max
        window_end = current_start + period
        # Find indices of rows that fall in the current window using searchsorted for better performance
        start_idx = searchsortedfirst(x, current_start)
        end_idx = searchsortedfirst(x, window_end) - 1
        if start_idx <= end_idx
            indices = start_idx:end_idx
            push!(group_idx, indices)
            push!(starts, current_start)
        end
        current_start += every
    end
    return group_idx, starts
end

function groupby_dynamic(x::Dimension, args...; kwargs...)
    return groupby_dynamic(parent(lookup(x)), args...; kwargs...)
end

"""
    tgroupby(x::AbstractDimArray, every, period = every, start_by = :window)

Returns a vector of `AbstractDimArray`s grouped by time intervals defined by `every` and `period`.
"""
function tgroupby(x::AbstractDimArray, args...; kwargs...)
    dim = dimnum(x, Ti)
    times = dims(x, Ti)
    group_idx, = groupby_dynamic(times, args...; kwargs...)
    return map(group_idx) do idx
        selectdim(x, dim, idx)
    end
end
