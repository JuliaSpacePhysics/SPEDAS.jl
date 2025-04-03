"""
    transform_pipeline(x)

Transform data for plotting with the following pipeline:
1. Custom transformations (`transform(x)`)
2. String -> `SpeasyProduct`

See also: [`transform`](@ref)
"""
transform_pipeline(x) = x |> transform |> transform_speasy

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x) = x

transform_speasy(x::String) = SpeasyProduct(x)
transform_speasy(x::AbstractArray{String}) = map(SpeasyProduct, x)
transform_speasy(x::NTuple{N,String}) where {N} = map(SpeasyProduct, x)
transform_speasy(x) = x
transform_speasy(ds::AbstractDataSet) = @set ds.parameters = transform_speasy.(ds.parameters)

transform(x::AbstractDimStack) = layers(x)