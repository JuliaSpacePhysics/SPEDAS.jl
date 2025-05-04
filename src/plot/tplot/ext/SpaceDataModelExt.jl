using SpaceDataModel

plottype(x::AbstractDataVariable) = isspectrogram(x) ? SpecPlot : LinesPlot
plottype(::AbstractProduct) = FunctionPlot
plottype(::AbstractDataSet) = MultiPlot

makie_x(da::AbstractDataVariable) = makie_t2x(parent(times(da)))

MakieCore.convert_arguments(::Type{<:LinesPlot}, da::AbstractDataVariable; kwargs...) = plot2spec(LinesPlot, da; kwargs...)

transform_speasy(ds::AbstractDataSet) = @set ds.data = transform_speasy.(ds.data)

function axis_attributes(ds::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ds))
    attrs
end