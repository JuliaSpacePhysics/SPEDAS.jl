abstract type AbstractDataSet end

struct DataSet{MD} <: AbstractDataSet
    name::String
    parameters::Vector
    metadata::MD
end

DataSet(name, parameters; metadata=Dict()) = DataSet(name, parameters, metadata)

meta(ds::DataSet) = ds.metadata
Base.length(ds::DataSet) = length(ds.parameters)
Base.getindex(ds::DataSet, i) = ds.parameters[i]
Base.map(f, ds::DataSet) = map(f, ds.parameters)

title(ds::DataSet) = ds.name
transform(ds::DataSet) = ds.parameters

function axis_attributes(ds::DataSet; add_title=false, kwargs...)
    attrs = Attributes(; kwargs...)
    add_title && (attrs[:title] = title(ds))
    attrs
end
