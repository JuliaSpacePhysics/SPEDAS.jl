DimensionalDataMakie = Base.get_extension(DimensionalData, :DimensionalDataMakie)
using .DimensionalDataMakie: _series
using Latexify

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure
    axes::AbstractArray{<:Axis}
end

struct AxisPlots
    axis::Axis
    plots
end


"""
    tplot(f, tas; legend=(; position=Right()), link_xaxes=true, rowgap=5, kwargs...)

Lay out multiple time series across different panels (rows) on one Figure / GridPosition `f`

If `legend` is `nothing`, no legend is added.
"""
function tplot(f::Union{Figure,GridPosition}, tas::Union{AbstractVector,NamedTuple}, args...; legend=(; position=Right()), link_xaxes=true, rowgap=5, kwargs...)
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

    !isnothing(legend) && add_legend!.(gps, axs; legend...)

    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

tplot(f::Union{Figure,GridPosition}, ta, args...; kwargs...) = tplot(f, [ta], args...; kwargs...)

function tplot(tas, args...; figure=(;), kwargs...)
    f = Figure(; figure...)
    tplot(f, tas, args...; kwargs...)
end

function tplot! end

"""
    tplot_panel(gp, ta::AbstractDimMatrix)

Plot a multivariate time series / spectrogram on a panel
"""
function tplot_panel(gp, ta::AbstractDimMatrix; add_colorbar=true, add_title=false, label_func=label_func, labeldim=nothing, kwargs...)
    attributes = Attributes(kwargs...; plot_attributes(ta; add_title)...)
    if !is_spectrogram(ta)
        args, merged_attributes = _series(ustrip(ta), attributes, labeldim)
        series(gp, args...; merged_attributes...)
    else
        x = dims(ta, Ti).val
        y = mean(ta.metadata["axes"][2].values, dims=1) |> vec
        axisPlot = heatmap(gp, x, y, ta.data; attributes..., kwargs...)
        add_colorbar && Colorbar(gp[1, 1, Right()], axisPlot.plot; label=clabel(ta))
        axisPlot
    end
end

"""
    tplot_panel(gp, ta::AbstractDimVector)

Plot a univariate time series on a panel on a panel.
Only add legend when the axis contains multiple labels.
"""
function tplot_panel(gp, ta::AbstractDimVector; add_title=false, kwargs...)
    lines(gp, ta; plot_attributes(ta; add_title)..., kwargs...)
end


"Setup the panel on a position and plot multiple time series on it"
function tplot_panel(gp, tas::AbstractVector; add_title=false, kwargs...)
    ax = Axis(gp, ylabel=ylabel(tas), xlabel=xlabel(tas))
    plots = map(tas) do ta
        tplot_panel!(ax, ta; kwargs...)
    end
    AxisPlots(ax, plots)
end


"""
    tplot_panel!(ax, tas; kwargs...)

Overlay multiple time series on the same axis
"""
tplot_panel!(ax::Axis, tas::AbstractVector{<:AbstractDimVecOrMat}; kwargs...) =
    tplot_panel!.(ax, tas; kwargs...)


"""
Overlay multiple columns of a time series on the same axis
"""
function tplot_panel!(ax::Axis, ta::AbstractDimMatrix; kwargs...)
    x = dims(ta, Ti).val
    map(eachcol(ta.data), string.(dims(ta, 2).val)) do y, label
        lines!(ax, x, y; label, kwargs...)
    end
end

tplot_panel!(ax::Axis, ta::AbstractDimVector; kwargs...) = lines!(ax, ta; kwargs...)

"""
    Interactive tplot of a function over a time range
"""
function tplot_panel(gp, f::Function, tmin::DateTime, tmax::DateTime; t0=tmin, kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = plot_attributes(ta)

    # Manually converting from time to float is needed for interactive plotting since ax.finallimits[] is represented as float
    # https://github.com/MakieOrg/Makie.jl/issues/4769
    xmin, xmax = t2x.((tmin, tmax))

    if is_spectrogram(ta)
        y = mean(ta.metadata["axes"][2].values, dims=1) |> vec
        ymin, ymax = Float64.(extrema(y))
        plot_func = (x, y, mat) -> heatmap(gp, x, y, mat; attrs..., kwargs...)

        # reverse from xrange to trange
        temp_f = xrange -> begin
            trange = x2t.(xrange)
            da = f(trange...)
            t2x(da), y, vs(da)
        end
        data = RangeFunction2D(temp_f, xmin, xmax, ymin, ymax)
    else
        if ndims(ta) == 2
            plot_func = (x, y) -> series(gp, x, y; attrs..., kwargs...)
        else
            plot_func = (x, y) -> lines(gp, x, y; attrs..., kwargs...)
        end

        # reverse from xrange to trange
        temp_f = xrange -> begin
            trange = x2t.(xrange)
            da = f(trange...)
            t2x(da), ys(da)
        end

        data = RangeFunction1D(temp_f, xmin, xmax)
    end
    viz = iviz(plot_func, data)
    # format the tick labels
    current_axis().xtickformat = values -> string.(x2t.(values))
    viz
end

tplot(ds::AbstractDimStack; kwargs...) = tplot(layers(ds); kwargs...)

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