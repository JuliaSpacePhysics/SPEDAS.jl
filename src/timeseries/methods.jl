function tnorm(x; dims=Ti)
    norm.(eachslice(x; dims))
end

function tcross(x, y; dims=Ti)
    cross.(eachslice(x; dims), eachslice(y; dims))
end

function tdot(x, y; dims=Ti)
    dot.(eachslice(x; dims), eachslice(y; dims))
end
