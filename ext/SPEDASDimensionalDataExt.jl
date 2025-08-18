using DimensionalData

function mva_eigen(A::AbstractDimArray; dim = nothing, query = nothing, kw...)
    dim = @something dim _dimnum(A, query)
    return mva_eigen(parent(A); dim, kw...)
end