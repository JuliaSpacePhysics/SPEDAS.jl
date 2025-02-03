function mean_relerr(itr)
    x_mean = mean(itr)
    relerrs = abs.(extrema(itr) .- x_mean) ./ x_mean
    relerr = maximum(relerrs)
    return x_mean, relerr
end

function prioritized_get(c, keys, default)
    values = get.(Ref(c), keys, nothing)
    something(values..., default)
end

function modify_meta(da; kwargs...)
    new_meta = merge(da.metadata, kwargs)
    rebuild(da; metadata=new_meta)
end

function Base.rename(da::AbstractDimArray, new_name)
    rebuild(da; name=new_name)
end

f2time(x, t0) = string(Millisecond(round(x)) + t0)

xs(ta::DimArray, t0) = (dims(ta, 1).val.data .- t0) ./ Millisecond(1)
ys(ta::DimArray) = permutedims(ustrip(ta.data))