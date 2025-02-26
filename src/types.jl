
@kwdef mutable struct Defaults
    add_title::Bool = false
end

"""
    SpaceTools.DEFAULTS

A global constant that holds default parameters:

- `SpaceTools.DEFAULTS.add_title::Bool` defaults to `false`.
"""
const DEFAULTS = Defaults(
    add_title=false
)

struct SpeasyProduct
    id::String
end

transform_speasy(x) = x isa String ? SpeasyProduct(x) : x