# - [PySPEDAS : pytplot.tplot_math.dpwrspc](https://pyspedas.readthedocs.io/en/latest/pytplot.html#dynamic-power-spectrum)
# - https://pyspedas.readthedocs.io/en/latest/pytplot.html#dynamic-power-spectrum-of-tplot-variable

export pspectrum

"""
    pspectrum(x::AbstractDimArray, spec::Spectrogram)
    pspectrum(x::AbstractDimArray; nfft=256, noverlap=128, window=hamming)

Compute the power spectrum (time-frequency representation) of a time series using the short-time Fourier transform.

Returns a `DimArray` with frequency and original time dimensions.

See also: `DSP.Spectrogram`, `DSP.stft`

# Reference
- [Matlab](https://www.mathworks.com/help/signal/ref/pspectrum.html)
"""
function pspectrum(x::AbstractDimArray, spec::Spectrogram; name="Power")
    fs = samplingrate(x) |> ustrip
    y = tfd(ustrip(x), spec; fs)
    t0 = DateTime(SpaceTools.times(x)[1])
    times = Ti(y.time .* 1u"s" .+ t0)
    freqs = 𝑓(y.freq * 1u"Hz")
    metadata = Dict(:DISPLAY_TYPE => "spectrogram", :scale => log10)
    y_da = DimArray(permutedims(y.power), (times, freqs); name, metadata)
end

function pspectrum(x::AbstractDimArray; nfft=256, noverlap=128, window=hamming)
    spec = Spectrogram(nfft, noverlap, window)
    pspectrum(x, spec)
end