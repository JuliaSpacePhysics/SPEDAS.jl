abstract type AbstractDataSet <: AbstractModel end

"""
    DataSet <: AbstractDataSet

A concrete dataset with a name, parameters, and metadata.
"""
struct DataSet <: AbstractDataSet
    name::String
    parameters::Union{Vector,Dict,NamedTuple}
    metadata::Dict
end

DataSet(name, parameters; metadata=Dict()) = DataSet(name, parameters, metadata)

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
    parameters::Dict = Dict()
    metadata::Dict = Dict()
end

"Construct a `LDataSet` from a dictionary."
LDataSet(d::Dict) = LDataSet(; symbolify(d)...)

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

# Custom display methods for DataSet type
function Base.show(io::IO, ::MIME"text/plain", ds::T) where {T<:AbstractDataSet}
    println(io, "$(T): \"$(ds.name)\"")

    # Display metadata if present
    if !isempty(ds.metadata)
        println(io, "  Metadata:")
        for (key, value) in ds.metadata
            println(io, "    $key: $value")
        end
    end

    if !isempty(ds.parameters)
        println(io, "  Parameters ($(length(ds.parameters))):")
        for (i, param) in enumerate(ds.parameters)
            if i <= 5
                println(io, "    $param")
            else
                println(io, "    ⋮")
                break
            end
        end
    end
end

Base.show(io::IO, p::T) where {T<:AbstractDataSet} = print(io, "$(T)(\"$(p.name)\")")
