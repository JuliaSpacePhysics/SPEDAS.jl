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

spectral_matrix!(S, Xf) = (@tullio S[f, i, j] = Xf[f, i] * conj(Xf[f, j]))

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
    Xf = rfft(X, 1) ./ sqrt(nfft)
    spectral_matrix(Xf)
end

"""
    smooth_spectral_matrix(S, aa)

Smooth the spectral matrix ``S(f)`` by applying a weighted average over frequency.
The smoothing uses a symmetric window `aa` (for example, a Hamming window) of length M.

# Arguments
- `S`: Spectral matrix array of size ``N_{freq}, n, n`` where n is the number of components.
- `aa`: Weighting vector of length M.
"""
function smooth_spectral_matrix(S, aa)
    S_smooth = similar(S)
    return smooth_spectral_matrix!(S_smooth, S, aa)
end

"""
    smooth_spectral_matrix!(S_smooth, S, aa)

In-place version of `smooth_spectral_matrix` that writes results to a pre-allocated array.
"""
function smooth_spectral_matrix!(S_smooth, S, aa)
    Nfreq, n, _ = size(S)
    M = length(aa)
    halfM = div(M, 2)

    # For boundary frequencies, copy original S
    for i in 1:n, j in 1:n
        for f in 1:halfM
            S_smooth[f, i, j] = S[f, i, j]
        end
        for f in (halfM+1):(Nfreq-halfM)
            sum_val = zero(eltype(S_smooth))
            for k in 0:(M-1)
                sum_val += aa[k+1] * S[f-halfM+k, i, j]
            end
            S_smooth[f, i, j] = sum_val
        end
        for f in (Nfreq-halfM+1):Nfreq
            S_smooth[f, i, j] = S[f, i, j]
        end
    end

    return S_smooth
end