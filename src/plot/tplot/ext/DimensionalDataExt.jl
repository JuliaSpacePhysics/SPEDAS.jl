import DimensionalData
using DimensionalData: AbstractDimArray, AbstractDimVector, AbstractDimMatrix, AbstractDimStack
using ..SPEDAS: times

plottype(::AbstractDimVector) = LinesPlot
plottype(::AbstractDimStack) = MultiPlot
plottype(x::AbstractDimMatrix) = isspectrogram(x) ? SpecPlot : LinesPlot

makie_x(da::AbstractDimArray) = makie_t2x(parent(times(da)))

"""Plot attributes for a time array (labels)"""
function plottype_attributes(ta::AbstractArray)
    attrs = Attributes()
    # handle spectrogram
    if !isspectrogram(ta)
        if ndims(ta) == 2
            attrs[:labels] = labels(ta)
        else
            attrs[:label] = label(ta)
        end
    else
        merge!(attrs, heatmap_attributes(ta))
    end
    attrs
end

"""Plot attributes for a time array (axis + labels)"""
function plot_attributes(ta::AbstractDimArray; add_title=false, axis=(;))
    attrs = plottype_attributes(ta)
    attrs[:axis] = axis_attributes(ta; add_title, axis...)
    attrs
end


MakieCore.convert_arguments(::Type{<:LinesPlot}, da::AbstractDimMatrix; kwargs...) = plot2spec(LinesPlot, da; kwargs...)
MakieCore.convert_arguments(::Type{<:LinesPlot}, da::AbstractDimVector; kwargs...) = plot2spec(LinesPlot, da; kwargs...)
MakieCore.convert_arguments(t::Type{<:LinesPlot}, da::AbstractDimVector{<:AbstractVector}) = convert_arguments(t, tstack(da))