"""
```math
𝐑 = ∑_α (𝐫_α-𝐫_b) (𝐫_α-𝐫_b)' = ∑_α 𝐫_α 𝐫_α'-𝐫_b 𝐫_b'
```

with ``𝐫_b = ∑_α 𝐫_α / N`` and `N` is the number of positions.

# References
- [paschmannMultispacecraftAnalysisMethods2008](@citet) Paschmann & Daly, 2008. Section 4.7
"""
function position_tensor(rs::AbstractVector{<:AbstractVector})
    rs = rs .- Ref(mean(rs))
    Rall = reduce(hcat, rs)'
    Rall' * Rall
end

"""
    volumetric_tensor(rs::AbstractVector{<:AbstractVector})

``\frac{1}{N} 𝐑'``.

See also: [`position_tensor`](@ref)
"""
volumetric_tensor(rs::AbstractVector{<:AbstractVector}) = position_tensor(rs) / length(rs)

"""Calculate tetrahedron quality factors"""
function tetrahedron_quality(rs::AbstractVector{<:AbstractVector})
    Rvol = volumetric_tensor(rs)
    # Calculate eigenvaluesz and eigenvectors
    F = eigen(ustrip(Rvol), sortby=x -> -abs(x)) # Note: we want descending order
    semiaxes = sqrt.(F.values)  # sqrt of eigenvalues
    eigenvectors = F.vectors
    # Calculate quality parameters
    Qsr = 0.5 * (sum(semiaxes) / semiaxes[1] - 1)
    Elongation = 1 - (semiaxes[2] / semiaxes[1])
    Planarity = 1 - (semiaxes[3] / semiaxes[2])

    return (; det=det(Rvol), semiaxes, Qsr, Elongation, Planarity, eigenvectors)
end