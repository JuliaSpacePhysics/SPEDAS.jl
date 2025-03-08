# polarisation analysis 
# https://github.com/spedas/bleeding_edge/blob/master/general/science/wavpol/twavpol.pro
# https://github.com/spedas/bleeding_edge/blob/master/general/science/wavpol/wavpol.pro
# https://pyspedas.readthedocs.io/en/latest/_modules/pyspedas/analysis/twavpol.html
# https://github.com/spedas/pyspedas/blob/master/pyspedas/analysis/twavpol.py

struct StokesVector{T}
    S0::T
    S1::T
    S2::T
    S3::T
end

"""
    polarization(S0, S1, S2, S3)
    polarization(S::StokesVector)

Compute the degree of polarization (p) from Stoke parameters or a Stokes vector.

# Reference
- [Wikipedia](https://en.wikipedia.org/wiki/Polarization_(waves))
- [Stokes parameters](https://en.wikipedia.org/wiki/Stokes_parameters)
"""
function polarization(S0, S1, S2, S3)
    return sqrt(S1^2 + S2^2 + S3^2) / S0
end

polarization(S::StokesVector) = polarization(S.S0, S.S1, S.S2, S.S3)

"""
    polarization(S)

Compute the degree of polarization (DOP) `p^2` from spectral matrix `S`.

```math
\\begin{aligned}
p^2  &= 1-\\frac{(tr 𝐒)^2-(tr 𝐒^2)}{(tr 𝐒)^2-n^{-1}(tr 𝐒)^2} \\\\
    &= \\frac{n(tr 𝐒^2)-(tr 𝐒)^2}{(n-1)(tr 𝐒)^2}
\\end{aligned}
```
"""
function polarization(S)
    n = size(S, 1)
    trS2 = tr(S * S)
    trS = tr(S)
    (n * trS2 - trS^2) / ((n - 1) * trS^2)
end

"""
Phase factor `exp (i φ)` satisfies the following equation

``\\exp (4 i φ) = \\exp (-2 i γ)``

where

``γ = \\arctan (2 Re(𝐮)^𝐓 Im(𝐮) /(Re(𝐮)^2-Im(𝐮)^2))``
"""
function phase_factor(u)
    Re, Im = reim(u)
    upper = 2Re'Im
    lower = Re'Re - Im'Im
    γ = atan(upper, lower)
    exp(-im * γ / 2)
end

"""
Wave normal angle is the angle between (wnx, wny) and the vertical |wnz|
Use the imaginary parts of off-diagonals.
Define:``A = Im(S₁₂), B = Im(S₁₃), C = Im(S₂₃)``
"""
function wave_normal_angle(S)
    A = imag(S[1, 2])
    B = imag(S[1, 3])
    C = imag(S[2, 3])
    aaa2 = sqrt(A^2 + B^2 + C^2)
    if aaa2 != 0
        # Normalize contributions to get directional cosines.
        wnx = abs(C / aaa2)
        wny = -abs(B / aaa2)
        wnz = A / aaa2
        atan(sqrt(wnx^2 + wny^2), abs(wnz))
    else
        NaN
    end
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
    helicity_comps = zeros(Float64, 3)
    ellip_comps = zeros(Float64, 3)

    lam_u = zeros(ComplexF64, 3)

    for comp in 1:3
        # Build state vector λ_u for this polarization component
        alph = sqrt(real(S[comp, comp]))
        alph == 0.0 && continue

        # Reset vectors to avoid carrying over values
        fill!(lam_u, 0.0)
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
        helicity_comps[comp] = (norm_imag != 0) ? norm_imag / norm_real : NaN

        # For ellipticity, use only the first two components
        u1 = lam_y[1]
        u2 = lam_y[2]

        # TODO: why there is no 2 in front of uppere?
        uppere = imag(u1) * real(u1) + imag(u2) * real(u2)
        lowere = (-imag(u1)^2 + real(u1)^2 - imag(u2)^2 + real(u2)^2)
        gammarot = atan(uppere, lowere)
        lam_urot = exp(-1im * 0.5 * gammarot) * [u1, u2]

        num = norm(imag(lam_urot))
        den = norm(real(lam_urot))
        ellip_val = (den != 0) ? num / den : NaN
        # Adjust sign using the off-diagonal of ematspec and the wave normal angle
        sign_factor = sign(imag(S[1, 2]) * sin(waveangle))
        ellip_comps[comp] = ellip_val * sign_factor
    end

    # Average the three computed values
    helicity = mean(helicity_comps)
    ellipticity = mean(ellip_comps)

    return helicity, ellipticity
