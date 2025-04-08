abstract type AbstractDataSet <: AbstractProduct end

"""
    DataSet <: AbstractDataSet

A concrete dataset with a name, data (parameters), and metadata.
"""
@kwdef struct DataSet <: AbstractDataSet
    name::String = ""
    data::Union{Vector,Dict,NamedTuple} = Dict()
    metadata::Dict = Dict()
end

"""Construct a `DataSet` from a name and data, with optional metadata."""
DataSet(name, data; metadata=Dict(), kwargs...) = DataSet(name, data, merge(metadata, kwargs))

function fmap(fs, args...; kwargs...)
    map(fs) do f
        !isempty(methods(f)) ? f(args...; kwargs...) : f
    end
end

data(ds::DataSet) = ds.data
func(ds::AbstractDataSet) = fmap

"""
    LDataSet <: AbstractDataSet

A template for generating datasets with parameterized naming patterns.

# Fields
- `format`: Format string pattern for the dataset name
- `data`: Dictionary of variable patterns
- `metadata`: Additional metadata

# Examples
```julia
using SPEDAS.MMS

# Access FPI dataset specification
lds = mms.datasets.fpi_moms

# Create a concrete dataset with specific parameters
ds = DataSet(lds; probe=1, data_rate="fast", data_type="des")
```

The format string and variable patterns use placeholders like `{probe}`, `{data_rate}`, 
which are replaced with actual values when creating a concrete `DataSet`.
"""
@kwdef struct LDataSet <: AbstractDataSet
    name::String = ""
    format::String = ""
    data::Dict{String,String} = Dict()
    metadata::Dict = Dict()
end

"Construct a `LDataSet` from a dictionary."
function LDataSet(d::Dict)
    dict = symbolify(d)
    rename!(dict, :parameters, :data)
    LDataSet(; dict...)
end

"""
    DataSet(ld::LDataSet; kwargs...)

Create a concrete `DataSet` from a Dataset template with specified data.

See also: [`LDataSet`](@ref)
"""
function DataSet(ld::LDataSet; kwargs...)
    DataSet(
        uppercase(format_pattern(ld.format; kwargs...)),
        Dict(k => format_pattern(v; kwargs...) for (k, v) in ld.data),
        ld.metadata
    )
end

Base.length(ds::AbstractDataSet) = length(ds.data)
Base.getindex(ds::AbstractDataSet, i) = ds.data[i]
Base.iterate(ds::AbstractDataSet, state=1) = state > length(ds) ? nothing : (ds.data[state], state + 1)
Base.map(f, ds::AbstractDataSet) = map(f, ds.data)

_repr(ld::LDataSet) = isempty(ld.name) ? ld.format : ld.name