function get_data end

function y_values(x)
    metadata = meta(x)
    if haskey(metadata, "axes")
        varAxis = metadata["axes"][2]
        varAxis.values
        # varAxis.values * unit(varAxis)
    else
        lookup(dims(x, 2))
    end
end

"""
    spectrogram_y_values(ta; check=false, center=false, transform=identity)

Get y-axis values from a spectrogram array.
Can return either bin centers or edges. By default, return bin edges for better compatibility.

# Arguments
- `check`: If true, check if values are constant along time
- `center`: If true, return bin centers instead of edges
- `transform`: Optional transform function for edge calculation (e.g., log for logarithmic bins)

Reference: Makie.edges
"""
function spectrogram_y_values(ta; check=false, center=true, transform=yscale(ta))
    centers = y_values(ta)

    if isa(centers, AbstractMatrix)
        if check
            all(allequal, eachcol(centers)) || @warn "Spectrogram y-axis values are not constant along time"
        end
        centers = vec(mean(centers; dims=1))
    end

    if center && transform == log10
        edges = binedges(centers)
        if first(edges) < zero(eltype(edges)) || last(edges) < zero(eltype(edges))
            @warn "Automatically using edge for Makie because transform == $transform and the first edge is negative"
            center = false
        end
    end

    !center ? binedges(centers; transform) : centers
end