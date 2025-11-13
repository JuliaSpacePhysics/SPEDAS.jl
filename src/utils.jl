vectorize(x) = [x]
vectorize(x::AbstractArray) = vec(x)

function stat_relerr(itr, f)
    m = f(itr)
    relerrs = abs.(extrema(itr) .- m) ./ m
    relerr = maximum(relerrs)
    return m, relerr
end

stat_relerr(f) = (x -> stat_relerr(x, f))
mean_relerr(itr) = stat_relerr(itr, mean)

function timedim(x, query = nothing)
    query = something(query, TimeDim)
    qdim = dims(x, query)
    return isnothing(qdim) ? dims(x, 1) : qdim
end

function timedimtype(x; query = TimeDim)
    return DimensionalData.basetypeof(timedim(x, query))
end

times(x) = SpaceDataModel.times(x)
times(x::AbstractDimArray, args...) = lookup(timedim(x, args...))

"""
Convert angular frequency to frequency

Reference: https://www.wikiwand.com/en/articles/Angular_frequency
"""
ω2f(ω) = uconvert(u"Hz", ω, Periodic())

"""Return the angle between two vectors."""
angle(v1::AbstractVector, v2::AbstractVector) = acosd(v1 ⋅ v2 / (norm(v1) * norm(v2)))

"""
    tstack(vectors::AbstractVector{<:AbstractVector{T}})

Stack a time series of `vectors` into a matrix. 

By default, each row in the output matrix represents a time point from the input vector of vectors.
"""
function tstack(vectors::AbstractVector{<:AbstractVector}; kwargs...)
    return stack(vectors; kwargs...)
end

function tstack(vectors::AbstractDimVector{<:AbstractVector}; dims = 1)
    n = length(first(vectors))
    data = stack(parent(vectors); dims)
    new_dims = (dims(vectors, 1), Y(1:n))
    return rebuild(vectors, data, new_dims)
end

"""
Transform matrix-like `A` to `n×m` shape
"""
function ensure_nxm(A, n, m)
    if size(A, 1) == m && size(A, 2) == n
        return permutedims(A)  # Convert from m×n to n×m
    elseif size(A, 1) == n && size(A, 2) == m
        return A  # Already in n×m format
    else
        throw(ArgumentError("A must be either n×m or m×n matrices, but got size $(size(A))"))
    end
end
