# polarisation analysis 
# https://github.com/spedas/bleeding_edge/blob/master/general/science/wavpol/twavpol.pro
# https://github.com/spedas/bleeding_edge/blob/master/general/science/wavpol/wavpol.pro
# https://pyspedas.readthedocs.io/en/latest/_modules/pyspedas/analysis/twavpol.html
# https://github.com/spedas/pyspedas/blob/master/pyspedas/analysis/twavpol.py

"""
    spectral_matrix(x, y, z; window)

Apply a window function to a segment of three time series and compute their FFT.
Then construct the spectral matrix ``S(f)`` (for positive frequencies only) defined by

```math
S_{ij}(f) = X_i(f) X_j^*(f),
```

where ``X_i(f)`` is the FFT of the i-th component and * denotes complex conjugation.

# Arguments
- `x, y, z`: Vectors of the three field components.
- `window`: A window function.

# Returns
- `S`: A 3‑D array of size ``N_{freq}, 3, 3`` where ``_{freq} = \\texttt{nfft}÷``.
"""
function spectral_matrix(x, y, z; window::Vector)
    # Apply the window to the data
    xw = x .* window
    yw = y .* window
    zw = z .* window
    # Compute FFTs and normalize (the normalization here is chosen for energy preservation)
    n = length(x)
    X = fft(xw) / sqrt(n)
    Y = fft(yw) / sqrt(n)
    Z = fft(zw) / sqrt(n)
    Nfreq = div(n, 2)
    # Only keep the positive frequencies
    X = X[1:Nfreq]
    Y = Y[1:Nfreq]
    Z = Z[1:Nfreq]

    # Initialize the spectral matrix
    S = zeros(ComplexF64, Nfreq, 3, 3)
    XYZ = [X, Y, Z]
    for i in 1:3, j in 1:3
        @. S[:, i, j] = XYZ[i] * conj(XYZ[j])
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

    for comp in 1:3
        # Build state vector λ_u for this polarization component
        alph = sqrt(real(S[comp, comp]))
        alph == 0.0 && continue
        if comp == 1
            lam_u = [
                alph,
                (real(S[1, 2]) / alph) + im * (-imag(S[1, 2]) / alph),
                (real(S[1, 3]) / alph) + im * (-imag(S[1, 3]) / alph)
            ]
        elseif comp == 2
            lam_u = [
                (real(S[2, 1]) / alph) + im * (-imag(S[2, 1]) / alph),
                alph,
                (real(S[2, 3]) / alph) + im * (-imag(S[2, 3]) / alph)
            ]
        else
            lam_u = [
                (real(S[3, 1]) / alph) + im * (-imag(S[3, 1]) / alph),
                (real(S[3, 2]) / alph) + im * (-imag(S[3, 2]) / alph),
                alph
            ]
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
# Reference
- [Wikipedia](https://en.wikipedia.org/wiki/Polarization_(waves))
- [Stokes parameters](https://en.wikipedia.org/wiki/Stokes_parameters)
"""
function polarization end

"""
    polarization(S)

Compute the degree of polarization (DOP) `P^2` from spectral matrix `S`.

```math
\\begin{aligned}
P^2  &= 1-\\frac{(tr 𝐒)^2-(tr 𝐒^2)}{(tr 𝐒)^2-n^{-1}(tr 𝐒)^2} \\\\
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
    compute_polarization_parameters(S)

Compute the following polarization parameters from the spectral matrix ``S``:

1. **Wave Power**: ``\\text{power} = \\mathrm{tr}(S)``.
2. **Degree of Polarization**: see [`polarization`](@ref).
3. **Wave Normal Angle**: see [`wave_normal_angle`](@ref).
4. **Ellipticity** and **Helicity**: see [`wpol_helicity`](@ref).
"""
function compute_polarization_parameters(Ss)
    Nfreq = size(Ss, 1)
    power = zeros(Float64, Nfreq)
    degpol = zeros(Float64, Nfreq)
    waveangle = zeros(Float64, Nfreq)
    ellipticity = zeros(Float64, Nfreq)
    helicity = zeros(Float64, Nfreq)

    for f in 1:Nfreq
        S = Ss[f, :, :]
        # Wave power is the trace of S.
        power[f] = real(tr(S))
        # Degree of polarization:
        degpol[f] = polarization(S)
        waveangle[f] = wave_normal_angle(S)
        helicity[f], ellipticity[f] = wpol_helicity(S, waveangle[f])
    end

    return (; power, degpol, waveangle, ellipticity, helicity)
end

"""
    wavpol(ct, bx, by, bz; nfft=256, steplength=nfft÷2, bin_freq=3)

Perform polarization analysis of three-component time series data.
Assumes the data are in a right-handed, field-aligned coordinate system 
(with Z along the ambient magnetic field).

For each FFT window (with specified overlap), the routine:
  1. Computes the FFT and constructs the spectral matrix ``S(f)``.
  2. Applies frequency smoothing using a window (of length `bin_freq`).
  3. Computes the wave power, degree of polarization, wave normal angle,
     ellipticity, and helicity.

# Arguments
- `ct`: Time vector.
- `bx, by, bz`: Field components.
- Keyword arguments:
  - `nfft`: Number of FFT points (default 256).
  - `steplength`: Step between successive FFT windows (default `nfft÷2`).
  - `bin_freq`: Number of frequency bins for smoothing (default 3; will be made odd if needed).

# Returns
A tuple: where each parameter (except `freqline`) is an array with one row per FFT window.
"""
function wavpol(ct, bx, by, bz; nfft=256, steplength=div(nfft, 2), bin_freq=3)
    N = length(bx)
    samp_freq = samplingrate(ct)
    Nfreq = div(nfft, 2)
    fs = (samp_freq / nfft) * (0:(Nfreq-1))

    # Define the number of FFT windows and times (center time of each window)
    nsteps = floor(Int, (N - nfft) / steplength) + 1
    times = similar(ct, nsteps)

    # Define the FFT window (here a smooth window similar to Hanning)
    window = 0.08 .+ 0.46 .* (1 .- cos.(2π .* (0:(nfft-1)) ./ nfft))
    half = div(nfft, 2)

    # Ensure the smoothing window length is odd.
    if iseven(bin_freq)
        bin_freq += 1
    end
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
        start_idx = 1 + (j - 1) * steplength
        end_idx = start_idx + nfft - 1
        if end_idx > N
            continue
        end

        # Extract the segment for this FFT window.
        seg_x = @view bx[start_idx:end_idx]
        seg_y = @view by[start_idx:end_idx]
        seg_z = @view bz[start_idx:end_idx]

        # Compute the spectral matrix for this window.
        S = spectral_matrix(seg_x, seg_y, seg_z; window)
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

        # Set the times at the center of the FFT window.
        times[j] = ct[start_idx+half]
    end
    return (; times, fs, power, degpol, waveangle, ellipticity, helicity)
end

wavpol(t, M; kwargs...) = wavpol(t, eachcol(M)...; kwargs...)

function twavpol(x)
    res = wavpol(times(x), parent(x))
    dims = (Ti(res.times), 𝑓(res.fs))
    DimStack((
        power=DimArray(res.power, dims; name="Power"),
        degpol=DimArray(res.degpol, dims; name="Degree of polarization"),
        waveangle=DimArray(res.waveangle, dims; name="Wave normal angle"),
        ellipticity=DimArray(res.ellipticity, dims; name="Ellipticity"),
        helicity=DimArray(res.helicity, dims; name="Helicity"),
    ))
end