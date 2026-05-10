# Code to be deprecated

# Return the angle between two vectors
angle(v1::AbstractVector, v2::AbstractVector) = acosd(v1 ⋅ v2 / (norm(v1) * norm(v2)))
