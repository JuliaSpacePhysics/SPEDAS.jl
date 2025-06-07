struct DataViewer{D} <: Function
    data::D
end

(d::DataViewer)(tmin, tmax) = tview(d.data, tmin, tmax)

"""
    transform_pipeline(x)

Transform data for plotting with the following pipeline:

 1. Custom transformations (`transform(x)`)
 2. String -> `SpeasyProduct`

See also: [`transform`](@ref)
"""
function transform_pipeline(x, args...)
    transform_speasy(transform(x, args...))
end

"""
    transform(args...; kwargs...)

Transform data into plottable format (e.g., `DimArray`).

Extend with `transform(x::MyType)` for custom types.
"""
transform(x, args...) = x
transform(x::AbstractArray{<:Number}, tmin, tmax) = DataViewer(x)
transform_speasy(x) = x
