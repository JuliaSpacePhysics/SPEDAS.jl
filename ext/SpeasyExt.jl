module SpeasyExt

using SpaceTools
using Speasy
using DimensionalData
import SpaceTools: xlabel, ylabel

function SpaceTools.tplot_panel(gd, s::AbstractString, args...; kwargs...)
    fs = (args...) -> DimArray(get_data(s, args...))
    tplot_panel(gd, fs, args...; kwargs...)
end

function SpaceTools.tplot_panel(gd, ta::SpeasyVariable, args...; kwargs...)
    tplot_panel(gd, DimArray(ta), args...; kwargs...)
end

function SpaceTools.tplot_panel!(ax, ta::SpeasyVariable, args...; kwargs...)
    tplot_panel!(ax, DimArray(ta), args...; kwargs...)
end

SpaceTools.ylabel(ta::SpeasyVariable) = ta.meta["LABLAXIS"]

end