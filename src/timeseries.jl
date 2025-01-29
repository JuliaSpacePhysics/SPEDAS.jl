using RollingWindowArrays

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


function smooth(da::AbstractDimArray, span::Integer; dim=Ti, suffix="_smoothed", kwargs...)
    new_da = mapslices(da, dims=dim) do slice
        mean.(RollingWindowArrays.rolling(slice, span; kwargs...))
    end
    rebuild(new_da; name=Symbol(da.name, suffix))
end