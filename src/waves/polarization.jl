# polarisation analysis 
# https://github.com/spedas/bleeding_edge/blob/master/general/science/wavpol/twavpol.pro
# https://github.com/spedas/bleeding_edge/blob/master/general/science/wavpol/wavpol.pro
# https://pyspedas.readthedocs.io/en/latest/_modules/pyspedas/analysis/twavpol.html
# https://github.com/spedas/pyspedas/blob/master/pyspedas/analysis/twavpol.py

using FFTW, LinearAlgebra
export compute_spectral_matrix, smooth_spectral_matrix, wavpol

"""
    compute_spectral_matrix(x, y, z; window, nopfft)

Apply a window function to a segment of three time series and compute their FFT.
Then construct the spectral matrix ``S(f)`` (for positive frequencies only) defined by

```math
S_{ij}(f) = X_i(f) X_j^*(f),
```

where ``X_i(f)`` is the FFT of the i-th component and * denotes complex conjugation.

# Arguments
- `x, y, z`: Vectors of the three field components (length `nopfft`).
- `window`: A window function (vector of length `nopfft`).
- `nopfft`: Number of FFT points.

# Returns
- `S`: A 3‑D array of size ``N_{freq}, 3, 3`` where ``_{freq} = \\texttt{nopfft}÷``.
"""
function compute_spectral_matrix(x::Vector, y::Vector, z::Vector; window::Vector, nopfft::Int)
    # Apply the window to the data
    xw = x .* window
    yw = y .* window
    zw = z .* window
    # Compute FFTs and normalize (the normalization here is chosen for energy preservation)
    X = fft(xw) / sqrt(nopfft)
    Y = fft(yw) / sqrt(nopfft)
    Z = fft(zw) / sqrt(nopfft)
    Nfreq = div(nopfft, 2)
    # Only keep the positive frequencies
    X = X[1:Nfreq]
    Y = Y[1:Nfreq]
    Z = Z[1:Nfreq]
    # Build the spectral (covariance) matrix S for each frequency f
    S = Array{ComplexF64}(undef, Nfreq, 3, 3)
    # Use broadcasting to compute all elements at once
    XYZ = [X, Y, Z]
    for i in 1:3, j in 1:3
        S[:, i, j] = XYZ[i] .* conj.(XYZ[j])
    end
    return S
end

"""
    smooth_spectral_matrix(S, aa)

Smooth the spectral matrix ``S(f)`` by applying a weighted average over frequency.
The smoothing uses a symmetric window `aa` (for example, a Hamming window) of length M.

# Arguments
- `S`: Spectral matrix array of size ``N_{freq}, 3, 3``.
- `aa`: Weighting vector of length M.

# Returns
- `S_smooth`: The smoothed spectral matrix (same dimensions as S).
"""
function smooth_spectral_matrix(S, aa::Vector{Float64})
    Nfreq, _, _ = size(S)
    M = length(aa)
    halfM = div(M, 2)
    S_smooth = similar(S)
    # For frequencies where the full smoothing window fits
    for f in (halfM+1):(Nfreq-halfM)
        for i in 1:3, j in 1:3
            S_smooth[f, i, j] = sum(aa .* S[(f-halfM):(f+halfM), i, j])
        end
    end
    # For boundary frequencies, copy original S (or you might handle edges separately)
    for f in 1:halfM
        S_smooth[f, :, :] = S[f, :, :]
    end
    for f in (Nfreq-halfM+1):Nfreq
        S_smooth[f, :, :] = S[f, :, :]
    end
    return S_smooth
end

