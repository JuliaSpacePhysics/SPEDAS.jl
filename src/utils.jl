function donothing(args...; kwargs...) end

function mean_relerr(itr)
    x_mean = mean(itr)
    relerrs = abs.(extrema(itr) .- x_mean) ./ x_mean
    relerr = maximum(relerrs)
    return x_mean, relerr
end

function prioritized_get(c, keys, default)
    values = get.(Ref(c), keys, nothing)
    all(isnothing, values) ? default : something(values...)
end

prioritized_get(c::AbstractDimArray, keys, default) = prioritized_get(c.metadata, keys, default)

f2time(x, t0) = string(Millisecond(round(x)) + t0)

times(x::DimArray; query=(Ti, Dim{:time})) = lookup(dims(x, query)[1])

# hack as `Makie` does not support `NanoDate` directly
function xs(da::AbstractDimArray)
    x = lookup(dims(da, 1)) |> parent
    eltype(x) == NanoDate ? DateTime.(x) : x
end
xs(ta::DimArray, t0) = (dims(ta, 1).val.data .- t0) ./ Millisecond(1)
ys(ta::DimArray) = ta.data
"""permutedims is needed for `series` in Makie"""
ys(ta::DimMatrix) = permutedims(ta.data)
vs(ta::DimArray) = ta.data

"""
Convert angular frequency to frequency

Reference: https://www.wikiwand.com/en/articles/Angular_frequency
"""
ω2f(ω) = uconvert(u"Hz", ω, Periodic())

"""
Convert x to DateTime

Reference:
- https://docs.makie.org/dev/explanations/dim-converts#Makie.DateTimeConversion
- https://github.com/MakieOrg/Makie.jl/issues/442
- https://github.com/MakieOrg/Makie.jl/blob/master/src/dim-converts/dates-integration.jl
"""
x2t(x::Millisecond) = DateTime(Dates.UTM(x))
x2t(x::Float64) = DateTime(Dates.UTM(round(Int64, x)))

t2x(t::DateTime) = Dates.value(t)
t2x(da::AbstractDimArray) = t2x.(dims(da, 1).val.data)

"""Return the angle between two vectors."""
Base.angle(v1::AbstractVector, v2::AbstractVector) = acosd(v1 ⋅ v2 / (norm(v1) * norm(v2)))

"""
    tstack(vectors::AbstractVector{<:AbstractVector{T}})

Stack a time series of `vectors` into a matrix. 

By default, each row in the output matrix represents a time point from the input vector of vectors.
"""
function tstack(vectors::AbstractVector{<:AbstractVector})
    return stack(vectors)
end

function tstack(vectors::DD.AbstractDimVector{<:AbstractVector})
    n = length(first(vectors))
    data = stack(vectors; dims=1)
    new_dims = (dims(vectors)..., Y(1:n))
    return DimArray(data, new_dims; name=vectors.name, metadata=vectors.metadata)
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