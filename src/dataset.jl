abstract type AbstractDataSet end

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