# Helper function to compute complex arctan (works for complex numbers)
function atan2c(zx, zy)
    if isreal(zx) && isreal(zy)
        return atan(zx, zy)
    else
        return -im * log((zx + im * zy) / sqrt(zx^2 + zy^2))
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

    for comp in 1:3
        # Build state vector λ_u for this polarization component
        if comp == 1
            # X-component: use S[1,1] as diagonal
            alph = sqrt(real(S[1, 1]))
            if alph == 0.0
                continue
            end
            lam_u = [
                alph,
                (real(S[1, 2]) / alph) + 1im * (-imag(S[1, 2]) / alph),
                (real(S[1, 3]) / alph) + 1im * (-imag(S[1, 3]) / alph)
            ]
        elseif comp == 2
            # Y-component: use S[2,2]
            alph = sqrt(real(S[2, 2]))
            if alph == 0.0
                continue
            end
            lam_u = [
                (real(S[2, 1]) / alph) + 1im * (-imag(S[2, 1]) / alph),
                alph,
                (real(S[2, 3]) / alph) + 1im * (-imag(S[2, 3]) / alph)
            ]
        else
            # Z-component: use S[3,3]
            alph = sqrt(real(S[3, 3]))
            if alph == 0.0
                continue
            end
            lam_u = [
                (real(S[3, 1]) / alph) + 1im * (-imag(S[3, 1]) / alph),
                (real(S[3, 2]) / alph) + 1im * (-imag(S[3, 2]) / alph),
                alph
            ]
        end

        # Compute the phase rotation (gammay) for this state vector
        upper = sum(2 .* real.(lam_u) .* imag.(lam_u))
        lower = sum(real.(lam_u) .^ 2 - imag.(lam_u) .^ 2)
        gammay = 0.0
        if isfinite(upper) && isfinite(lower)
            if upper > 0
                gammay = atan2c(upper, lower)
            else
                gammay = 2π + atan2c(upper, lower)
            end
        end
        lam_y = exp(-1im * 0.5 * gammay) * lam_u

        # Helicity: ratio of the norm of the imaginary part to the real part
        norm_real = norm(real.(lam_y))
        norm_imag = norm(imag.(lam_y))
        helicity_comps[comp] = (norm_imag != 0) ? 1 / (norm_real / norm_imag) : NaN

        # For ellipticity, use only the first two components
        u1 = lam_y[1]
        u2 = lam_y[2]
        uppere = imag(u1) * real(u1) + imag(u2) * real(u2)
        lowere = (-imag(u1)^2 + real(u1)^2 - imag(u2)^2 + real(u2)^2)
        gammarot = 0.0
        if isfinite(uppere) && isfinite(lowere)
            if uppere > 0
                gammarot = atan2c(uppere, lowere)
            else
                gammarot = 2π + atan2c(uppere, lowere)
            end
        end
        lam_urot = exp(-1im * 0.5 * gammarot) * [u1, u2]
        num = norm(imag.(lam_urot))
        den = norm(real.(lam_urot))
        ellip_val = (den != 0) ? num / den : NaN
        # Adjust sign using the off-diagonal of ematspec and the wave normal angle
        sign_factor = sign(imag(S[1, 2]) * sin(waveangle))
        ellip_comps[comp] = ellip_val * sign_factor
    end

    # Average the three computed values
    helicity = mean(filter(!isnan, helicity_comps))
    ellipticity = mean(filter(!isnan, ellip_comps))

    return helicity, ellipticity
end

"""
    compute_polarization_parameters(S_smooth)

For each frequency bin, compute the following polarization parameters from the smoothed
spectral matrix ``S``:

1. **Wave Power**: ``\\text{power} = \\mathrm{tr}(S)``.
2. **Degree of Polarization**:
   ```math
   P = \\frac{3\\,\\mathrm{tr}(S^2) - [\\mathrm{tr}(S)]^2}{2\\,[\\mathrm{tr}(S)]^2}.
   ```
3. **Wave Normal Angle**: Derived from the imaginary parts of the off-diagonal elements.
4. **Ellipticity**: Estimated from a simplified eigen-decomposition of ``S``.
5. **Helicity**: Here defined as the absolute value of the ellipticity (a simplified proxy).

# Returns
A dictionary with keys:
- `"power"`, `"degpol"`, `"waveangle"`, `"ellipticity"`, `"helicity"`
each mapping to a vector (length = number of frequency bins).
"""
function compute_polarization_parameters(S_smooth)
    Nfreq = size(S_smooth, 1)
    power = zeros(Float64, Nfreq)
    degpol = zeros(Float64, Nfreq)
    waveangle = zeros(Float64, Nfreq)
    ellipticity = zeros(Float64, Nfreq)
    helicity = zeros(Float64, Nfreq)

    for f in 1:Nfreq
        S = S_smooth[f, :, :]
        # Wave power is the trace of S.
        power[f] = real(tr(S))
        # Degree of polarization:
        trS = real(tr(S))
        trS2 = real(tr(S * S))
        degpol[f] = (3 * trS2 - trS^2) / (2 * trS^2)

        # Wave normal angle: use the imaginary parts of off-diagonals.
        # Define:``
        #   A = Im(S₁₂), B = Im(S₁₃), C = Im(S₂₃)
        A = imag(S[1, 2])
        B = imag(S[1, 3])
        C = imag(S[2, 3])
        aaa2 = sqrt(A^2 + B^2 + C^2)
        if aaa2 != 0
            # Normalize contributions to get directional cosines.
            wnx = abs(C / aaa2)
            wny = -abs(B / aaa2)
            wnz = A / aaa2
            # Wave normal angle is the angle between (wnx, wny) and the vertical |wnz|
            waveangle[f] = atan(sqrt(wnx^2 + wny^2), abs(wnz))
        else
            waveangle[f] = NaN
        end
    end

    helicity, ellipticity = wpol_helicity(S_smooth, waveangle)
    return (; power, degpol, waveangle, ellipticity, helicity)
end

