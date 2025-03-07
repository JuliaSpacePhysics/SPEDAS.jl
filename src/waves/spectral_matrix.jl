"""
    spectral_matrix(X, window)

Compute the spectral matrix ``S(f)`` defined by

```math
S_{ij}(f) = X_i(f) X_j^*(f),
```

where ``X_i(f)`` is the FFT of the i-th component and * denotes complex conjugation.

Returns a 3-D array of size ``N_{freq}, n, n``, where ``N_{freq} = \\lfloor N/2 \\rfloor`` 
    and `n` is the dimensionality (number of components).

# Arguments
- `X`: Matrix where each column is a component of the multivariate time series, or a vector of vectors.
- `window`: A window function (optional). If not provided, a rectangular window (no windowing) is used.
"""
function spectral_matrix(X::AbstractMatrix, window::AbstractVector=ones(size(X, 1)))
    n_samples, n = size(X)

    # Apply the window to each component
    Xw = X .* window

    # Compute FFTs and normalize
    Xf = fft(Xw, 1) ./ sqrt(n_samples)

    # Only keep the positive frequencies
    Nfreq = div(n_samples, 2)
    Xf = Xf[1:Nfreq, :]

    S = Array{ComplexF64,3}(undef, Nfreq, n, n)
    for i in 1:n, j in 1:n
        @. S[:, i, j] = Xf[:, i] * conj(Xf[:, j])
    end

    return S
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
    for f in (halfM+1):(Nfreq-halfM)
        for i in 1:n, j in 1:n
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