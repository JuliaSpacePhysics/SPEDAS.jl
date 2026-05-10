# - [Spectrogram Computation with Signal Processing Toolbox - MATLAB &amp; Simulink](https://www.mathworks.com/help/signal/ug/spectrogram-computation-with-signal-processing-toolbox.html)
# - [SignalDecomposition.jl](https://juliadynamics.github.io/SignalDecomposition.jl/dev/)
# - [PySPEDAS : pytplot.tplot_math.dpwrspc](https://pyspedas.readthedocs.io/en/latest/pytplot.html#dynamic-power-spectrum)
# - https://pyspedas.readthedocs.io/en/latest/utilities.html#dynamic-power-spectrum-of-tplot-variable

export pspectrum

_seconds(dt::Dates.Period) = Dates.seconds(dt)
_seconds(dt) = dt
_timebins(t0::Dates.TimeType, seconds) = Nanosecond.(round.(Int, 1e9 .* seconds)) .+ t0
_timebins(t0, seconds) = seconds .+ t0

function pspectrum(x::AbstractVector, times; nfft = 256, noverlap = div(nfft, 2), window = hamming)
    dt = resolution(times)
    fs = inv(_seconds(dt))
    y = spectrogram(x, nfft, noverlap; fs, window)
    time = _timebins(times[1], y.time)
    return (power = y.power, time, freq = y.freq)
end

function pspectrum(x::AbstractDimVector; name = :power, metadata = Dict("DISPLAY_TYPE" => "spectrogram", :scale => log10, :ylabel => "Frequency (Hz)"), kwargs...)
    ts = times(x)
    y = pspectrum(parent(x), ts; kwargs...)
    t_dim = Ti(y.time)
    f_dim = Z(y.freq)
    return DimArray(y.power, (f_dim, t_dim); name, metadata)
end

"""
    pspectrum(x::AbstractDimArray; nfft=256, noverlap=128, window=hamming)

Compute the power spectrum (time-frequency representation) of a time series using the short-time Fourier transform.

Returns a `DimArray` with frequency and original time dimensions.

Defaults to a Hamming window to preserve SPEDAS behavior.

See also: `DSP.spectrogram`, `DSP.stft`

# Reference
- [Matlab](https://www.mathworks.com/help/signal/ref/pspectrum.html)
"""
function pspectrum(x::AbstractDimArray; query = Ti, kwargs...)
    dims = otherdims(x, query)
    specs = map(eachslice(x; dims)) do slice
        pspectrum(slice; kwargs...)
    end
    return cat(specs...; dims)
end
