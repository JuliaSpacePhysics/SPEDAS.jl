function get_data end

function tnorm end

isspectrogram(ta::AbstractDimArray) = prioritized_get(ta, ("DISPLAY_TYPE", :DISPLAY_TYPE), nothing) == "spectrogram"
isspectrogram(ta) = false

function spectrogram_y_values(ta; check=false)
    if haskey(ta.metadata, "axes")
        values = ta.metadata["axes"][2].values
        if check
            all(allequal, eachcol(values)) || @warn "Spectrogram y-axis values are not constant along time"
        end
        return mean(values, dims=1) |> vec
    else
        return dims(ta, 2).val
    end
end