# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl
import Makie: convert_arguments, plot!

struct NoDimConversion <: Makie.ConversionTrait end

@recipe LinesPlot begin
    labels = nothing
    # Makie.MakieCore.documented_attributes(Lines)...
    # resample = 10000
end

Makie.conversion_trait(::Type{<:LinesPlot}) = NoDimConversion()

function Makie.convert_arguments(::Type{<:LinesPlot}, x::AbstractVector, ys::AbstractMatrix)
    A = parent(ys)
    curves = map(i -> (x, view(A, :, i)), 1:size(A, 2))
    return (curves,)
end

function Makie.convert_arguments(T::Type{<:LinesPlot}, ys::AbstractMatrix)
    Makie.convert_arguments(T, 1:size(ys, 1), ys)
end

"""Convert the vector into a single-column matrix"""
function Makie.convert_arguments(T::Type{<:LinesPlot}, ys::AbstractVector{<:Number})
    return Makie.convert_arguments(T, reshape(ys, :, 1))
end

"""Convert the vector of vectors into a single vector of curves"""
function Makie.convert_arguments(T::Type{<:LinesPlot}, ys::Union{Tuple,AbstractVector})
    tuples = Makie.convert_arguments.(T, ys)
    curves_vec = first.(tuples)
    curves = reduce(vcat, curves_vec)
    return (curves,)
end

Makie.convert_arguments(::Type{<:LinesPlot}, da::DD.AbstractDimMatrix; kwargs...) = plot2spec(LinesPlot, da; kwargs...)
Makie.convert_arguments(::Type{<:LinesPlot}, da::DD.AbstractDimVector; kwargs...) = plot2spec(LinesPlot, da; kwargs...)

function plot2spec(::Type{<:LinesPlot}, da::DimensionalData.AbstractDimMatrix; labels=labels(da))
    x = xs(da)
    map(enumerate(eachcol(parent(da)))) do (i, y)
        S.Lines(x, y; label=get(labels, i, nothing))
    end
end

function plot2spec(::Type{<:LinesPlot}, da::DimensionalData.AbstractDimVector; labels=nothing, label=nothing)
    label = @something label labels to_value(label(da))
    S.Lines(xs(da), parent(da); label)
end

function Makie.convert_arguments(t::Type{<:LinesPlot}, da::DimensionalData.AbstractDimVector{<:AbstractVector})
    Makie.convert_arguments(t, tstack(da))
end


function Makie.plot!(plot::LinesPlot)
    curves = plot[1]
    nseries = length(curves[])
    for i in 1:nseries
        positions = lift(c -> c[i], plot, curves)
        x = lift(x -> x[1], positions)
        y = lift(x -> x[2], positions)
        lines!(plot, x, y)
    end
end

"""
    linesplot(gp, ta)

Plot a multivariate time series on a panel
"""
function linesplot(gp::Drawable, ta; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = linesplot!(ax, ta; kwargs...)
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end