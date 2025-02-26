function get_data end

"""
    spectrogram_y_values(ta; check=false, center=false, transform=identity)

Get y-axis values from a spectrogram array.
Can return either bin centers or edges. By default, return bin edges for better compatibility.

# Arguments
- `check`: If true, check if values are constant along time
- `center`: If true, return bin centers instead of edges
- `transform`: Optional transform function for edge calculation (e.g., log for logarithmic bins)
"""
function spectrogram_y_values(ta; check=false, center=false, transform=yscale(ta))
    metadata = meta(ta)
    centers = if haskey(metadata, "axes")
        values = metadata["axes"][2].values
        if isa(values, AbstractVector)
            values
        elseif isa(values, AbstractMatrix)
            if check
                all(allequal, eachcol(values)) || @warn "Spectrogram y-axis values are not constant along time"
            end
            mean(values, dims=2)
        end
    else
        dims(ta, 2).val
    end
    !center ? binedges(centers; transform) : centers
end