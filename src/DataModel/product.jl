struct Product <: AbstractProduct
    name::String
    transformation::Function
    data::Any
    metadata::Any
end

function Product(; name, transformation=identity, data, metadata=Dict(), kwargs...)
    metadata = merge(metadata, kwargs)
    Product(
        name,
        transformation,
        data,
        metadata
    )
end

data(p::Product) = p.data
func(p::AbstractProduct) = identity
func(p::Product) = p.transformation

(p::AbstractProduct)(args...) = func(p)(data(p), args...)

"""Create a new product with the composed function"""
function ∘(f, p::AbstractProduct)
    typeof(p)(p.name, f ∘ func(p), data(p), p.metadata)
end

# Allow chaining of transformations with multiple products
function ∘(g::AbstractProduct, f::AbstractProduct)
    # Create a new product that applies both functions
    typeof(g)(g.name, g.transformation ∘ f.transformation, g.data, g.metadata)
end

function set(ds::Product, args...; name=nothing, data=nothing, kwargs...)
    !isnothing(name) && (ds = @set ds.name = name)
    !isnothing(data) && (ds = @set ds.data = data)
    (!isnothing(kwargs) || !isnothing(args)) && (ds = @set ds.metadata = set(ds.metadata, args...; kwargs...))
    return ds
end

function set!!(ds::Product, args...; name=nothing, data=nothing, kwargs...)
    !isnothing(name) && (ds = @set ds.name = name)
    !isnothing(data) && (ds = @set ds.data = data)
    set!(ds.metadata, args...; kwargs...)
    ds
end