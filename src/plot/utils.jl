import ..SPEDAS: yvalues

set_if_valid!(d, val, key) = setindex!(d, val, key)
set_if_valid!(d, val::Union{AbstractString,AbstractArray}, key) = isempty(val) || setindex!(d, val, key)
function set_if_valid!(d, ::Nothing, key) end
function set_if_valid!(d, pairs::Pair...)
    for (key, value) in pairs
        set_if_valid!(d, value, key)
    end
end

"""Set an attribute if all values are equal and non-empty"""
function set_if_equal!(attrs, key, values; default=nothing)
    val = allequal(values) ? first(values) : default
    set_if_valid!(attrs, val, key)
end

_merge(x, args...) = merge(x, args...)
_merge(x::Dict, y::NamedTuple) = merge(x, Dict(pairs(y)))

"""
Convert x to DateTime

Reference:
- https://docs.makie.org/dev/explanations/dim-converts#Makie.DateTimeConversion
- https://github.com/MakieOrg/Makie.jl/issues/442
- https://github.com/MakieOrg/Makie.jl/blob/master/src/dim-converts/dates-integration.jl
"""
x2t(x::Millisecond) = DateTime(Dates.UTM(x))
x2t(x::Float64) = DateTime(Dates.UTM(round(Int64, x)))


"""
    spectrogram_y_values(ta; check=false, center=false, transform=identity)

Get y-axis values from a spectrogram array.
Can return either bin centers or edges. By default, return bin edges for better compatibility.

# Arguments
- `check`: If true, check if values are constant along time
- `center`: If true, return bin centers instead of edges
- `transform`: Optional transform function for edge calculation (e.g., log for logarithmic bins)

Reference: Makie.edges
"""
function spectrogram_y_values(ta; check=false, center=true, transform=yscale(ta))
    centers = yvalues(Vector, ta)
    if center && transform == log10
        edges = binedges(centers)
        if first(edges) < zero(eltype(edges)) || last(edges) < zero(eltype(edges))
            @warn "Automatically using edge for Makie because transform == $transform and the first edge is negative"
            center = false
        end
    end

    !center ? binedges(centers; transform) : centers
end

function donothing(args...; kwargs...) end