export current_density
using Unitful: μ0

include("current_density.jl")
include("unit.jl")

export tlingradest
# Multi-spacecraft analysis
"""
    tlingradest(fields, positions)

Interpolate and Compute spatial derivatives such as grad, div, curl and curvature using reciprocal vector technique.
"""
function tlingradest(fields, positions; flatten = true, kw...)
    return MultiSpacecraftAnalysis.lingradest(tsync(fields..., positions...)...; flatten, kw...)
end


"""
    jparallel(𝐁, curl𝐁)

Calculate the parallel component of current density with respect to magnetic field, given `𝐁` and Curl of magnetic field vector `curl𝐁`.
"""
function jparallel(𝐁, curl𝐁)
    𝐁 = unitify.(SV3(𝐁), u"nT")
    curl𝐁 = unitify.(SV3(curl𝐁), u"nT/km")
    J_parallel = dot(curl𝐁, 𝐁) / norm(𝐁) / μ0
    return J_parallel |> u"nA/m^2"
end

jparallel(B::AbstractMatrix, curl𝐁::AbstractMatrix; dim = 2) = jparallel.(eachslice(B; dims = dim), eachslice(curl𝐁; dims = dim))