"""
    wpol_helicity(S, waveangle)

Compute helicity and ellipticity for a given spectral matrix and wave normal angle.

# Arguments
- `S`: Spectral matrix array of size (Nfreq, 3, 3)
- `waveangle`: Wave normal angle vector of length Nfreq

# Returns
- `helicity`: Average helicity across the three components
- `ellipticity`: Average ellipticity across the three components
"""
function wpol_helicity(S::Array{ComplexF64,3}, waveangle::Vector{Float64})
    Nfreq = size(S, 1)
    # Preallocate arrays for results
    helicity = zeros(Float64, Nfreq)
    ellipticity = zeros(Float64, Nfreq)
    for f in 1:Nfreq
        helicity[f], ellipticity[f] = wpol_helicity(S[f, :, :], waveangle[f])
    end
    return helicity, ellipticity
end

# ============================================================================
# Main Function: wavpol
# ============================================================================

"""
    wavpol(ct, bx, by, bz; nopfft=256, steplength=nopfft÷2, bin_freq=3)

Perform polarization analysis of three-component magnetic field time series data.
Assumes the data are in a right‑handed, field‑aligned coordinate system (with Z along the
ambient magnetic field).

For each FFT window (with specified overlap), the routine:
  1. Computes the FFT and constructs the spectral matrix ``S(f)``.
  2. Applies frequency smoothing using a window (of length `bin_freq`).
  3. Computes the wave power, degree of polarization, wave normal angle,
     ellipticity, and helicity.

# Arguments
- `ct`: Time vector.
- `bx, by, bz`: Magnetic field components.
- Keyword arguments:
  - `nopfft`: Number of FFT points (default 256).
  - `steplength`: Step between successive FFT windows (default `nopfft÷2`).
  - `bin_freq`: Number of frequency bins for smoothing (default 3; will be made odd if needed).

# Returns
A tuple:

where each parameter (except `freqline`) is an array with one row per FFT window.
"""
function wavpol(ct, bx, by, bz; nopfft::Int=256, steplength::Int=div(nopfft, 2), bin_freq::Int=3)
    N = length(bx)
    samp_freq = samplingrate(ct)
    Nfreq = div(nopfft, 2)
    freqline = (samp_freq / nopfft) * collect(0:(Nfreq-1))

    # Define the number of FFT windows and timeline (center time of each window)
    nsteps = floor(Int, (N - nopfft) / steplength) + 1
    timeline = zeros(Float64, nsteps)

    # Define the FFT window (here a smooth window similar to Hanning)
    fft_window = 0.08 .+ 0.46 .* (1 .- cos.(2π .* (0:(nopfft-1)) ./ nopfft))

    # Ensure the smoothing window length is odd.
    if iseven(bin_freq)
        bin_freq += 1
    end
    # Use a Hamming window for frequency smoothing.
    smooth_win = 0.54 .- 0.46 * cos.(2π .* (0:(bin_freq-1)) ./ (bin_freq - 1))
    smooth_win = smooth_win / sum(smooth_win)

    # Preallocate output arrays (each row corresponds to one FFT window).
    power = zeros(Float64, nsteps, Nfreq)
    degpol = zeros(Float64, nsteps, Nfreq)
    waveangle = zeros(Float64, nsteps, Nfreq)
    ellipticity = zeros(Float64, nsteps, Nfreq)
    helicity = zeros(Float64, nsteps, Nfreq)

    for j in 1:nsteps
        start_idx = 1 + (j - 1) * steplength
        end_idx = start_idx + nopfft - 1
        if end_idx > N
            break
        end
        # Extract the segment for this FFT window.
        seg_x = bx[start_idx:end_idx]
        seg_y = by[start_idx:end_idx]
        seg_z = bz[start_idx:end_idx]

        # Compute the spectral matrix for this window.
        S = compute_spectral_matrix(seg_x, seg_y, seg_z; window=fft_window, nopfft=nopfft)
        # Smooth the spectral matrix in the frequency domain.
        S_smooth = smooth_spectral_matrix(S, smooth_win)
        # Compute polarization parameters for each frequency.
        params = compute_polarization_parameters(S_smooth)

        # Store the results.
        power[j, :] = params.power
        degpol[j, :] = params.degpol
        waveangle[j, :] = params.waveangle
        ellipticity[j, :] = params.ellipticity
        helicity[j, :] = params.helicity

        # Set the timeline at the center of the FFT window.
        # timeline[j] = ct[start_idx+div(nopfft, 2)]
        # timeline[j] = ct[start_idx]
    end

    return (; timeline, freqline, power, degpol, waveangle, ellipticity, helicity)
end

wavpol(t, M; kwargs...) = wavpol(t, eachcol(M)...; kwargs...)

function twavpol(x)
    wavpol(times(x), parent(x))
end