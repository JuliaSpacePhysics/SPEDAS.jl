# References
# - https://github.com/melizalab/quickspikes
# - https://halleysfifthinc.github.io/Peaks.jl/stable/
# - https://pyspedas.readthedocs.io/en/latest/_modules/pytplot/tplot_math/clean_spikes.html
# - https://stackoverflow.com/questions/37556487/remove-spikes-from-signal-in-python
# - https://medium.com/towards-data-science/removing-spikes-from-raman-spectra-a-step-by-step-guide-with-python-b6fd90e8ea77

"""
    find_spikes(data; threshold=3.0, window=0)

Identifies indices in `data` that are considered spikes

For multidimensional arrays, the function can be applied along a specific dimension using the `dims` parameter.

# Arguments
- `threshold`: Threshold multiplier for MAD to identify spikes (default: 3.0)
- `window`: Size of the moving window for local statistics (default: 16)
- `dims`: Dimension along which to find spikes (for multidimensional arrays)

# Returns
- For 1D arrays: Vector of indices where spikes were detected
- For multidimensional arrays: Dictionary mapping dimension indices to spike indices

See also: [`find_spikes_1d_mad`](@ref)
"""
function find_spikes(data; detector=find_spikes_1d_mad, threshold=3.0, window::Int=16, dims=nothing)
    # Handle 1D arrays (original functionality)
    if dims === nothing || ndims(data) == 1
        return detector(data; threshold, window)
    end

    # Handle multidimensional arrays
    result = Dict{Int,Vector{Int}}()

    # Get the size of the array along the specified dimension
    dim_size = size(data, dims)

    # Create a view for each slice along the specified dimension
    for i in 1:dim_size
        # Create selector for the current slice
        selector = [j == dims ? i : Colon() for j in 1:ndims(data)]

        # Extract the slice
        slice = view(data, selector...)

        # Find spikes in the slice
        spike_indices = detector(slice; threshold=threshold, window=window)

        # Store the result if spikes were found
        if !isempty(spike_indices)
            result[i] = spike_indices
        end
    end

    return result
end

"""
    find_spikes_1d_mad(data; threshold=3.0, window=0)

Identifies indices in `data` that are considered spikes based on a `threshold`
multiplier of the median absolute deviation (MAD).

When `window` is set to a positive integer, a moving window of that size is used to compute local MAD.
Otherwise, global statistics are used.

# References
- [Wikipedia](https://en.wikipedia.org/wiki/Median_absolute_deviation)
"""
function find_spikes_1d_mad(data; threshold=3.0, window::Int=16)
    spike_indices = Int[]
    n = length(data)

    if window <= 0  # use global statistics
        med = NaNMath.median(data)
        mad = NaNMath.median(abs.(data .- med)) + eps()  # add eps() to avoid zero MAD
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
            window_data = @view data[start_idx:end_idx]
            med_local = NaNMath.median(window_data)
            mad_local = NaNMath.median(abs.(window_data .- med_local)) + eps()
            if abs(data[i] - med_local) > threshold * mad_local
                push!(spike_indices, i)
            end
        end
    end
    return spike_indices
end

find_spikes_1d_mad(data::AbstractArray{Q}; kwargs...) where {Q<:Quantity} = find_spikes_1d_mad(ustrip(data); kwargs...)

"""
    replace_outliers(data; detector=find_spikes, replacement_fn=nothing, kwargs...)

Replaces outliers in `data` using `replacement_fn`.

A `detector` function (by default, `find_spikes`) is used to identify outlier indices. 

A `replacement_fn` function can be supplied to define how to correct each spike: 
- It should takes `(data, index)` and returns a replacement value;
- If not provided, the default is to replace with NaN.

For multidimensional arrays, the `dims` parameter specifies the dimension along which to detect and replace outliers.

See also: [`find_spikes`](@ref)
"""
function replace_outliers(data::AbstractArray{Q}; detector=find_spikes, replacement_fn=nothing, dims=nothing, kwargs...) where {Q}

    # Get outlier indices
    indices = detector(data; dims, kwargs...)

    # Create a copy of the data for modification
    cleaned_data = deepcopy(data)

    # Handle 1D arrays (original functionality)
    if dims === nothing || ndims(data) == 1
        for i in indices
            if replacement_fn !== nothing
                cleaned_data[i] = replacement_fn(data, i)
            else
                cleaned_data[i] = NaN * oneunit(Q)
            end
        end
    else
        # Handle multidimensional arrays
        for (dim_idx, spike_indices) in indices
            # Create selector for the current slice
            for i in spike_indices
                # Create full index for the spike
                full_idx = [j == dims ? dim_idx : (j == 1 ? i : 1) for j in 1:ndims(data)]

                if replacement_fn !== nothing
                    # Create a view for the slice to pass to replacement_fn
                    selector = [j == dims ? dim_idx : Colon() for j in 1:ndims(data)]
                    slice = view(data, selector...)
                    cleaned_data[full_idx...] = replacement_fn(slice, i)
                else
                    cleaned_data[full_idx...] = NaN * oneunit(Q)
                end
            end
        end
    end

    return cleaned_data
end