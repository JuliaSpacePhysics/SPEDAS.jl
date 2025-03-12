abstract type AbstractModel end
abstract type AbstractProject <: AbstractModel end
abstract type AbstractInstrument <: AbstractModel end

"""
    Project <: AbstractProject

A representation of a project or mission containing instruments and datasets.

# Fields
- `name`: The name of the project
- `metadata`: Additional metadata
- `instruments::NamedTuple`: Named collection of instruments
- `datasets::NamedTuple`: Named collection of datasets

# Examples
```julia
using SpaceTools.MMS # Export project related variables
mms  # Project instance for Magnetospheric Multiscale mission

# Access instruments
mms.instruments.fpi  # Fast Plasma Investigation instrument

# Access datasets
mms.datasets.fpi  # FPI dataset specification
```
"""
mutable struct Project <: AbstractProject
    name::String
    metadata::Dict
    instruments::NamedTuple
    datasets::NamedTuple
end

"keyword-based constructor"
Project(; name="", instruments=(;), datasets=(;), metadata=Dict(), kwargs...) = Project(name, merge(metadata, Dict(kwargs)), instruments, datasets)

"""
    Instrument <: AbstractInstrument

# Fields
- `name`: The name of the instrument
- `metadata`: Additional metadata

# Examples
```julia
using SpaceTools.MMS
fpi  # Fast Plasma Investigation instrument
```
"""
@kwdef struct Instrument <: AbstractInstrument
    name::String
    metadata::Dict = Dict()
end

"Construct an `Instrument` from a dictionary."
Instrument(d::Dict) = Instrument(; symbolify(d)...)

"""
    LDataSet <: AbstractDataSet

A template for generating datasets with parameterized naming patterns.

# Fields
- `format`: Format string pattern for the dataset name
- `variables`: Dictionary of variable patterns
- `metadata`: Additional metadata

# Examples
```julia
using SpaceTools.MMS

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
    variables::Dict = Dict()
    metadata::Dict = Dict()
end

"Construct a `LDataSet` from a dictionary."
LDataSet(d::Dict) = LDataSet(; symbolify(d)...)

# Custom display methods for Project type
Base.show(io::IO, p::T) where {T<:AbstractModel} = print(io, "$(T)(\"$(p.name)\")")

function Base.show(io::IO, ::MIME"text/plain", p::Project)
    println(io, "Project: $(p.name)")

    # Display metadata if present
    if !isempty(p.metadata)
        println(io, "  Metadata:")
        for (key, value) in p.metadata
            println(io, "    $key: $value")
        end
    end

    # Display instruments if present
    if !isempty(p.instruments)
        println(io, "  Instruments:")
        for (key, instr) in pairs(p.instruments)
            println(io, "    $key: $(instr.name)")
        end
    end

    # Display datasets if present
    if !isempty(p.datasets)
        println(io, "  Datasets:")
        for (key, _) in pairs(p.datasets)
            println(io, "    $key")
        end
    end
end