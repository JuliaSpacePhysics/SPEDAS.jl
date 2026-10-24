module SPEDAS

using ConstructionBase: setproperties
using Reexport: @reexport
@reexport using SpaceDataModel
using SpaceDataModel: meta, setmeta
@reexport using TimeseriesUtilities
@reexport using MinimumVarianceAnalysis
@reexport using PlasmaWaves
@reexport using MultiSpacecraftAnalysis
@reexport using GeoCotrans

export setcoord
export cotrans

include("cotrans.jl")
end
