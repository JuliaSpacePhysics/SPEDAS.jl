function tnorm(x; dims=Ti)
    norm.(eachslice(x; dims))
end

"""

References:
- https://docs.xarray.dev/en/stable/generated/xarray.cross.html
"""
function tcross(x, y; dims=Ti)
    cross.(eachslice(x; dims), eachslice(y; dims))
end

function tdot(x, y; dims=Ti)
    dot.(eachslice(x; dims), eachslice(y; dims))
end

norm_combine(x; dims=1) = cat(x, norm.(eachslice(x; dims)); dims=setdiff(1:ndims(x), dims))

"""
    tnorm_combine(x; dims=Ti, name=:magnitude)

Calculate the norm of each slice along dimension `dims` and combine it with the original components.
"""
function tnorm_combine(x; dims=Ti, name=:magnitude)
    new_x = norm_combine(x.data; dims=dimnum(x, dims))

    # Replace the original dimension with our new one that includes the magnitude
    odim = otherdims(x, dims) |> only
    odimType = basetypeof(odim)
    new_odim = odimType(vcat(odim.val, name))
    new_dims = map(d -> d isa odimType ? new_odim : d, DD.dims(x))
    return DimArray(new_x, new_dims)
end