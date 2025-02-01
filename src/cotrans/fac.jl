# References
# - https://github.com/henry2004y/VisAnaJulia/blob/master/src/MFA.jl

"""
    fac_mat(vec::AbstractVector; xref=[1.0, 0.0, 0.0])

Generates a field-aligned coordinate (FAC) transformation matrix for a vector.

# Arguments
- `vec`: A 3-element vector representing the magnetic field
"""
function fac_mat(
    vec::AbstractVector;
    xref=[1.0, 0.0, 0.0]
)
    z0 = normalize(vec)
    y0 = normalize(cross(z0, xref))
    x0 = cross(y0, z0)
    # Build 3x3 transformation matrix
    return vcat(x0', y0', z0')
end