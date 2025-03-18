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
"""
struct Instrument <: AbstractInstrument
    name::String
    metadata::Dict
end

"keyword-based constructor"
Instrument(; name="", metadata=Dict(), kwargs...) = Instrument(name, merge(metadata, Dict(kwargs)))

"Construct an `Instrument` from a dictionary."
Instrument(d::Dict) = Instrument(; symbolify(d)...)

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