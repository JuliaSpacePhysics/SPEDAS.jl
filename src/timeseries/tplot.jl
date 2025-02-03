DimensionalDataMakie = Base.get_extension(DimensionalData, :DimensionalDataMakie)
using .DimensionalDataMakie: _series
using Latexify

ylabel_sources = (:long_name, "long_name", :label, "FIELDNAM")
xlabel_sources = (:long_name, "long_name", :label)

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure
    axes::AbstractArray{<:Axis}
end

struct AxisPlots
    axis::Axis
    plots
end


ylabel(ta) = ""
function ylabel(ta::AbstractDimArray)
    name = prioritized_get(ta.metadata, ylabel_sources, DD.label(ta))
    units = get(ta.metadata, :units, "")
    units == "" ? name : "$name ($units)"
end

label_func(labels) = latexify.(labels)

function ylabel(ta::AbstractDimArray{Q}) where {Q<:Quantity}
    name = prioritized_get(ta.metadata, ylabel_sources, DD.label(ta))
    units = unit(Q)
    units == "" ? name : "$name ($units)"
end

xlabel(ta) = ""
xlabel(da::AbstractDimArray) = prioritized_get(da.metadata, xlabel_sources, DD.label(dims(da, 1)))
xlabel(das::AbstractVector) = xlabel(das[1])

"""
Only add legend when the axis contains multiple labels
"""
function add_legend!(gp, ax; min=2, position=Right(), kwargs...)
    plots, labels = Makie.get_labeled_plots(ax; merge=false, unique=false)
    length(plots) < min && return
    Legend(gp[1, 1, position], ax; kwargs...)
end

function scale(x::String)
    if x == "identity" || x == "linear"
        identity
    elseif x == "log10" || x == "log"
        log10
    end
end

is_spectrogram(ta) = ta.metadata["DISPLAY_TYPE"] == "spectrogram"

"""
    plot_attributes(ta)

Plot attributes for a time array
"""
function plot_attributes(ta)
    yscale = get(ta.metadata, "SCALETYP", "identity") |> scale
    axis = (; ylabel=ylabel(ta), xlabel=xlabel(ta), yscale)

    # handle spectrogram
    if !is_spectrogram(ta)
        labels = label_func(dims(ta, 2).val.data)
        (; axis, labels)
    else
        colorscale = yscale
        (; axis, colorscale)
    end
end

plot_attributes(f::Function, args...) = plot_attributes(f(args...))

"""
    tplot!(ax, tas; kwargs...)

Overlay multiple time series on the same axis
"""
function tplot!(ax::Axis, tas::AbstractVector; kwargs...)
    for ta in tas
        tplot!(ax, ta; kwargs...)
    end
end


"""
Setup the axis on a position and plot multiple time series on it
"""
function tplot(gp::GridPosition, tas::AbstractVector; kwargs...)
    ax = Axis(gp, ylabel=ylabel(tas), xlabel=xlabel(tas))
    plots = map(tas) do ta
        tplot!(ax, ta; kwargs...)
    end
    AxisPlots(ax, plots)
end

"""
Overlay multiple columns of a time series on the same axis
"""
function tplot!(ax::Axis, ta::AbstractDimMatrix; labeldim=nothing, kwargs...)
    args, attributes = _series(ta, kwargs, labeldim)
    series!(ax, args...; labels=attributes.labels, kwargs...)
end

tplot!(ax::Axis, ta::AbstractDimVector; kwargs...) = lines!(ax, ta; kwargs...)

"""
Plot a multivariate time series on a position in a figure
"""
function tplot(gp::GridPosition, ta::AbstractDimMatrix; label_func=label_func, labeldim=nothing, kwargs...)
    attributes = Attributes(kwargs...; plot_attributes(ta)...)
    if !is_spectrogram(ta)
        args, merged_attributes = _series(ustrip(ta), attributes, labeldim)
        series(gp, args...; merged_attributes...)
    else
        x = ta.metadata["axes"][1].values
        y = mean(ta.metadata["axes"][2].values, dims=1) |> vec
        heatmap(gp, x, y, ta.data; attributes..., kwargs...)
    end
end

# Only add legend when the axis contains multiple labels
tplot(gp::GridPosition, ta::AbstractDimVector; kwargs...) = lines(gp, ta; plot_attributes(ta)..., kwargs...)


"""
    Interactive tplot of a function over a time range
"""
function tplot(gp, f::Function, tmin::DateTime, tmax::DateTime; t0=tmin, kwargs...)
    # get a sample data to determine the attributes and plot types
    ta = f(tmin, tmax)
    attrs = plot_attributes(ta)

    xmin, xmax = ((tmin, tmax) .- t0) ./ Millisecond(1)

    if is_spectrogram(ta)
        y = mean(ta.metadata["axes"][2].values, dims=1) |> vec
        ymin, ymax = Float64.(extrema(y))
        plot_func = (x, y, mat) -> heatmap(gp, x, y, mat; attrs..., kwargs...)

        # reverse from xrange to trange
        temp_f = xrange -> begin
            trange = round.(xrange) .* Millisecond(1) .+ t0
            da = f(trange...)
            xs(da, t0), y, vs(da)
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
            trange = round.(xrange) .* Millisecond(1) .+ t0
            da = f(trange...)
            xs(da, t0), ys(da)
        end

        data = RangeFunction1D(temp_f, xmin, xmax)
    end
    viz = iviz(plot_func, data)
    # format the tick labels
    current_axis().xtickformat = values -> f2time.(values, t0)
    viz
end

"""
Lay out multiple time series on the same figure across different panels (rows)
"""
function tplot(f, tas::Union{AbstractVector,NamedTuple}, args...; add_legend=true, legend=(; position=Right()), link_xaxes=true, rowgap=5, kwargs...)
    palette = [(i, 1) for i in 1:length(tas)]
    gaps = map(palette, tas) do pos, ta
        gp = f[pos...]
        ap = tplot(gp, ta, args...; kwargs...)
        # Hide redundant x labels
        link_xaxes && pos[1] != length(tas) && hidexdecorations!(ap.axis, grid=false)
        (gp, ap)
    end
    axs = map(gap -> gap[2].axis, gaps)
    gps = map(gap -> gap[1], gaps)
    link_xaxes && linkxaxes!(axs...)

    add_legend && add_legend!.(gps, axs; legend...)

    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

tplot(ds::AbstractDimStack; kwargs...) = tplot(layers(ds); kwargs...)

function tplot(tas, args...; figure=(;), kwargs...)
    f = Figure(; figure...)
    tplot(f, tas, args...; kwargs...)
end


Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.display(fg::FigureAxes) = display(fg.figure)
Base.show(io::IO, m::MIME, fg::FigureAxes) = show(io, m, fg.figure)
Base.show(io::IO, ::MIME"text/plain", fg::FigureAxes) = print(io, "FigureAxes()")
Base.showable(mime::MIME{M}, fg::FigureAxes) where {M} = showable(mime, fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)