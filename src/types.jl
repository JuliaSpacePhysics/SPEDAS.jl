# Overload function composition operator for AbstractProduct
import Base: ∘

@kwdef mutable struct Defaults
    add_title::Bool
    add_colorbar::Bool
    delay::Float64
    resample::Int
end

"""
    SpaceTools.DEFAULTS

A global constant that holds default parameters:

- `add_title::Bool` defaults to `false`.
- `add_colorbar::Bool` defaults to `true`.
- `delay` : in seconds, the time interval between updates. Default is 0.25.
- `resample::Int` : the number of points to resample to. Default is 6070.
"""
const DEFAULTS = Defaults(;
    add_title=false,
    add_colorbar=true,
    delay=0.25,
    resample=6070
)

abstract type AbstractProduct end

struct SpeasyProduct <: AbstractProduct
    id::String
    func::Function
end

SpeasyProduct(id::String) = SpeasyProduct(id, get_data)

(p::SpeasyProduct)(args...) = p.func(p, args...)

"""Create a new product with the composed function"""
function ∘(f::Function, p::AbstractProduct)
    typeof(p)(p.id, f ∘ p.func)
end

# Allow chaining of transformations with multiple products
function ∘(g::AbstractProduct, f::AbstractProduct)
    # Create a new product that applies both functions
    # This maintains the ID of the second product
    typeof(g)(g.id, x -> g.func(f.func(x)))
end