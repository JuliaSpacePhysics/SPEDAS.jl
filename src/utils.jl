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
