get_coord(da) = get(meta(da), "COORDINATE_SYSTEM", nothing)
function get_coords(da)
    coord = get_coord(da)
    return isnothing(coord) ? [] : split(coord, '>')
end

_lowercase(x::Tuple) = tuple(lowercase.(x)...)
_lowercase(x::Pair) = Pair(lowercase(x.first), lowercase(x.second))

"""
Set the coordinate system.

Updates legend names and axis labels if they include the coordinate system.
Also updates the dimension name if it contains the coordinate system.

Reference:

  - https://pyspedas.readthedocs.io/en/latest/_modules/pytplot/data_att_getters_setters.html#set_coords
"""
function set_coord(da, coord_out; old_coords = get_coords(da))
    # Update the coordinate system metadata
    coord = string(coord_out)
    old_new_pairs = [old_coord => coord for old_coord in old_coords]
    push!(old_coords, lowercase.(old_coords)...)
    push!(old_new_pairs, _lowercase.(old_new_pairs)...)

    # Get the current metadata
    m = meta(da)

    metadata_pairs = Pair{String, Any}["COORDINATE_SYSTEM" => coord]
    # Update other potential metadata fields that might contain coordinate info
    for field in ("LABLAXIS", "UNITS", "FIELDNAM", "CATDESC", "DICT_KEY") ∩ keys(m)
        value = m[field]
        if any(occursin(value), old_coords)
            new_value = replace(value, old_new_pairs...)
            push!(metadata_pairs, field => new_value)
        end
    end
    for field in ("LABL_PTR_1",) ∩ keys(m)
        values = m[field]
        if any(occursin(first(values)), old_coords)
            new_value = replace.(values, old_new_pairs...)
            push!(metadata_pairs, field => new_value)
        end
    end
    new_da = setmeta(da, metadata_pairs...)

    # Update name
    name = string(da.name)
    if any(occursin(name), old_coords)
        new_name = replace(name, old_new_pairs...)
        new_da = rebuild(new_da, name = Symbol(new_name))
    end

    # Update dimension names if they contain the coordinate system
    for dim in dims(new_da)
        dim_name = string(DD.name(dim))
        if any(occursin(dim_name), old_coords)
            new_dim_name = replace(dim_name, old_new_pairs...)
            new_da = DD.set(new_da, dim => Dim{Symbol(new_dim_name)})
        end
    end

    return new_da
end

set_coord(coord; kwargs...) = da -> set_coord(da, coord; kwargs...)