end

"""
    wavpol(ct, X; nfft=256, noverlap=nfft÷2, bin_freq=3)

Perform polarization analysis of `n`-component time series data.

Assumes the data are in a right-handed, field-aligned coordinate system 
(with Z along the ambient magnetic field).

For each FFT window (with specified overlap), the routine:
  1. Computes the FFT and constructs the spectral matrix ``S(f)``.
  2. Applies frequency smoothing using a window (of length `bin_freq`).
  3. Computes the wave power, degree of polarization, wave normal angle,
     ellipticity, and helicity.

# Arguments
- `ct`: Time vector.
- `X`: Field components (where each column is a component).
- Keyword arguments:
  - `nfft`: Number of FFT points (default 256).
  - `noverlap`: Step between successive FFT windows (default `nfft÷2`).
  - `bin_freq`: Number of frequency bins for smoothing (default 3; will be made odd if needed).

# Returns
A tuple: where each parameter (except `freqline`) is an array with one row per FFT window.

See [`polarization`](@ref), [`wave_normal_angle`](@ref), [`wpol_helicity`](@ref).
"""
function wavpol(ct, X; nfft=256, noverlap=div(nfft, 2), bin_freq=3)
    # Ensure the smoothing window length is odd.
    iseven(bin_freq) && (bin_freq += 1)

    N = size(X, 1)
    samp_freq = samplingrate(ct)
    Nfreq = div(nfft, 2)
    fs = (samp_freq / nfft) * (0:(Nfreq-1))

    # Define the number of FFT windows and times (center time of each window)
    nsteps = floor(Int, (N - nfft) / noverlap) + 1
    times = similar(ct, nsteps)

    # Define the FFT window (here a smooth window similar to Hanning)
    window = 0.08 .+ 0.46 .* (1 .- cos.(2π .* (0:(nfft-1)) ./ nfft))
    half = div(nfft, 2)
    # Use a Hamming window for frequency smoothing.
    smooth_win = 0.54 .- 0.46 * cos.(2π .* (0:(bin_freq-1)) ./ (bin_freq - 1))
    smooth_win = smooth_win / sum(smooth_win)

    # Preallocate arrays for the results.
    power = zeros(Float64, nsteps, Nfreq)
    degpol = zeros(Float64, nsteps, Nfreq)
    waveangle = zeros(Float64, nsteps, Nfreq)
    ellipticity = zeros(Float64, nsteps, Nfreq)
    helicity = zeros(Float64, nsteps, Nfreq)

    # Process each FFT window.
    Threads.@threads for j in 1:nsteps
        start_idx = 1 + (j - 1) * noverlap
        end_idx = start_idx + nfft - 1
        if end_idx > N
            continue
        end
        S = spectral_matrix(@view(X[start_idx:end_idx, :]), window)
        S_smooth = smooth_spectral_matrix(S, smooth_win)

        # Compute the following polarization parameters from the spectral matrix ``S``:
        for f in 1:Nfreq
            Sf = S_smooth[f, :, :]
            power[j, f] = real(tr(Sf))
            degpol[j, f] = polarization(Sf)
            waveangle[j, f] = wave_normal_angle(Sf)
            helicity[j, f], ellipticity[j, f] = wpol_helicity(Sf, waveangle[j, f])
        end
        times[j] = ct[start_idx+half] # Set the times at the center of the FFT window.
    end
    return (; times, fs, power, degpol, waveangle, ellipticity, helicity)
end

"""
    twavpol(x)

A convenience wrapper around [`wavpol`](@ref) that works with DimensionalData arrays.

It automatically extracts the time dimension and returns the results as a DimStack with properly labeled dimensions.
"""
function twavpol(x; kwargs...)
    res = wavpol(times(x), parent(x); kwargs...)
    dims = (Ti(res.times), 𝑓(res.fs))
    DimStack((
        power=DimArray(res.power, dims; name="Power", metadata=Dict{Any,Any}("scale" => log10)),
        degpol=DimArray(res.degpol, dims; name="Degree of polarization"),
        waveangle=DimArray(res.waveangle, dims; name="Wave normal angle"),
        ellipticity=DimArray(res.ellipticity, dims; name="Ellipticity"),
        helicity=DimArray(res.helicity, dims; name="Helicity"),
    ))
end