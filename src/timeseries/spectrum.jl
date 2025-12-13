# - [Spectrogram Computation with Signal Processing Toolbox - MATLAB &amp; Simulink](https://www.mathworks.com/help/signal/ug/spectrogram-computation-with-signal-processing-toolbox.html)
# - [SignalDecomposition.jl](https://juliadynamics.github.io/SignalDecomposition.jl/dev/)
# - [PySPEDAS : pytplot.tplot_math.dpwrspc](https://pyspedas.readthedocs.io/en/latest/pytplot.html#dynamic-power-spectrum)
# - https://pyspedas.readthedocs.io/en/latest/utilities.html#dynamic-power-spectrum-of-tplot-variable

export pspectrum

function pspectrum(x::AbstractVector, times, spec::Spectrogram; name=:power, metadata=Dict("DISPLAY_TYPE" => "spectrogram", :scale => log10, :ylabel => "Frequency (Hz)"))
    fs = samplingrate(times) |> ustrip
    y = tfd(ustrip(x), spec; fs)
    t0 = DateTime(times[1])
    t_dim = Ti(y.time .* 1u"s" .+ t0)
    f_dim = Z(y.freq)
    DimArray(permutedims(y.power), (t_dim, f_dim); name, metadata)
end

"""
    pspectrum(x::AbstractDimArray, spec::Spectrogram)
    pspectrum(x::AbstractDimArray; nfft=256, noverlap=128, window=hamming)

Compute the power spectrum (time-frequency representation) of a time series using the short-time Fourier transform.

Returns a `DimArray` with frequency and original time dimensions.

See also: `DSP.Spectrogram`, `DSP.stft`

# Reference
- [Matlab](https://www.mathworks.com/help/signal/ref/pspectrum.html)
"""
function pspectrum(x::AbstractDimVector, spec::Spectrogram; kwargs...)
    return pspectrum(x, times(x), spec; kwargs...)
end

function pspectrum(x::AbstractDimArray, spec::Spectrogram; query=Ti, kwargs...)
    ts = times(x)
    dims = otherdims(x, query)
    specs = map(eachslice(x; dims)) do slice
        pspectrum(slice, ts, spec; kwargs...)
    end
    cat(specs...; dims)
end

function pspectrum(x::AbstractDimArray; nfft=256, noverlap=div(nfft, 2), window=hamming)
    spec = Spectrogram(nfft, noverlap, window)
    pspectrum(x, spec)
end