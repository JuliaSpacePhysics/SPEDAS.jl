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

"""
    tplot(f, tas; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, transform=transform_pipeline, kwargs...)

Lay out multiple time series across different panels (rows) on one Figure / GridPosition `f`

If `legend` is `nothing`, no legend will be added to the plot. Otherwise, `legend` can be a `NamedTuple` containing options for legend placement and styling.
By default, the time series are transformed via `transform_pipeline`, which is extensible via `transform`.

See also: [`tplot_panel`](@ref), [`transform_pipeline`](@ref), [`transform`](@ref)
"""
function tplot(f::Drawable, tas, args...; legend=(; position=Right()), link_xaxes=true, link_yaxes=false, rowgap=5, transform=transform_pipeline, kwargs...)
    palette = [(i, 1) for i in 1:length(tas)]
    gaps = map(palette, tas) do pos, ta
        gp = f[pos...]
        axis = axis_attributes(ta; kwargs...)
        pap = tplot_panel(gp, transform(ta), args...; axis, kwargs...)
        # Hide redundant x labels
        link_xaxes && pos[1] != length(tas) && hidexdecorations!.(pap.axis, grid=false)
        pap
    end

    axs = reduce(vcat, getproperty.(gaps, :axis))
    link_xaxes && linkxaxes!(axs...)
    link_yaxes && linkyaxes!(axs...)

    !isnothing(legend) && add_legend!.(gaps; legend...)

    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

tplot(f::Drawable, ta::SupportTypes, args...; kwargs...) = tplot(f, (ta,), args...; kwargs...)
tplot(tas, args...; figure=(;), kwargs...) = tplot(Figure(; figure...), tas, args...; kwargs...)
tplot(ds::AbstractDimStack; kwargs...) = tplot(layers(ds); kwargs...)

function tplot! end

"Setup the panel on a position and plot multiple time series on it"
function tplot_panel(gp, tas::AbstractVector{<:SupportTypes}, args...; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(tas; add_title)..., axis...)
    plots = tplot_panel!(ax, tas, args...; kwargs...)
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end

tplot_panel(gp, ta::DualAxisData, args...; kwargs...) = dual_axis_plot(gp, ta.data1, ta.data2, tplot_panel!, args...; kwargs...)
tplot_panel(gp, ta::NTuple{2,Any}, args...; kwargs...) = dual_axis_plot(gp, ta[1], ta[2], tplot_panel!, args...; kwargs...)
tplot_panel(gp, ax1tas::MultiPlottable, ax2tas::MultiPlottable, args...; kwargs...) =
    dual_axis_plot(gp, ax1tas, ax2tas, tplot_panel!, args...; kwargs...)

tplot_panel(gd, ds::AbstractDimStack; kwargs...) = tplot_panel(gd, layers(ds); kwargs...)

"""
    tplot_panel(gp, ta::AbstractDimMatrix)

Plot a multivariate time series / spectrogram on a panel
"""
function tplot_panel(gp, ta::AbstractDimMatrix; axis=(;), add_colorbar=DEFAULTS.add_colorbar, add_title=DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = tplot_panel!(ax, ta; kwargs...)
    pos = gp[1, 1, Right()]
    add_colorbar && isspectrogram(ta) && Colorbar(pos, plots; label=clabel(ta))
    PanelAxesPlots(gp, AxisPlots(ax, plots))
end

"""
    tplot_panel(gp, ta::AbstractDimVector)

Plot a univariate time series on a panel.
Only add legend when the axis contains multiple labels.
"""
function tplot_panel(gp, ta::AbstractDimVector; axis=(;), add_title=DEFAULTS.add_title, kwargs...)
    lines(gp, ta; plot_attributes(ta; add_title)..., axis..., kwargs...)
end

tplot_panel(gp, ta::DD.AbstractDimVector{<:AbstractVector}; kwargs...) = tplot_panel(gp, tstack(ta); kwargs...)

tplot_panel!(ax::Axis, vs::AbstractVector{<:SupportTypes}; kwargs...) =
    map(vs) do ta
        tplot_panel!(ax, ta; kwargs...)
    end

"""
Plot heatmap / overlay multiple columns of a time series on the same axis
"""
function tplot_panel!(ax::Axis, ta::AbstractDimMatrix; labels=labels(ta), kwargs...)
    ta = resample(ta)
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
    tplot_panel(gp, f::Function, tmin, tmax; kwargs...)

Interactive tplot of a function over a time range on a grid position
"""
function tplot_panel(gp, f::Function, tmin, tmax; axis=(;), add_title=DEFAULTS.add_title, add_colorbar=DEFAULTS.add_colorbar, xtickformat=format_datetime, kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = axis_attributes(ta; add_title, xtickformat=values -> xtickformat.(x2t.(values)))
    ax = Axis(gp; attrs..., axis...)
    plot = tplot_panel!(ax, f, tmin, tmax; kwargs...)
    isspectrogram(ta) && add_colorbar && Colorbar(gp[1, 1, Right()], plot; label=clabel(ta))
    PanelAxesPlots(gp, AxisPlots(ax, plot))
end

"""
    tplot_panel!(ax, f::Function, tmin, tmax; kwargs...)

Interactive tplot of a function `f` on `ax` for a time range from `tmin` to `tmax`
"""
function tplot_panel!(ax, f::Function, tmin, tmax; kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = plottype_attributes(ta)

    # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
    # https://github.com/MakieOrg/Makie.jl/issues/4769
    xmin, xmax = t2x.((tmin, tmax))
    if isspectrogram(ta)
        y = spectrogram_y_values(ta)
        plot_func = (x, mat) -> heatmap!(ax, x, y, mat; attrs..., kwargs...)
    else
        plot_type = ndims(ta) == 2 ? series! : lines!
        plot_func = (xs, vs) -> plot_type(ax, xs, vs; attrs..., kwargs...)
    end
    data = RangeFunction1D(time2value_transform(f), xmin, xmax)
    iviz(plot_func, data)
end

function tplot_panel(gp, fs::AbstractVector, tmin::DateTime, tmax::DateTime; axis=(;), add_title=false, kwargs...)
    ax = Axis(gp; axis_attributes(fs, tmin, tmax; add_title)..., axis...)
    plots = iviz_api!(ax, fs, tmin, tmax; kwargs...)
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end

tplot_panel!(ax, fs::AbstractVector, tmin::DateTime, tmax::DateTime; kwargs...) =
    iviz_api!(ax, fs, tmin, tmax; kwargs...)

######################
## Extension interface
######################

"""
    tplot_panel(gp, ta, args...; kwargs...)

Extension interface for interactively plotting custom data types. 
To support a new data type, define a method for `get_data(ta, args...; kwargs...)` that converts your type to a DimensionalData array
"""
function tplot_panel(gp, ta, tmin, tmax; axis=(;), kwargs...)
    f = (args...) -> get_data(ta, args...)
    tplot_panel(gp, f, tmin, tmax; axis, kwargs...)
end

# default fallback
tplot_panel(gp, args...; kwargs...) = panelplot(gp, args...; kwargs...)
tplot_panel!(ax, args...; kwargs...) = panelplot!(ax, args...; kwargs...)

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