function tstat(f, x::AbstractDimVector; query = TimeDim)
    if dimnum(x, query) == 1
        f(x)
    else
        @error "x is not a vector along the $query dimension"
    end
end

tstat(f, x; query = TimeDim) = f(x; dim = dimnum(x, query))

"""
    tmean(x; query=TimeDim)

Calculate the mean of `x` along the `query` dimension (default: `TimeDim`).

It returns a value if `x` is a vector along the `query` dimension, otherwise returns a `DimArray` with the specified dimension dropped.
"""
tmean(x; query = TimeDim) = tstat(nanmean, x; query)

tmedian(x; query = TimeDim) = tstat(nanmedian, x; query)

"""
    tsubtract(x, f=nanmedian; dims=timedim(x))

Subtract a statistic (default function `f`: `nanmedian`) along dimensions (default: time dimension) from `x`.
"""
function tsubtract(x, f = nanmedian; dims = timedim(x))
    x .- f(parent(x); dims = dimnum(x, dims))
end

function tnorm(x; dims = nothing)
    dims = something(dims, TimeDim)
    norm.(eachslice(x; dims))
end

"""
    proj(a, b)

Vector projection of a vector `a` on (or onto) a nonzero vector `b`.

# References: [Wikipedia](https://en.wikipedia.org/wiki/Vector_projection)

See also: [`sproj`](@ref), [`oproj`](@ref)
"""
function proj(a, b)
    b̂ = normalize(ustrip(b))
    return dot(a, b̂) * b̂
end

"""
Scalar projection
"""
function sproj(a, b)
    return dot(a, b) / norm(b)
end

function tsproj(a, b; dims = TimeDim)
    sproj.(eachslice(a; dims), eachslice(b; dims))
end

function tproj(a, b; dims = TimeDim)
    proj.(eachslice(a; dims), eachslice(b; dims))
end

"""
Vector rejection
"""
oproj(a, b) = a - proj(a, b)

function toproj(a, b; dims = TimeDim)
    res = oproj.(eachslice(a; dims), eachslice(b; dims))
    tstack(res)
end

"""
    tcross(x, y; dims=TimeDim, stack=nothing)

Compute the cross product of two (arrays of) vectors along the `dims` dimension.

References:

  - https://docs.xarray.dev/en/stable/generated/xarray.cross.html
"""
function tcross(x, y; dims = TimeDim, stack = nothing)
    stack = @something stack (ndims(x)==2)
    res = cross.(eachslice(x; dims), eachslice(y; dims))
    stack ? tstack(res) : res
end

"""
    tdot(x, y; dims=TimeDim)

Dot product of two arrays `x` and `y` along the `dims` dimension.
"""
function tdot(x, y; dims = TimeDim)
    dot.(eachslice(x; dims), eachslice(y; dims))
end

function norm_combine(x; dims = 1)
    cat(x, norm.(eachslice(x; dims)); dims = setdiff(1:ndims(x), dims))
end

"""
    tnorm_combine(x; dims=timedim(x), name=:magnitude)

Calculate the norm of each slice along `query` dimension and combine it with the original components.
"""
function tnorm_combine(x; dims = timedim(x), name = :magnitude)
    data = norm_combine(parent(x); dims = dimnum(x, dims))

    # Replace the original dimension with our new one that includes the magnitude
    odim = otherdims(x, dims) |> only
    odimType = basetypeof(odim)
    new_odim = odimType(vcat(odim.val, name))
    new_dims = map(d -> d isa odimType ? new_odim : d, DD.dims(x))
    return rebuild(x, data, new_dims)
end

for f in (:tsubtract,)
    @eval $f(args...; kwargs...) = x -> $f(x, args...; kwargs...)
end