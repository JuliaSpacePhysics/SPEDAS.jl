# https://docs.sciml.ai/DataInterpolations/stable
# https://github.com/JuliaMath/Interpolations.jl
# https://github.com/rafaqz/DimensionalData.jl/pull/609
using DataInterpolations

function tinterp(A, t)
    u = stack(A.data) # necessary as no method matching zero(::Type{Vector{}})
    DataInterpolations.LinearInterpolation(u, t2x.(dims(A, Ti)))(t2x(t))
end