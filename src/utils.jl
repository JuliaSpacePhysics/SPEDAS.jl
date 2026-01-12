"""
Convert angular frequency to frequency

Reference: https://www.wikiwand.com/en/articles/Angular_frequency
"""
ω2f(ω) = uconvert(u"Hz", ω, Periodic())

"""Return the angle between two vectors."""
angle(v1::AbstractVector, v2::AbstractVector) = acosd(v1 ⋅ v2 / (norm(v1) * norm(v2)))

