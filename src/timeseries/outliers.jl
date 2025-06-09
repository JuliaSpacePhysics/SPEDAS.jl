# - [Data Preprocessing - MATLAB](https://www.mathworks.com/help/matlab/preprocessing-data.html?s_tid=CRUX_lftnav)
# - https://www.mathworks.com/help/signal/smoothing-and-denoising.html
# - https://www.mathworks.com/help/matlab/ref/cleanoutlierdata.html

# References
# - [HampelOutliers.jl](https://github.com/tobydriscoll/HampelOutliers.jl)
# - https://www.mathworks.com/help/signal/ref/hampel.html
# - https://github.com/melizalab/quickspikes
# - https://halleysfifthinc.github.io/Peaks.jl/stable/
# - https://pyspedas.readthedocs.io/en/latest/_modules/pytplot/tplot_math/clean_spikes.html
# - https://stackoverflow.com/questions/37556487/remove-spikes-from-signal-in-python
# - https://medium.com/towards-data-science/removing-spikes-from-raman-spectra-a-step-by-step-guide-with-python-b6fd90e8ea77

function outlier_detector(method)
    if method == :median
        return find_outliers_median
    elseif method == :mean
        return find_outliers_mean
    end
end

"""
    find_outliers(A, [method, window]; dim = 1, kw...)

Find outliers in data `A` along the specified `dim` dimension.

Returns a Boolean array whose elements are true when an outlier is detected in the corresponding element of `A`.

The default `method` is `:median` (other option is `:mean`), which uses the median absolute deviation (MAD) to detect outliers.
When the length of `A` is greater than 256, it uses a moving `window` of size 16.

See also: [`find_outliers_median`](@ref), [`find_outliers_mean`](@ref), [isoutlier - MATLAB](https://www.mathworks.com/help/matlab/ref/isoutlier.html)
"""
function find_outliers(A; dim = 1, kw...)
    if size(A, dim) > 256
        window = 16
        return find_outliers(A, :median, window; dim, kw...)
    else
        return find_outliers(A, :median; dim, kw...)
    end
end

function find_outliers(A, method, args...; dim = 1, kw...)
    detector = outlier_detector(method)
    return mapslices(A; dims = dim) do x
        detector(x, args...; kw...)
    end
end

function find_outliers(A::AbstractDimArray, args...; dim = nothing, query = TimeDim, kw...)
    dim = something(dim, dimnum(A, query))
    return find_outliers(parent(A), args...; dim, kw...)
end


"""
    find_outliers_median(x, window; threshold=3)

Find outliers that are defined as elements more than `threshold=3` times the scaled median absolute deviation (MAD) from the median.

When `window` is set to a integer, a moving window of that size is used to compute local MAD.
Otherwise, global statistics are used.

# References
- [Median absolute deviation - Wikipedia](https://en.wikipedia.org/wiki/Median_absolute_deviation)
"""
function find_outliers_median(x::AbstractVector, window; threshold = 3)
    y = falses(length(x))
    n = length(x)
    bsize, fsize = window_bf_sizes(window)
    buffer = similar(x, bsize + fsize + 1) # use buffer to avoid allocations for median calculation
    nan = eltype(x)(NaN)
    for i in eachindex(x, y)
        start_idx = max(1, i - bsize)
        end_idx = min(n, i + fsize)
        N = end_idx - start_idx + 1
        copyto!(buffer, 1, x, start_idx, N)
        buffer[(N + 1):end] .= nan
        med = nanmedian!(buffer)
        buffer .= abs.(buffer .- med)
        mad = nanmedian!(buffer)
        σ = 1.4826 * mad
        y[i] = abs(x[i] - med) > threshold * σ
    end
    return y
end

function find_outliers_median(x::AbstractVector; threshold = 3)
    med = nanmedian(x)
    mad = nanmedian(abs.(x .- med))
    σ = 1.4826 * mad
    return abs.(x .- med) .> threshold * σ
end

"""
    find_outliers_mean(x::AbstractVector, window; threshold = 3)

Find outliers that are defined as elements more than three standard deviations from the mean.

This method is faster but less robust than [`find_outliers_median`](@ref).
"""
function find_outliers_mean(x::AbstractVector, window; threshold = 3)
    y = falses(length(x))
    n = length(x)
    bsize, fsize = window_bf_sizes(window)
    for i in eachindex(x, y)
        start_idx = max(1, i - bsize)
        end_idx = min(n, i + fsize)
        wdata = view(x, start_idx:end_idx)
        mean = nanmean(wdata)
        std = nanstd(wdata; mean = mean)
        y[i] = abs(x[i] - mean) > threshold * std
    end
    return y
