abstract type AbstractModel end
abstract type AbstractProject <: AbstractModel end
abstract type AbstractInstrument <: AbstractModel end

"""
    Project <: AbstractProject

A representation of a project or mission containing instruments and datasets.

# Fields
- `name`: The name of the project
- `metadata`: Additional metadata
- `instruments`: Collection of instruments
- `datasets`: Collection of datasets
"""
mutable struct Project <: AbstractProject
    name::String
    metadata::Dict
    instruments::Dict
    datasets::Dict
end

"keyword-based constructor"
Project(; name="", instruments=Dict(), datasets=Dict(), metadata=Dict(), kwargs...) = Project(name, merge(metadata, Dict(kwargs)), instruments, datasets)

"""
    Instrument <: AbstractInstrument

# Fields
- `name`: The name of the instrument
- `metadata`: Additional metadata
- `datasets`: Collection of datasets
"""
struct Instrument <: AbstractInstrument
    name::String
    metadata::Dict
    datasets::Dict
end

"keyword-based constructor"
Instrument(; name="", metadata=Dict(), datasets=Dict(), kwargs...) = Instrument(name, merge(metadata, Dict(kwargs)), datasets)

"Construct an `Instrument` from a dictionary."
Instrument(d::Dict) = Instrument(; symbolify(d)...)

name(m::AbstractModel) = m.name
_repr(m::AbstractModel) = name(m)
_repr(m) = m

# Custom display methods for Project type
Base.show(io::IO, p::T) where {T<:AbstractModel} = print(io, "$(T)(\"$(_repr(p))\")")

function Base.show(io::IO, ::MIME"text/plain", p::T) where {T<:AbstractModel}
    print(io, "$T: ")
    printstyled(io, _repr(p), color=:yellow)
    println(io)

    for field in setdiff(fieldnames(T), (:name, :format))
        ff = getfield(p, field)
        if !isempty(ff)
            println(io, titlecase("  $field ($(length(ff))):"))
            for (k, v) in ff
                println(io, "    $k: $(_repr(v))")
            end
        end
    end
end