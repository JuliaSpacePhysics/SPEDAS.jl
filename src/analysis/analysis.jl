export current_density

include("current_density.jl")

export tlingradest
# Multi-spacecraft analysis
"""
    tlingradest(fields, positions)

Interpolate and Compute spatial derivatives such as grad, div, curl and curvature using reciprocal vector technique.
"""
function tlingradest(fields, positions; flatten = true, kw...)
    return MultiSpacecraftAnalysis.lingradest(tsync(fields..., positions...)...; flatten, kw...)
end