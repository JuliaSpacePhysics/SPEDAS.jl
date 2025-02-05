function tnorm end

is_spectrogram(ta) = get(ta.metadata, "DISPLAY_TYPE", nothing) == "spectrogram"