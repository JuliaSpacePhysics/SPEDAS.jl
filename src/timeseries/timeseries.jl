using VectorizedStatistics

# Time operations
export tclip, tclips, tview, tviews, tmask, tmask!, tsort, tshift
# Linear Algebra
export proj, sproj, oproj
export tdot, tcross, tnorm, tproj, tsproj, toproj
export tgroupby
# Statistics
export tsum, tmean, tmedian, tstd, tsem, tvar
# Derivatives
export tderiv, tsubtract

export find_outliers, replace_outliers!, replace_outliers

include("operations.jl")
include("groupby.jl")
include("reduce.jl")
include("stats.jl")
include("methods.jl")
include("lazyoperations.jl")
include("outliers.jl")
include("utils.jl")

"""
    tderiv(data, times; dims = 1)

Compute the time derivative of `data` with respect to `times`.
"""
function tderiv(data::AbstractArray{T,N}, times; dims=1) where {T,N}
    # return diff(data; dims) ./ diff(times) # this allocates and is slow
    Base.require_one_based_indexing(data)
    1 <= dims <= N || throw(ArgumentError("dimension $dims out of range (1:$N)"))

    r = Base.axes(data)
    r0 = ntuple(i -> i == dims ? UnitRange(1, last(r[i]) - 1) : UnitRange(r[i]), N)
    r1 = ntuple(i -> i == dims ? UnitRange(2, last(r[i])) : UnitRange(r[i]), N)
    rt0 = r0[dims]
    rt1 = r1[dims]

    return (view(data, r1...) .- view(data, r0...)) ./ (view(times, rt1) .- view(times, rt0))
end

"""
    tderiv(data; dims = Ti)

Compute the time derivative of `data`.

See also: [deriv_data - PySPEDAS](https://pyspedas.readthedocs.io/en/latest/_modules/pyspedas/analysis/deriv_data.html)
"""
tderiv(data; dims=Ti) = diff(data; dims) ./ diff(times(data))

function resolution(times; tol=2, f=stat_relerr(median))
    dt = diff(times)
    dt0 = eltype(dt)(1)
    dt_m, relerr = f(dt ./ dt0)
    if relerr > exp10(-tol - 1)
        @warn "Time resolution is is not approximately constant (relerr ≈ $relerr)"
    end
    round(Integer, dt_m) * dt0
end

resolution(da::AbstractDimType; kwargs...) =
    resolution(times(da); kwargs...)

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
smooth(da::AbstractDimArray, window::Quantity; kwargs...) = smooth(da, Integer(div(window, resolution(da))); kwargs...)

function smooth(da::AbstractDimArray, window::Integer; dims=Ti, suffix="_smoothed", kwargs...)
    new_da = mapslices(da; dims) do slice
        mean.(RollingWindowArrays.rolling(slice, window; kwargs...))
    end
    rebuild(new_da; name=Symbol(da.name, suffix))
end

"""
    tfilter(da, Wn1, Wn2=samplingrate(da) / 2; designmethod=Butterworth(2))

By default, the max frequency corresponding to the Nyquist frequency is used.

References
- https://docs.juliadsp.org/stable/filters/
- https://www.mathworks.com/help/signal/ref/filtfilt.html
- https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.filtfilt.html

Issues
- DSP.jl and Unitful.jl: https://github.com/JuliaDSP/DSP.jl/issues/431
"""
function tfilter(da::AbstractDimArray, Wn1, Wn2=0.999 * samplingrate(da) / 2; designmethod=Butterworth(2))
    fs = samplingrate(da)
    Wn1, Wn2, fs = (Wn1, Wn2, fs) ./ 1u"Hz" .|> NoUnits
    f = digitalfilter(Bandpass(Wn1, Wn2; fs), designmethod)
    res = filtfilt(f, ustrip(parent(da)))
    rebuild(da; data=res * (da |> eltype |> unit))
end


"""
    dropna(da::DimArray, query)

Remove slices containing NaN values along dimensions other than `query`.
"""
function dropna(da::DimArray, query)
    valid_idx = vec(all(!isnan, da; dims=otherdims(da, query)))
    da[query(valid_idx)]
end

dropna(da::DimArray; query=Ti) = dropna(da, query)

function rectify(ts::DimensionalData.Dimension; tol=4, atol=nothing)
    u = unit(eltype(ts))
    ts = collect(ts)
    stp = ts |> diff |> mean
    err = ts |> diff |> std
    tol = Int(tol - round(log10(stp |> ustripall)))

    if isnothing(atol) && ustripall(err) > exp10(-tol - 1)
        @warn "Step $stp is not approximately constant (err=$err, tol=$(exp10(-tol-1))), skipping rectification"
    else
        if !isnothing(atol)
            tol = atol
        end
        stp = u == NoUnits ? round(stp; digits=tol) : round(u, stp; digits=tol)
        t0, t1 = u == NoUnits ? round.(extrema(ts); digits=tol) :
                 round.(u, extrema(ts); digits=tol)
        ts = range(start=t0, step=stp, length=length(ts))
    end
    return ts
end

"""Rectify the time step of a `DimArray` to be uniform."""
function rectify_datetime(da; tol=2, kwargs...)
    times = dims(da, Ti)
    t0 = times[1]
    dtime = Quantity.(times.val .- t0)
    new_times = rectify(Ti(dtime); tol)
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

for f in (:smooth, :tfilter)
    @eval $f(args...; kwargs...) = da -> $f(da, args...; kwargs...)
end