import Makie.SpecApi as S
using Latexify


"""
Transform a function that handles time range to a function that handles x range (time values) and return x and y values.
"""
function time2value_transform(xrange, f)
    trange = x2t.(xrange)
    da = f(trange...)
    return t2x(da), vs(da)
end

time2value_transform(f) = (xrange) -> time2value_transform(xrange, f)

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure
    axes::AbstractArray{<:Axis}
end

struct AxisPlots
    axis
    plots
end

const Drawable = Union{Figure,GridPosition,GridSubposition}
const SupportTypes = Union{AbstractDimArray,AbstractDimMatrix,Function,String}

"""
    tplot(f, tas; legend=(; position=Right()), link_xaxes=true, rowgap=5, kwargs...)

Lay out multiple time series across different panels (rows) on one Figure / GridPosition `f`

If `legend` is `nothing`, no legend will be added to the plot. Otherwise, `legend` can be a `NamedTuple` containing options for legend placement and styling.
"""
function tplot(f::Drawable, tas, args...; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, kwargs...)
    palette = [(i, 1) for i in 1:length(tas)]
    gaps = map(palette, tas) do pos, ta
        gp = f[pos...]
        ap = tplot_panel(gp, ta, args...; kwargs...)
        # Hide redundant x labels
        link_xaxes && pos[1] != length(tas) && hidexdecorations!(ap.axis, grid=false)
        (gp, ap)
    end
    axs = map(gap -> gap[2].axis, gaps)
    gps = map(gap -> gap[1], gaps)

    link_xaxes && linkxaxes!(axs...)
    link_yaxes && linkyaxes!(axs...)

    !isnothing(legend) && add_legend!.(gps, axs; legend...)

    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

tplot(f::Drawable, ta::SupportTypes, args...; kwargs...) = tplot(f, (ta,), args...; kwargs...)
tplot(tas, args...; figure=(;), kwargs...) = tplot(Figure(; figure...), tas, args...; kwargs...)
tplot(ds::AbstractDimStack; kwargs...) = tplot(layers(ds); kwargs...)

function tplot! end

"Setup the panel on a position and plot multiple time series on it"
function tplot_panel(gp, tas::AbstractVector, args...; add_title=false, kwargs...)
    ax = Axis(gp; axis_attributes(tas; add_title)...)
    plots = map(tas) do ta
        tplot_panel!(ax, ta, args...; kwargs...)
    end
    AxisPlots(ax, plots)
end

"""
    tplot_panel(gp, ta::AbstractDimMatrix)

Plot a multivariate time series / spectrogram on a panel
"""
function tplot_panel(gp, ta::AbstractDimMatrix; add_colorbar=true, add_title=false, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)...)
    plots = tplot_panel!(ax, ta; kwargs...)
    pos = gp[1, 2]
    add_colorbar && isspectrogram(ta) && Colorbar(pos, plots; label=clabel(ta))
    AxisPlots(ax, plots)
end

"""
    tplot_panel(gp, ta::AbstractDimVector)

Plot a univariate time series on a panel.
Only add legend when the axis contains multiple labels.
"""
function tplot_panel(gp, ta::AbstractDimVector; add_title=false, kwargs...)
    lines(gp, ta; plot_attributes(ta; add_title)..., kwargs...)
end

"""
Plot heatmap / overlay multiple columns of a time series on the same axis
"""
function tplot_panel!(ax::Axis, ta::AbstractDimMatrix; labels=labels(ta), kwargs...)
    x = dims(ta, Ti).val
    if !isspectrogram(ta)
        map(eachcol(ta.data), labels) do y, label
            lines!(ax, x, y; label, kwargs...)
        end
    else
        heatmap!(ax, x, spectrogram_y_values(ta), ta.data; heatmap_attributes(ta; kwargs...)...)
    end
end

tplot_panel!(ax::Axis, ta::AbstractDimVector; kwargs...) = lines!(ax, ta; kwargs...)

####################
## Interactive tplot
####################

