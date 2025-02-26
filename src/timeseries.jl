function timeshift(ta; dim=1, t0=nothing)
    td = dims(ta, dim)
    times = td.val.data
    t0 = something(t0, times[1])

    new_dim_name = Symbol("Time after ", t0)
    new_dim = Dim{new_dim_name}(times .- t0)

    DimArray(ta.data, (new_dim, otherdims(ta, dim)...), name=ta.name, metadata=ta.metadata)
end

function resolution(times; tol=2)
    dt = diff(times)
    dt0 = eltype(dt)(1)
    dtf_mean, relerr = mean_relerr(dt ./ dt0)
    if relerr > exp10(-tol - 1)
        @warn "Time resolution is is not approximately constant (relerr ≈ $relerr)"
    end
    round(Integer, dtf_mean) * dt0
end

resolution(da::AbstractDimType; dim=Ti, kwargs...) =
    resolution(dims(da, dim).val; kwargs...)

samplingrate(da) = 1u"s" / resolution(da) * u"Hz" |> u"Hz"


"""
    smooth(da::AbstractDimArray, window; dim=Ti, suffix="_smoothed", kwargs...)

Smooths a time series by computing a moving average over a sliding window.

The size of the sliding `window` can be either:
  - `Quantity`: A time duration that will be converted to number of samples based on data resolution
  - `Integer`: Number of samples directly

# Arguments
- `dims=Ti`: Dimension along which to perform smoothing (default: time dimension)
- `suffix="_smoothed"`: Suffix to append to the variable name in output
- `kwargs...`: Additional arguments passed to `RollingWindowArrays.rolling`
"""
smooth(da::AbstractDimArray, window::Quantity; kwargs...) = smooth(da, convert(Integer, window / resolution(da)); kwargs...)

function smooth(da::AbstractDimArray, window::Integer; dims=Ti, suffix="_smoothed", kwargs...)
    new_da = mapslices(da; dims) do slice
        mean.(RollingWindowArrays.rolling(slice, window; kwargs...))
    end
    rebuild(new_da; name=Symbol(da.name, suffix))
end

"""
References
- https://docs.juliadsp.org/stable/filters/
- https://www.mathworks.com/help/signal/ref/filtfilt.html
- https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.filtfilt.html

Issues
- DSP.jl and Unitful.jl: https://github.com/JuliaDSP/DSP.jl/issues/431
"""
function DSP.filtfilt(da::AbstractDimArray, Wn1, Wn2; designmethod=Butterworth(2))
    fs = samplingrate(da)
    Wn1, Wn2, fs = (Wn1, Wn2, fs) ./ 1u"Hz" .|> NoUnits
    f = digitalfilter(Bandpass(Wn1, Wn2; fs), designmethod)
    res = filtfilt(f, ustrip(da))
    rebuild(da; data=res * (da |> eltype |> unit))
end

"""
    dropna(da::DimArray, query)

Remove slices containing NaN values along dimensions other than `query`.
"""
function dropna(da::DimArray, query)
    valid_idx = .!vec(any(isnan, da; dims=otherdims(da, query)))
    dim = dims(da, query)
    selector = DimSelectors(dim[valid_idx])
    da[selector]
end

dropna(da::DimArray; query=Ti) = dropna(da, query)

"""Rectify the time step of a `DimArray` to be uniform."""
function rectify_datetime(da; tol=2, kwargs...)
    times = dims(da, Ti)
    t0 = times[1]
    dtime = Quantity.(times.val .- t0)
    new_times = TimeseriesTools.rectify(Ti(dtime); tol)[1]
    set(da, Ti => new_times .+ t0)
end

"""
    tsplit(da::AbstractDimArray, dim=Ti)

Splits up data along dimension `dim`.
"""
function tsplit(da::AbstractDimArray, dim=Ti; new_names=labels(da))
    odims = otherdims(da, dim)
    rows = eachslice(da; dims=odims)
    das = map(rows, new_names) do row, name
        rename(modify_meta(row; long_name=name), name)
    end
    DimStack(das...)
end