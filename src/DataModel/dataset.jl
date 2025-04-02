abstract type AbstractDataSet <: AbstractModel end

"""
    DataSet <: AbstractDataSet

A concrete dataset with a name, parameters, and metadata.
"""
@kwdef struct DataSet{M} <: AbstractDataSet
    name::String = ""
    parameters::Union{Vector,Dict,NamedTuple} = Dict()
    metadata::M = Dict()
end

"""Construct a `DataSet` from a name and parameters, with optional metadata."""
DataSet(name, parameters; metadata::M=Dict()) where {M} = DataSet{M}(name, parameters, metadata)

"""
    LDataSet <: AbstractDataSet

A template for generating datasets with parameterized naming patterns.

# Fields
- `format`: Format string pattern for the dataset name
- `variables`: Dictionary of variable patterns
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
    parameters::Dict{String,String} = Dict()
    metadata::Dict = Dict()
end

"Construct a `LDataSet` from a dictionary."
LDataSet(d::Dict) = LDataSet(; symbolify(d)...)

"""
    DataSet(ld::LDataSet; kwargs...)

Create a concrete `DataSet` from a Dataset template with specified parameters.

See also: [`LDataSet`](@ref)
"""
function DataSet(ld::LDataSet; kwargs...)
    DataSet(
        uppercase(format_pattern(ld.format; kwargs...)),
        Dict(k => format_pattern(v; kwargs...) for (k, v) in ld.parameters),
        ld.metadata
    )
end

Base.length(ds::AbstractDataSet) = length(ds.parameters)
Base.getindex(ds::AbstractDataSet, i) = ds.parameters[i]
Base.map(f, ds::AbstractDataSet) = map(f, ds.parameters)

_repr(ld::LDataSet) = isempty(ld.name) ? ld.format : ld.name
