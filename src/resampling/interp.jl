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
tinterp(A, t; interp=LinearInterpolation) = _tinterp(A, t; interp)

"""
    tinterp(A, B; interp=LinearInterpolation)

Interpolate `A` to times in `B`
"""
tinterp(A, B::AbstractDimArray; kwargs...) = _tinterp(A, dims(B, Ti); kwargs...)

function _tinterp(A::T, t; interp=LinearInterpolation) where {T<:AbstractDimVector}
    u = stack(parent(A)) # necessary as no method matching zero(::Type{Vector{}})
    out = interp(u, t2x.(dims(A, Ti)))(t2x.(t))
    t isa DateTime && return out
    data = ndims(out) == 1 ? out : eachcol(out)
    return DimArray(data, tdim(t); name=A.name, metadata=A.metadata)
end

function _tinterp(A::T, t; interp=LinearInterpolation) where {T<:AbstractDimMatrix}
    u = permutedims(A.data)
    out = interp(u, t2x.(dims(A, Ti)))(t2x.(t))
    t isa DateTime && return out
    data = permutedims(out)
    newdims = (tdim(t), otherdims(A, Ti)...)
    return DimArray(data, newdims; name=A.name, metadata=A.metadata)
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