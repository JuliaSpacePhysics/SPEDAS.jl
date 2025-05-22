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
function set_coord(da, coord; old_coords=get_coords(da))
    # Update the coordinate system metadata
    new_da = modify_meta(da, "COORDINATE_SYSTEM" => coord)
    old_new_pairs = [old_coord => coord for old_coord in old_coords]
    push!(old_coords, lowercase.(old_coords)...)
    push!(old_new_pairs, _lowercase.(old_new_pairs)...)

    # Get the current metadata
    m = meta(new_da)

    # Update legend names and axis label if they include the coordinate system
    if haskey(m, "LABLAXIS")
        if !isnothing(old_coords)
            # Replace old coordinate system with new one in the label
            label = m["LABLAXIS"]
            if occursin(string(old_coords), label)
                new_label = replace(label, string(old_coords) => coord)
                new_da = modify_meta(new_da; LABLAXIS=new_label)
            end
        end
    end

    # Update other potential metadata fields that might contain coordinate info
    for field in ["UNITS", "FIELDNAM", "CATDESC", "DICT_KEY"] ∩ keys(m)
        value = m[field]
        # Replace old coordinate system with new one in the field
        if any(occursin.(old_coords, Ref(value)))
            new_value = replace(value, old_new_pairs...)
            new_da = modify_meta(new_da, field => new_value)
        end
    end

    for field in ["LABL_PTR_1"] ∩ keys(m)
        value = m[field]
        if any(occursin.(old_coords, first(value)))
            new_value = replace.(value, old_new_pairs...)
            new_da = modify_meta(new_da, field => new_value)
        end
    end

    # Update name
    name = string(da.name)
    if any(occursin(name).(old_coords))
        new_name = replace(name, old_new_pairs...)
        new_da = rename(new_da, Symbol(new_name))
    end

    # Update dimension names if they contain the coordinate system
    for dim in dims(new_da)
        dim_name = string(DD.name(dim))
        if any(occursin.(old_coords, Ref(dim_name)))
            new_dim_name = replace(dim_name, old_new_pairs...)
            new_da = DD.set(new_da, dim => Dim{Symbol(new_dim_name)})
        end
    end

    return new_da
end

set_coord(coord; kwargs...) = da -> set_coord(da, coord; kwargs...)