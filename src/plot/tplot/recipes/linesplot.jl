# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl
import Makie: convert_arguments, plot!

@recipe LinesPlot begin end

Makie.conversion_trait(::Type{<:LinesPlot}) = Makie.PointBased()

function Makie.convert_arguments(T::Type{<:LinesPlot}, da::AbstractDimMatrix)
    x = lookup(dims(da, Ti))
    ys = parent(da)
    points = map(1:size(ys, 2)) do i
        (x, view(ys, :, i))
    end
    return (points,)
end

function Makie.plot!(plot::LinesPlot)
    curves = plot[1][]
    nseries = length(curves)
    for i in 1:nseries
        positions = lift(c -> c[i], plot, curves)
        lines!(plot, positions)
    end
end

"""
    linesplot(gp, ta)

Plot a multivariate time series on a panel
"""
function linesplot(gp, ta; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = linesplot!(ax, ta; kwargs...)
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end

"""
Plot multiple columns of a time series on the same axis
"""
function linesplot!(ax::Axis, ta; labels=labels(ta), kwargs...)
    ta = resample(ta)
    x = dims(ta, Ti).val
    map(eachcol(ta.data), labels) do y, label
        lines!(ax, x, y; label, kwargs...)
    end
end