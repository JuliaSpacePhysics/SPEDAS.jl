get_coord(da) = getmeta(da, "COORDINATE_SYSTEM", nothing)
function get_coords(da)
    coord = get_coord(da)
    return isnothing(coord) ? [] : split(coord, '>')
end

"""
Set the coordinate system.

Updates legend names, axis labels, and the array name if they include the coordinate system.
"""
function setcoord(da, coord_out; old_coords = get_coords(da))
    coord = string(coord_out)
    old_new_pairs = [[old => coord for old in old_coords]; [lowercase(old) => lowercase(coord) for old in old_coords]]
    has_old(s) = any(p -> occursin(first(p), s), old_new_pairs)

    m = meta(da)
    metadata_pairs = Pair{String, Any}["COORDINATE_SYSTEM" => coord]
    for field in ("LABLAXIS", "UNITS", "FIELDNAM", "CATDESC", "DICT_KEY") ∩ keys(m)
        value = m[field]
        has_old(value) && push!(metadata_pairs, field => replace(value, old_new_pairs...))
    end
    # In CDF files `LABL_PTR_1` names a label variable; only inline label vectors are rewritten.
    labels = get(m, "LABL_PTR_1", nothing)
    if labels isa AbstractVector{<:AbstractString} && any(has_old, labels)
        push!(metadata_pairs, "LABL_PTR_1" => replace.(labels, old_new_pairs...))
    end
    new_da = setmeta(da, metadata_pairs...)
    return _rename(new_da, old_new_pairs)
end

function _rename(da, old_new_pairs)
    hasproperty(da, :name) || return da
    name = da.name
    name isa Union{Symbol, String} || return da
    return setproperties(da, (; name = typeof(name)(replace(string(name), old_new_pairs...))))
end

setcoord(coord; kwargs...) = da -> setcoord(da, coord; kwargs...)

"""
    cotrans(out, A, [times]; in=get_coord(A))
    cotrans(in => out, A, [times])

Transform data to the `out` coordinate system with [`GeoCotrans`](https://juliaspacephysics.github.io/GeoCotrans.jl) and update its coordinate metadata ([`setcoord`](@ref)), e.g. `cotrans(GSM, A)`.

References:

  - [SPEDAS Cotrans](https://spedas.org/wiki/index.php?title=Cotrans)
"""
function cotrans(out, A, args...; in = get_coord(A), kw...)
    isnothing(in) && throw(ArgumentError("input coordinate system required; use `cotrans(in => out, A, times)` or pass `in = ...`"))
    return setcoord(GeoCotrans.transform(in => out, A, args...; kw...), nameof(GeoCotrans.frametype(out)))
end

cotrans(pair::Pair, A, args...; kw...) =
    cotrans(last(pair), A, args...; in = first(pair), kw...)
