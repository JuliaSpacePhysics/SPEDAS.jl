# https://docs.sciml.ai/DataInterpolations/stable
# https://github.com/brendanjohnharris/TimeseriesTools.jl/blob/main/ext/DataInterpolationsExt.jl
# https://github.com/JuliaMath/Interpolations.jl
# https://github.com/rafaqz/DimensionalData.jl/pull/609
using DataInterpolations

"""
    tinterp(A, t; interp=LinearInterpolation)

Interpolate time series `A` at time point(s) `t`.
Returns interpolated value for single time point or DimArray for multiple time points.
"""
tinterp(A, t, interp=LinearInterpolation) = _tinterp(A, t, interp)

"""
    tinterp(A, B, interp=LinearInterpolation)

Interpolate `A` to times in `B`
"""
tinterp(A, B::AbstractDimArray, interp=LinearInterpolation; kwargs...) = _tinterp(A, dims(B, Ti), interp; kwargs...)

struct Tinterp{F}
    interp::F
end

Tinterp(u, t, interp) = Tinterp(interp(u, t))
Tinterp(u, t::AbstractArray{<:AbstractTime}, interp) = Tinterp(u, Dates.value.(t), interp)
Tinterp(A::AbstractDimArray, interp) = Tinterp(parent(A), parent(dims(A, Ti)), interp)

(ti::Tinterp)(t) = ti.interp(t)
(ti::Tinterp)(t::AbstractTime) = ti.interp(Dates.value(t))
(ti::Tinterp)(t::AbstractArray{<:AbstractTime}) = @. ti.interp(Dates.value(t))

function _tinterp(A::T, t, interp) where {T<:AbstractDimVector}
    out = Tinterp(A, interp)(t)
    t isa AbstractTime ? out : rebuild(A, out, (Ti(t),))
end

function _tinterp(A::T, ts, interp) where {T<:AbstractDimMatrix}
    _times = parent(parent(dims(A, Ti)))
    out = stack(Tinterp(eachrow(parent(A)), _times, interp)(ts); dims=1)
    ts isa AbstractTime ? out : rebuild(A, out, (Ti(ts), dims(A, 2)))
end

"""
    interpolate_nans(da; interp=LinearInterpolation)

Interpolate only the NaN values in `da` along the specified dimension `dims`.
Non-NaN values are preserved exactly as they are.

The default interpolation method `interp` is `LinearInterpolation`.
"""
function interpolate_nans(u, t; interp=LinearInterpolation)
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


function interpolate_nans(u, t::AbstractArray{<:Dates.AbstractDateTime}; kwargs...)
    interpolate_nans(u, t2x.(t); kwargs...)
end

"""
    tinterp_nans(da::AbstractDimArray; query=timeDimType, kwargs...)

Interpolate only the NaN values in `da` along the specified dimensions `query`.
Non-NaN values are preserved exactly as they are.

See also [`interpolate_nans`](@ref)
"""
function tinterp_nans(da::AbstractDimArray; query=timeDimType, kwargs...)
    u = parent(da)
    dim = timedim(da; query)
    t = parent(lookup(dim))
    new_data = mapslices(u; dims=dimnum(da, dim)) do slice
        interpolate_nans(slice, t; kwargs...)
    end
    return rebuild(da; data=new_data)
end