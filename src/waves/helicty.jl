"""
Phase factor `exp (i φ)` satisfies the following equation

``\\exp (4 i φ) = \\exp (-2 i γ)``

where

``γ = \\arctan (2 Re(𝐮)^𝐓 Im(𝐮) /(Re(𝐮)^2-Im(𝐮)^2))``
"""
@inline function phase_factor(u)
    Re = real(u)
    Im = imag(u)
    upper = 2 * Re ⋅ Im
    lower = Re ⋅ Re - Im ⋅ Im
    γ = atan(upper, lower)
    exp(-im * γ / 2)
end

"""
    wpol_helicity(S, waveangle)

Compute helicity and ellipticity for a single frequency.

# Arguments
- `S`: Spectral matrix for a single frequency, size (3,3)
- `waveangle`: Wave normal angle for this frequency

# Returns
- `helicity`: Average helicity across the three components
- `ellipticity`: Average ellipticity across the three components
"""
function wpol_helicity(S::AbstractMatrix{ComplexF64}, waveangle::Number)
    # Preallocate arrays for 3 polarization components
    helicity = 0
    ellipticity = 0
    lam_u = MVector{3,ComplexF64}(undef)

    for comp in 1:3
        # Build state vector λ_u for this polarization component
        alph = sqrt(real(S[comp, comp]))
        lam_u[comp] = alph
        if comp == 1
            lam_u[2] = (real(S[1, 2]) / alph) + im * (-imag(S[1, 2]) / alph)
            lam_u[3] = (real(S[1, 3]) / alph) + im * (-imag(S[1, 3]) / alph)
        elseif comp == 2
            lam_u[1] = (real(S[2, 1]) / alph) + im * (-imag(S[2, 1]) / alph)
            lam_u[3] = (real(S[2, 3]) / alph) + im * (-imag(S[2, 3]) / alph)
        else
            lam_u[1] = (real(S[3, 1]) / alph) + im * (-imag(S[3, 1]) / alph)
            lam_u[2] = (real(S[3, 2]) / alph) + im * (-imag(S[3, 2]) / alph)
        end

        # Compute the phase rotation (gammay) for this state vector
        lam_y = phase_factor(lam_u) * lam_u

        # Helicity: ratio of the norm of the imaginary part to the real part
        norm_real = norm(real(lam_y))
        norm_imag = norm(imag(lam_y))
        helicity += norm_imag / norm_real / 3

        # For ellipticity, use only the first two components
        u1 = lam_y[1]
        u2 = lam_y[2]

        # TODO: why there is no 2 in front of uppere?
        uppere = imag(u1) * real(u1) + imag(u2) * real(u2)
        lowere = (-imag(u1)^2 + real(u1)^2 - imag(u2)^2 + real(u2)^2)
        gammarot = atan(uppere, lowere)
        p_rot = exp(-1im * 0.5 * gammarot)
        lam_urot = SA[p_rot*u1, p_rot*u2]

        num = norm(imag(lam_urot))
        den = norm(real(lam_urot))
        ellip_val = (den != 0) ? num / den : NaN
        # Adjust sign using the off-diagonal of ematspec and the wave normal angle
        sign_factor = sign(imag(S[1, 2]) * sin(waveangle))
        ellipticity += ellip_val * sign_factor / 3
    end
    return helicity, ellipticity
end