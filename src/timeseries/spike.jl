# References
# - https://github.com/melizalab/quickspikes
# - https://pyspedas.readthedocs.io/en/latest/_modules/pytplot/tplot_math/clean_spikes.html
# - https://stackoverflow.com/questions/37556487/remove-spikes-from-signal-in-python

"""
    find_spikes(data; threshold=3.0, window=0)

Identifies indices in `data` that are considered spikes based on a `threshold`
multiplier of the median absolute deviation (MAD).

When `window` is set to a positive integer, a moving window of that size is used to compute local MAD.
Otherwise, global statistics are used.

# References
- [Wikipedia](https://en.wikipedia.org/wiki/Median_absolute_deviation)
"""
function find_spikes(data; threshold=3.0, window::Int=16)
    spike_indices = Int[]
    n = length(data)

    if window <= 0  # use global statistics
        med = median(data)
        mad = median(abs.(data .- med)) + eps()  # add eps() to avoid zero MAD
        for i in 1:n
            if abs(data[i] - med) > threshold * mad
                push!(spike_indices, i)
            end
        end
    else  # use a moving window
        half_window = window ÷ 2
        for i in 1:n
            start_idx = max(1, i - half_window)
            end_idx = min(n, i + half_window)
            window_data = data[start_idx:end_idx]
            med_local = median(window_data)
            mad_local = median(abs.(window_data .- med_local)) + eps()
            if abs(data[i] - med_local) > threshold * mad_local
                push!(spike_indices, i)
            end
        end
    end
    return spike_indices
end

"""
    replace_outliers(data; detector=find_spikes, detect=(;), replacement_fn=nothing)

Replaces outliers in `data` using `replacement_fn`.

A `detector` function (by default, `find_spikes`) is used to identify outlier indices. 

A `replacement_fn` function can be supplied to define how to correct each spike: 
- It should takes `(data, index)` and returns a replacement value;
- If not provided, the default is to replace with NaN.

See also: [`find_spikes`](@ref)
"""
function replace_outliers(data; detector=find_spikes, detect=(;), replacement_fn=nothing)
    indices = detector(data; detect...)
    cleaned_data = deepcopy(data)
    for i in indices
        if replacement_fn !== nothing
            cleaned_data[i] = replacement_fn(data, i)
        else
            cleaned_data[i] = NaN
        end
    end
    return cleaned_data
end