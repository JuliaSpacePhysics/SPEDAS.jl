# https://docs.sciml.ai/DataInterpolations/stable
# https://github.com/brendanjohnharris/TimeseriesTools.jl/blob/main/ext/DataInterpolationsExt.jl
# https://github.com/JuliaMath/Interpolations.jl
# https://github.com/rafaqz/DimensionalData.jl/pull/609
# https://discourse.julialang.org/t/interpolating-along-a-single-dimension-of-a-multi-dimensional-array-for-particular-points/29308/3
using DataInterpolations

"""
    tinterp(A, t; interp=LinearInterpolation)

Interpolate time series `A` at time point(s) `t`.
Returns interpolated value for single time point or DimArray for multiple time points.
"""
function tinterp(A, t; interp = nothing, query = nothing)
    interp = something(interp, LinearInterpolation)
    query = something(query, TimeDim)
    dim = dimnum(A, query)
    out = _tinterp(parent(A), parent(lookup(dims(A, dim))), t, interp, dim)
    return if t isa AbstractTime
        out
    else
        newdims = ntuple(i -> i == dim ? Ti(t) : dims(A, i), ndims(A))
        rebuild(A, out, newdims)
    end
end

"""
    tinterp(A, B; interp=LinearInterpolation)

Interpolate `A` to times in `B`
"""
tinterp(A, B::AbstractDimArray; kws...) = tinterp(A, parent(lookup(dims(B, Ti))); kws...)

struct Tinterp{F}
    interp::F
end

# workaround for `Time` type: https://github.com/SciML/DataInterpolations.jl/issues/436
Tinterp(u, t, interp) = Tinterp(interp(u, t))
Tinterp(u, t::AbstractArray{<:AbstractTime}, interp) = Tinterp(u, Dates.value.(t), interp)

(ti::Tinterp)(t) = ti.interp(t)
(ti::Tinterp)(t::AbstractTime) = ti.interp(Dates.value(t))
(ti::Tinterp)(t::AbstractArray{<:AbstractTime}) = @. ti.interp(Dates.value(t))

function _tinterp(A::AbstractArray, t, ts, interp, dim)
    u = eachslice(hybridify(A, dim); dims = dim) # hybridify to reduce memory allocationallocation
    return stack(Tinterp(u, t, interp)(ts); dims = dim)
end

function _tinterp(u::AbstractVector, t, ts, interp, dim)
    @assert dim == 1
    return Tinterp(u, t, interp)(ts)
end


"""
    tsync(A, Bs...)

Synchronize multiple time series to have the same time points.

This function aligns the time series `Bs...` to match the time points of `A` by:
1. Finding the common time range between all input time series
2. Extracting the subset of `A` within this common range
3. Interpolating each series in `Bs...` to match the time points of the subset of `A`

Returns a tuple containing the synchronized time series, with the first element being
the subset of `A` and subsequent elements being the interpolated versions of `Bs...`.

# Examples
```julia
A_sync, B_sync, C_sync = tsync(A, B, C)
```

See also: [`tinterp`](@ref), [`common_timerange`](@ref)
"""
@views function tsync(A, Bs...)
    tr = common_timerange(A, Bs...)
    @assert !isnothing(tr) "No common time range found"
    A_tsync = A[Ti(Between(tr...))]
    return ntuple(1 + length(Bs)) do i
        i == 1 ? A_tsync : tinterp(Bs[i-1], A_tsync)
    end
end

"""
    interpolate_nans(da; interp=LinearInterpolation)

Interpolate only the NaN values in `da` along the specified dimension `dims`.
Non-NaN values are preserved exactly as they are.

The default interpolation method `interp` is `LinearInterpolation`.
"""
function interpolate_nans(u, t; interp = LinearInterpolation)
    # For 1D arrays, directly interpolate the NaN values
    nan_indices = findall(isnan, u)

    if !isempty(nan_indices) && length(nan_indices) < length(u)
        # Find valid (non-NaN) data points
        valid_indices = findall(!isnan, u)
        valid_t = t[valid_indices]
        valid_u = u[valid_indices]
        interp_obj = interp(valid_u, valid_t)

        # Interpolate only at NaN positions
        new_u = deepcopy(u)
        new_u[nan_indices] = interp_obj(t[nan_indices])
        return new_u
    else
        return u
    end
end


function interpolate_nans(u, t::AbstractArray{<:AbstractTime}; kwargs...)
    return interpolate_nans(u, Dates.value.(t); kwargs...)
end

"""
    tinterp_nans(da::AbstractDimArray; query=timeDimType, kwargs...)

Interpolate only the NaN values in `da` along the specified dimensions `query`.
Non-NaN values are preserved exactly as they are.

See also [`interpolate_nans`](@ref)
"""
function tinterp_nans(da::AbstractDimArray; query = timeDimType, kwargs...)
    u = parent(da)
    dim = timedim(da; query)
    t = parent(lookup(dim))
    new_data = mapslices(u; dims = dimnum(da, dim)) do slice
        interpolate_nans(slice, t; kwargs...)
    end
    return rebuild(da; data = new_data)
end

function workload_interp_setup(n = 4)
    # Create arrays with different time ranges
    times1 = DateTime(2020, 1, 1) + Day.(0:n-1)
    times2 = DateTime(2020, 1, 2) + Day.(0:n-1)
    times3 = DateTime(2020, 1, 1, 12) + Day.(0:n-2)

    # Create DimArrays with different data and time dimensions
    da1 = DimArray(1:n, (Ti(times1),))
    da2 = DimArray(10:10+n-1, (Ti(times2),))
    da3 = DimArray(hcat(5:5+n-2, 8:2:8+2n-4), (Ti(times3), Y([1, 2])))
    return da1, da2, da3
end

function workload_interp()
    da1, da2, da3 = workload_interp_setup()
    return tsync(da1, da2, da3)
end