"""
    Interactive tplot of a function over a time range
"""
function tplot_panel(gp, f::Function, tmin::DateTime, tmax::DateTime; add_title=false, add_colorbar=true, xtickformat=format_datetime, kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = plot_attributes(ta; add_title)

    # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
    # https://github.com/MakieOrg/Makie.jl/issues/4769
    xmin, xmax = t2x.((tmin, tmax))
    attrs.axis.xtickformat = values -> xtickformat.(x2t.(values))

    if isspectrogram(ta)
        y = spectrogram_y_values(ta)
        plot_func = (x, mat) -> heatmap(gp, x, y, mat; attrs..., kwargs...)
    else
        plot_type = ndims(ta) == 2 ? series : lines
        plot_func = (xs, vs) -> plot_type(gp, xs, vs; attrs..., kwargs...)
    end

    data = RangeFunction1D(time2value_transform(f), xmin, xmax)
    fapex = iviz(plot_func, data)
    isspectrogram(ta) && add_colorbar && Colorbar(gp[1, 1, Right()], fapex.fap.plot; label=clabel(ta))
    fapex
end

function tplot_panel(gp, fs::AbstractVector, tmin::DateTime, tmax::DateTime; axis=(;), add_title=false, kwargs...)
    tas = get_data.(fs, tmin, tmax; kwargs...)
    ax = Axis(gp; axis_attributes(tas; add_title)..., axis...)
    plots = iviz_api(fs, tmin, tmax; kwargs...)
    return AxisPlots(ax, plots)
end

function tplot_spec(da::AbstractDimMatrix; labels=labels(da), samples=10000, kwargs...)
    x = dims(da, Ti).val

    if length(x) > samples
        indices = round.(Int, range(1, length(x), length=samples))
        x = x[indices]
        da = da[indices, :]
    end

    if !isspectrogram(da)
        map(eachcol(da.data), labels) do y, label
            S.Lines(x, y; label, kwargs...)
        end
    else
        S.Heatmap(x, spectrogram_y_values(da), da.data; kwargs...)
    end
end

######################
## Extension interface
######################

"""
    tplot_panel(gp, ta, args...; kwargs...)

Extension interface for plotting custom data types. To support a new data type:
1. Define a method for `get_data(ta, args...; kwargs...)` that converts your type to a DimensionalData array
2. Optionally include metadata for labels, units, and other plotting attributes
"""
tplot_panel(gp, ta, args...; kwargs...) = tplot_panel(gp, get_data(ta, args...); kwargs...)

function tplot_panel(gp, ta, tmin::DateTime, tmax::DateTime; kwargs...)
    f = (args...) -> get_data(ta, args...)
    tplot_panel(gp, f, tmin, tmax; kwargs...)
end

"""
    tplot_panel!(ax::Axis, ta, args...; kwargs...)

Extension interface for plotting custom data types. See `tplot_panel` for more details.
"""
tplot_panel!(ax::Axis, ta, args...; kwargs...) = tplot_panel!(ax, get_data(ta, args...); kwargs...)

tplot_spec(args...; kwargs...) = tplot_spec(get_data(args...); kwargs...)

##########
## Recipes
##########

"""
    tsheat(data; kwargs...)

Heatmap with better default attributes for time series.

References:
- https://docs.makie.org/stable/reference/plots/heatmap
"""
function tsheat(da::AbstractDimArray; colorscale=log10, colorrange=colorrange(da), kwargs...)

    fig, ax, hm = heatmap(da; colorscale, colorrange, kwargs...)
    Colorbar(fig[:, end+1], hm)

    # rasterize the heatmap to reduce file size
    if *(size(da)...) > 32^2
        hm.rasterize = true
    end

    fig, ax, hm
end

Base.display(fg::FigureAxes) = display(fg.figure)
Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.show(io::IO, m::MIME, fg::FigureAxes) = show(io, m, fg.figure)
Base.show(io::IO, ::MIME"text/plain", fg::FigureAxes) = print(io, "FigureAxes()")
Base.showable(mime::MIME{M}, fg::FigureAxes) where {M} = showable(mime, fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)