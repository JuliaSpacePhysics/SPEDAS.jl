function tnorm end

is_spectrogram(ta::AbstractDimArray) = get(ta.metadata, "DISPLAY_TYPE", nothing) == "spectrogram"
is_spectrogram(ta) = false

function spectrogram_y_values(ta; check=false)
    values = ta.metadata["axes"][2].values
    if check
        all(allequal, eachcol(values)) || @warn "Spectrogram y-axis values are not constant along time"
    end
    mean(values, dims=1) |> vec
end