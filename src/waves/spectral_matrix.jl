"""
    spectral_matrix(Xf)

Compute the spectral matrix ``S`` defined by

```math
S_{ij}(f) = X_i(f) X_j^*(f),
```

where ``X_i(f)``=`Xf[f, i]` is the FFT of the i-th component and * denotes complex conjugation.
"""
function spectral_matrix(Xf::AbstractMatrix{<:Complex})
    @tullio S[f, i, j] := Xf[f, i] * conj(Xf[f, j])
end

"""
    spectral_matrix(X, window)

Compute the spectral matrix ``S(f)`` given the time series data `X`.

Returns a 3-D array of size ``N_{freq}, n, n``, where ``N_{freq} = \\lfloor N/2 \\rfloor`` 
    and `n` is the dimensionality (number of components).

# Arguments
- `X`: Matrix where each column is a component of the multivariate time series, or a vector of vectors.
- `window`: A window function (optional). If not provided, a rectangular window (no windowing) is used.
"""
function spectral_matrix(X::AbstractMatrix{<:Real})
    nfft = size(X, 1)
    # Compute FFTs and normalize
    Xf = fft(X, 1) ./ sqrt(nfft)
    # Only keep the positive frequencies
    Nfreq = div(nfft, 2)
    @views spectral_matrix(Xf[1:Nfreq, :])
end

function spectral_matrix(components::AbstractVector{<:AbstractVector}, args...; kwargs...)
    X = reduce(hcat, components)
    spectral_matrix(X, args...; kwargs...)
end

"""
    smooth_spectral_matrix(S, aa)

Smooth the spectral matrix ``S(f)`` by applying a weighted average over frequency.
The smoothing uses a symmetric window `aa` (for example, a Hamming window) of length M.

# Arguments
- `S`: Spectral matrix array of size ``N_{freq}, n, n`` where n is the number of components.
- `aa`: Weighting vector of length M.
"""
function smooth_spectral_matrix(S, aa::Vector{Float64})
    Nfreq, n, _ = size(S)
    M = length(aa)
    halfM = div(M, 2)
    S_smooth = similar(S)

    # For frequencies where the full smoothing window fits
    for i in 1:n, j in 1:n
        for f in (halfM+1):(Nfreq-halfM)
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