abstract type AbstractDataSet end

struct DataSet <: AbstractDataSet
    name::String
    parameters::Vector
    metadata::Dict
end

DataSet(name, parameters; metadata=Dict()) = DataSet(name, parameters, metadata)

meta(ds::DataSet) = ds.metadata
Base.length(ds::DataSet) = length(ds.parameters)
Base.getindex(ds::DataSet, i) = ds.parameters[i]
Base.map(f, ds::DataSet) = map(f, ds.parameters)

title(ds::DataSet) = ds.name

function axis_attributes(ds::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ds))
    attrs
end

"Setup the panel on a position and plot multiple time series on it"
function tplot_panel(gp, ds::DataSet, args...; add_title=false, kwargs...)
    axis = axis_attributes(ds; add_title)
    return tplot_panel(gp, ds.parameters, args...; axis, kwargs...)
end
