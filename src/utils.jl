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

f2time(x, t0) = string(Millisecond(round(x)) + t0)

function timedim(x; query=TimeDim)
    qdim = dims(x, query)
    isnothing(qdim) ? dims(x, 1) : qdim
end

function timedimtype(x; query=TimeDim)
    DimensionalData.basetypeof(timedim(x; query))
end

times(x::AbstractDimArray; query=TimeDim) = lookup(timedim(x; query))
times(x) = x
ys(ta::DimArray) = ta.data
"""permutedims is needed for `series` in Makie"""
ys(ta::DimMatrix) = permutedims(ta.data)
vs(ta::DimArray) = ta.data

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

function tstack(vectors::AbstractDimVector{<:AbstractVector}; dims=1)
    n = length(first(vectors))
    data = stack(parent(vectors); dims)
    new_dims = (dims(vectors, 1), Y(1:n))
    return rebuild(vectors, data, new_dims)
end

"https://github.com/JuliaLang/julia/issues/54542"
tmean(vec::AbstractVector{DateTime}) = convert(Dates.DateTime, Millisecond(mean(Dates.value.(vec))))

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


"""
    _linear_binedges(centers)

Calculate bin edges assuming linear spacing.
"""
function _linear_binedges(centers)
    N = length(centers)
    edges = Vector{eltype(centers)}(undef, N + 1)

    # Calculate internal edges
    for i in 2:N
        edges[i] = (centers[i-1] + centers[i]) / 2
    end

    # Calculate first and last edges using the same spacing as adjacent bins
    edges[1] = centers[1] - (edges[2] - centers[1])
    edges[end] = centers[end] + (centers[end] - edges[end-1])

    return edges
end

"""
    binedges(centers; transform=identity)

Calculate bin edges from bin centers. 
- For linear spacing, edges are placed halfway between centers.
- For transformed spacing, edges are placed halfway between transformed centers.

# Arguments
- `transform`: Function to transform the space (e.g., log for logarithmic spacing)

# Example
```julia
centers = [1.0, 2.0, 3.0]
edges = binedges(centers)               # Returns [0.5, 1.5, 2.5, 3.5]
edges = binedges(centers, transform=log)  # Returns edges in log space
```
"""
function binedges(centers; transform=identity)
    N = length(centers)
    N < 2 && throw(ArgumentError("Need at least 2 bin centers to calculate edges"))
    if transform === identity || transform === nothing
        return _linear_binedges(centers)
    else
        # Work in transformed space
        transformed = transform.(centers)
        transformed_edges = _linear_binedges(transformed)
        return inverse(transform).(transformed_edges)
    end
end

function binedges(centers::AbstractVector{Q}; kwargs...) where {Q<:Quantity}
    return binedges(ustrip(centers); kwargs...) * unit(Q)
end