"""
    window_bf_sizes(window)

Converts a window specification to backward and forward window sizes.

When window is a positive integer scalar, the window is centered about the current element and contains window-1 neighboring elements.
If window is even, then the window is centered about the current and previous elements.
"""
function window_bf_sizes(window::Integer)
    return isodd(window) ? (window ÷ 2, window ÷ 2) : (window ÷ 2, window ÷ 2 - 1)
end

function window_bf_sizes(window)
    @assert length(window) == 2 "Window must be of length 2"
    return window
end

other_dims(A, dim) = filter(!=(dim), ntuple(identity, ndims(A)))

# https://github.com/joshday/SearchSortedNearest.jl
function searchsortednearest(a, x; by = identity, lt = isless, rev = false, distance = (a, b) -> abs(a - b))
    i = searchsortedfirst(a, x; by, lt, rev)
    if i == 1
    elseif i > length(a)
        i = length(a)
    elseif a[i] == x
    else
        i = lt(distance(by(a[i]), by(x)), distance(by(a[i - 1]), by(x))) ? i : i - 1
    end
    return i
end
