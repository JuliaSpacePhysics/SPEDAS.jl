using SpaceDataModel

plottype(::AbstractProduct) = FunctionPlot
plottype(::AbstractDataSet) = MultiPlot

transform_speasy(ds::AbstractDataSet) = @set ds.data = transform_speasy.(ds.data)

function axis_attributes(ds::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ds))
    attrs
end