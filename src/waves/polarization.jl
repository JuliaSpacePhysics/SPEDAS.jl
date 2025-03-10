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


_smooth_t(nfft) = 0.08 .+ 0.46 .* (1 .- cos.(2π .* (0:(nfft-1)) ./ nfft))

"""
    wavpol(X, fs=1; nfft=256, noverlap=div(nfft, 2), smooth_t=_smooth_t(nfft), smooth_f=hamming(3), nbuffers=Threads.nthreads())

Perform polarization analysis of `n`-component time series data.

For each FFT window (with specified overlap), the routine:
1. Applies a time-domain window function and computes the FFT to construct the spectral matrix ``S(f)``
2. Applies frequency smoothing using a window function
3. Computes wave parameters: power, degree of polarization, wave normal angle, ellipticity, and helicity

The analysis assumes the data are in a right-handed, field-aligned coordinate system 
(with Z along the ambient magnetic field).

# Arguments
- `X`: Matrix where each column is a component of the multivariate time series
- `fs`: Sampling frequency (default: 1)

# Keywords
- `nfft`: Number of points for FFT (default: 256)
- `noverlap`: Number of overlapping points between windows (default: nfft÷2)
- `smooth_t`: Time domain window function (default: Hann window)
- `smooth_f`: Frequency domain smoothing window (default: 3-point Hamming window)
- `nbuffers`: Number of pre-allocated buffers for parallel processing (default: number of threads)

# Returns
A named tuple containing:
- `indices`: Time indices for each FFT window
- `freqs`: Frequency array
- `power`: Power spectral density, normalized by frequency bin width and window function
- `degpol`: Degree of polarization [0,1]
- `waveangle`: Wave normal angle [0,π/2]
- `ellipticity`: Wave ellipticity [-1,1], negative for left-hand polarized
- `helicity`: Wave helicity

See also: [`polarization`](@ref), [`wave_normal_angle`](@ref), [`wpol_helicity`](@ref)
"""
function wavpol(X::AbstractMatrix{T}, ::Val{n}, fs=1; nfft=256, noverlap=div(nfft, 2), smooth_t=_smooth_t(nfft), smooth_f=hamming(3), nbuffers=Threads.nthreads()) where {T<:Number,n}
    N = size(X, 1)
    Nfreq = div(nfft, 2) + 1
    freqs = (fs / nfft) * (0:(Nfreq-1))

    # Define the number of FFT windows
    nsteps = floor(Int, (N - nfft) / noverlap) + 1
    indices = 1 .+ (0:nsteps-1) * noverlap .+ div(nfft, 2)
    # normalize the smooth window for frequency smoothing
    smooth_f = smooth_f / sum(smooth_f)

    # Preallocate arrays for the results.
    power = zeros(T, nsteps, Nfreq)
    degpol = zeros(T, nsteps, Nfreq)
    waveangle = zeros(T, nsteps, Nfreq)
    ellipticity = zeros(T, nsteps, Nfreq)
    helicity = zeros(T, nsteps, Nfreq)

    # Channels for parallel processing
    Xwchnl = Channel{Matrix{T}}(nbuffers)
    Xfchnl = Channel{Matrix{Complex{T}}}(nbuffers)
    SType = Array{Complex{T},3}
    Schnl = Channel{SType}(nbuffers)
    Smchnl = Channel{SType}(nbuffers)
    foreach(1:nbuffers) do _
        put!(Xwchnl, Matrix{T}(undef, nfft, n))
        put!(Xfchnl, Matrix{Complex{T}}(undef, Nfreq, n))
        put!(Schnl, SType(undef, Nfreq, n, n))
        put!(Smchnl, SType(undef, Nfreq, n, n))
    end
    chnls = (Xwchnl, Xfchnl, Schnl, Smchnl)
    plan = plan_rfft(zeros(T, nfft, n), 1)

    tforeach(1:nsteps) do j
        Xw, Xf, S, Sm = map(take!, chnls)

        start_idx = 1 + (j - 1) * noverlap
        end_idx = start_idx + nfft - 1
        copyto!(Xw, @view(X[start_idx:end_idx, :]))
        Xw .*= smooth_t
        mul!(Xf, plan, Xw)
        Xf ./= sqrt(nfft) # Compute FFTs and normalize
        spectral_matrix!(S, Xf)
        smooth_spectral_matrix!(Sm, S, smooth_f)
        # Compute the following polarization parameters from the spectral matrix ``S``:
        for f in 1:Nfreq
            Sf = @views SMatrix{n,n}(Sm[f, :, :])
            power[j, f] = real(tr(Sf))
            degpol[j, f] = real(polarization(Sf))
            waveangle[j, f] = wave_normal_angle(Sf)
            helicity[j, f], ellipticity[j, f] = wpol_helicity(Sf, waveangle[j, f])
        end

        put!(Schnl, S)
        put!(Smchnl, Sm)
        put!(Xwchnl, Xw)
        put!(Xfchnl, Xf)
    end

    # Scaling power results to units with meaning
    binwidth = fs / nfft
    W = sum(smooth_t .^ 2) / nfft
    power_s = power * 2 / (binwidth * W)

    return (; indices, freqs, power=power_s, degpol, waveangle, ellipticity, helicity)
end

wavpol(X, args...; kwargs...) = wavpol(X, Val(size(X, 2)), args...; kwargs...)

"""
    twavpol(x)

A convenience wrapper around [`wavpol`](@ref) that works with DimensionalData arrays.

It automatically extracts the time dimension and returns the results as a DimStack with properly labeled dimensions.
"""
function twavpol(x; nfft=256, noverlap=div(nfft, 2), kwargs...)
    t = times(x)
    fs = samplingrate(t)
    res = wavpol(parent(x), fs; nfft, noverlap, kwargs...)
    dims = (Ti(t[res.indices]), 𝑓(res.freqs))
    DimStack((
        power=DimArray(res.power, dims; name="Power", metadata=Dict{Any,Any}("scale" => log10)),
        degpol=DimArray(res.degpol, dims; name="Degree of polarization"),
        waveangle=DimArray(res.waveangle, dims; name="Wave normal angle"),
        ellipticity=DimArray(res.ellipticity, dims; name="Ellipticity"),
        helicity=DimArray(res.helicity, dims; name="Helicity"),
    ))
end