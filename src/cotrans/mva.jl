# Minimum variance analysis
# References:
# - https://github.com/henry2004y/VisAnaJulia/blob/master/src/MVA.jl
# - https://pyspedas.readthedocs.io/en/latest/coords.html#pyspedas.minvar

@inline function sorteigen(F; sortby=abs, rev=true)
    order = sortperm(F.values; rev, by=sortby)
    Eigen(F.values[order], F.vectors[:, order])
end

@views function mva_mat(B::AbstractMatrix, ::Val{N}; sort=(;)) where N
    n = size(B, 1)
    B̄ = SVector{N}(sum(Bc) / n for Bc in eachcol(B))
    M = SMatrix{N,N}(
        B[:, i] ⋅ B[:, j] / n - B̄[i] * B̄[j]
        for i in 1:N, j in 1:N
    )
    sorteigen(eigen(M); sort...)
end

"""
    mva_mat(B::AbstractMatrix; sort=(;), check=false)

Perform minimum variance analysis to generate a LMN coordinate transformation matrix from matrix `B`.

Set `check=true` to check the reliability of the result.

The `k`th eigenvector can be obtained from the slice `F.vectors[:, k]`.
"""
function mva_mat(B::AbstractMatrix; sort=(;), check=false)
    N = size(B, 2)
    F = mva_mat(B, Val(N); sort)
    check && check_mva(F)
    F
end

function mva_mat(B::AbstractMatrix{Q}; kwargs...) where {Q<:Quantity}
    F = mva_mat(ustrip(B); kwargs...)
    Eigen(F.values * unit(Q)^2, F.vectors)
end

"""
    mva(V::AbstractMatrix, B::AbstractMatrix; kwargs...)

Rotate a timeseries `V` into the LMN coordinates based on the reference field `B`.

# Arguments
- `V::AbstractMatrix`: The timeseries data to be transformed, where each column represents a component
- `B::AbstractMatrix`: The reference field used to determine the minimum variance directions, where each column represents a component

See also: [`mva_mat(Bx, By, Bz)`](@ref), [`rotate`](@ref)
"""
function mva(V::AbstractMatrix, B::AbstractMatrix; kwargs...)
    F = mva_mat(B; kwargs...)
    rotate(V, F.vectors)
end

function mva(V::AbstractDimArray, B::AbstractDimArray; new_dim=B_LMN, kwargs...)
    V_mva = mva(V, B.data)
    old_dim = otherdims(V_mva, (Ti, 𝑡))[1]
    set(V_mva, old_dim => new_dim)
end

mva(B) = mva(B, B)

"""
    check_mva_mat(F; r=5, verbose=false)

Check the quality of the MVA result. 

If λ₁ ≥ λ₂ ≥ λ₃ are 3 eigenvalues of the constructed matrix M, then a good
indicator of nice fitting LMN coordinate system should have λ₂ / λ₃ > r.
"""
function check_mva_mat(F; r0=5, verbose=false)
    r = F.values[2] / F.values[3]
    verbose && println(F.vectors)
    verbose && println("Ratio of intermediate variance to minimum variance = ", r)
    if r > r0
        @info "Seems to be a proper MVA attempt!"
    else
        @warn "Take the MVA result with a grain of salt!"
    end
end

function is_right_handed(v1, v2, v3)
    dot(cross(v1, v2), v3) > 0
end

function is_right_handed(F::Eigen)
    vs = F.vectors
    v1 = vs[:, 1]
    v2 = vs[:, 2]
    v3 = vs[:, 3]
    is_right_handed(v1, v2, v3)
end

################
# Error Estimate
################

"""
    Δφij(λᵢ, λⱼ, λ₃, M)

Calculate the phase error between components i and j according to:
|Δφᵢⱼ| = |Δφⱼᵢ| = √(λ₃/(M-1) * (λᵢ + λⱼ - λ₃)/(λᵢ - λⱼ)²)

Parameters:
- λᵢ: eigenvalue i
- λⱼ: eigenvalue j
- λ₃: smallest eigenvalue (λ₃)
- M: number of samples
"""
function Δφij(λᵢ, λⱼ, λ₃, M)
    return sqrt((λ₃ / (M - 1)) * (λᵢ + λⱼ - λ₃) / (λᵢ - λⱼ)^2)
end

"""
Calculate the composite statistical error estimate for ⟨B·x₃⟩:
|Δ⟨B·x₃⟩| = √(λ₃/(M-1) + (Δφ₃₂⟨B⟩·x₂)² + (Δφ₃₁⟨B⟩·x₁)²)

Parameters:
- λ₁, λ₂, λ₃: eigenvalues in descending order
- M: number of samples
- B: mean magnetic field vector
- x₁, x₂, x₃: eigenvectors
"""
function B_x3_error(λ₁, λ₂, λ₃, M, B, x₁, x₂, x₃)
    Δφ₃₂ = Δφij(λ₃, λ₂, λ₃, M)
    Δφ₃₁ = Δφij(λ₃, λ₁, λ₃, M)
    B_x₂ = dot(B, x₂)
    B_x₁ = dot(B, x₁)
    return sqrt(λ₃ / (M - 1) + (Δφ₃₂ * B_x₂)^2 + (Δφ₃₁ * B_x₁)^2)
end

B_x3_error(F::Eigen, M, B) =
    B_x3_error(F.values..., M, B, eachcol(F.vectors)...)