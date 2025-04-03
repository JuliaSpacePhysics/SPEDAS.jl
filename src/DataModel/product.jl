import Base: ∘

abstract type AbstractProduct end

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

(p::Product)(args...) = p.transformation(p.data, args...)

"""Create a new product with the composed function"""
function ∘(f, p::AbstractProduct)
    typeof(p)(p.name, f ∘ p.transformation, p.data, p.metadata)
end

# Allow chaining of transformations with multiple products
function ∘(g::AbstractProduct, f::AbstractProduct)
    # Create a new product that applies both functions
    typeof(g)(g.name, g.transformation ∘ f.transformation, g.data, g.metadata)
end

function SpeasyProduct end