include("coordinate.jl")
include("fac.jl")


"""
    cotrans(out, A, [times]; in=get_coord(A))
    cotrans(in => out, A, [times])

Transform data to the `out` coordinate system with [`GeoCotrans`](https://juliaspacephysics.github.io/GeoCotrans.jl) and update its coordinate metadata ([`set_coord`](@ref)), e.g. `cotrans(GSM, A)`.

References:

  - [SPEDAS Cotrans](https://spedas.org/wiki/index.php?title=Cotrans)
"""
function cotrans(out, A, args...; in = get_coord(A), kw...)
    isnothing(in) && throw(ArgumentError("input coordinate system required; use `cotrans(in => out, A, times)` or pass `in = ...`"))
    return set_coord(GeoCotrans.transform(in => out, A, args...; kw...), nameof(GeoCotrans.frametype(out)))
end

cotrans(pair::Pair, A, args...; kw...) =
    cotrans(last(pair), A, args...; in = first(pair), kw...)
