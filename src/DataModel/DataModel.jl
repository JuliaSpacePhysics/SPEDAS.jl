module SpaceDataModel
using Accessors: @set
import Base: ∘
export AbstractModel, AbstractProject, AbstractInstrument, AbstractProduct, AbstractDataSet
export Project, Instrument, DataSet, LDataSet, Product
export abbr

include("utils.jl")
include("types.jl")
include("dataset.jl")
include("methods.jl")
include("product.jl")
end