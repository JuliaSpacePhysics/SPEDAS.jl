"""
    transform_pipeline(x)

Transform data for plotting with the following pipeline:
1. Custom transformations (`transform(x)`)
2. String -> `SpeasyProduct`
3. 2-column matrix -> `DualAxisData`

See also: [`transform`](@ref)
"""
transform_pipeline(x) = x |> transform |> transform_speasy |> transform_matrix

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
function transform end

transform(x) = x
transform(p::SpeasyVariable; kwargs...) = DimArray(p; kwargs...)
transform(p::AbstractArray{SpeasyVariable}; kwargs...) = DimArray.(p; kwargs...)
transform_speasy(x::Union{String,AbstractArray{String}}) = SpeasyProduct.(x)
transform_speasy(x) = x
transform_matrix(x::AbstractMatrix) = size(x, 2) == 2 ? DualAxisData(view(x, :, 1), view(x, :, 2)) : x
transform_matrix(x) = x

get_data(p::SpeasyProduct, args...; kwargs...) = transform(Speasy.get_data(p.id, args...; kwargs...))
axis_attributes(sps::AbstractVector{SpeasyProduct}, tmin, tmax; kwargs...) =
    axis_attributes(get_data.(sps, tmin, tmax); kwargs...)