end

function find_outliers_mean(x::AbstractVector; threshold = 3)
    mean = nanmean(x)
    std = nanstd(x; mean = mean)
    return abs.(x .- mean) .> threshold * std
end

"""
    replace_outliers!(A, s, [find_method, window]; kwargs...)

Finds outliers in `A` and replaces them with `s` (by default: NaN).

See also: [`find_outliers`](@ref), [filloutliers - MATLAB](https://www.mathworks.com/help/matlab/ref/filloutliers.html)
"""
function replace_outliers!(A, s, args...; kwargs...)
    indices = find_outliers(A, args...; kwargs...)
    A[indices] .= s
    return A
end

replace_outliers!(A, args...; kw...) = replace_outliers!(A, eltype(A)(NaN), args...; kw...)

"""
    interpolate_outliers!(x, t, outliers)

Interpolate outliers in `x` using interpolation of neighboring non-outlier values.
"""
function interpolate_outliers!(x, t, outliers; interp = LinearInterpolation)
    goods = findall(.!outliers)
    interp_obj = interp(x[goods], t[goods])
    for i in eachindex(x, outliers)
        !outliers[i] && continue
        x[i] = interp_obj(t[i])
    end
    return x
end


function replace_outliers_nearest!(x, outliers)
    goods = findall(.!outliers)
    for idx in eachindex(x, outliers)
        !outliers[idx] && continue
        nearest_idx = searchsortednearest(goods, idx)
        x[idx] = x[goods[nearest_idx]]
    end
    return x
end

function _replace_outliers_np!(x, outliers, range_func)
    for i in eachindex(x, outliers)
        !outliers[i] && continue
        rs = range_func(i)
        fidx = findfirst(j -> !outliers[j], rs)
        if !isnothing(fidx)
            x[i] = x[rs[fidx]]
        end
    end
    return x
end

"""
    replace_outliers!(A, method, [find_method, window]; kwargs...)
    replace_outliers!(A, method, outliers; kwargs...)

Replaces outliers in `A` with values determined by the specified `method`.

Outliers can be detected using [`find_outliers`](@ref) with optional `find_method` and `window` parameters or
specified directly as a Boolean array `outliers`.

`method` can be one of the following:
- `:linear`: Linear interpolation of neighboring, nonoutlier values
- `:previous`: Previous nonoutlier value
- `:next`: Next nonoutlier value
- `:nearest`: Nearest nonoutlier value

See also: [filloutliers - MATLAB](https://www.mathworks.com/help/matlab/ref/filloutliers.html)
"""
function replace_outliers!(A, method::Symbol, args...; dim = 1, kwargs...)
    dims = other_dims(A, dim)
    Aslices = eachslice(A; dims)
    foreach(Aslices) do x
        outliers = find_outliers(x, args...; kwargs...)
        _replace_outliers!(x, method, outliers; kwargs...)
    end
    return A
end

function replace_outliers!(A, method::Symbol, outliers::AbstractArray{Bool}; dim = 1, kwargs...)
    dims = other_dims(A, dim)
    Aslices = eachslice(A; dims)
    outlierslices = eachslice(outliers; dims)
    foreach(Aslices, outlierslices) do x, y
        _replace_outliers!(x, method, y; kwargs...)
    end
    return A
end

# Helper function for dispatching to different methods
function _replace_outliers!(x::AbstractVector, method::Symbol, outliers; kwargs...)
    if method == :linear
        t = 1:length(x)
        interpolate_outliers!(x, t, outliers)
    elseif method == :nearest
        replace_outliers_nearest!(x, outliers)
    elseif method == :next
        n = length(x)
        next_range(idx) = (idx + 1):n
        _replace_outliers_np!(x, outliers, next_range)
    elseif method == :previous
        prev_range(idx) = idx:-1:1
        _replace_outliers_np!(x, outliers, prev_range)
    end
    return x
end


"""
    replace_outliers(A; args...; kw...)

Non-mutable version of [`replace_outliers!`](@ref).
"""
replace_outliers(A, args...; kw...) = replace_outliers!(copy(A), args...; kw...)
