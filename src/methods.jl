function tnorm end

is_spectrogram(ta::AbstractDimArray) = get(ta.metadata, "DISPLAY_TYPE", nothing) == "spectrogram"
is_spectrogram(ta) = false