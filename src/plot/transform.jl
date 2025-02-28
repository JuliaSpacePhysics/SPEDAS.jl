"""
    transform_pipeline(x)

Transform data for plotting with the following pipeline:
1. Custom transformations (`transform(x)`)
2. String -> `SpeasyProduct`
3. 2-element tuple -> `DualAxisData`

See also: [`transform`](@ref)
"""
transform_pipeline(x) = x |> transform |> transform_speasy |> transform_dual

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x) = x

transform_speasy(x::Union{String,AbstractArray{String}}) = SpeasyProduct.(x)
transform_speasy(x) = x

transform_dual(x::Tuple{Any,Any}) = DualAxisData(x[1], x[2])
transform_dual(x) = x