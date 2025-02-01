DimensionalDataMakie = Base.get_extension(DimensionalData, :DimensionalDataMakie)
using .DimensionalDataMakie: _series
using Latexify

# https://github.com/MakieOrg/AlgebraOfGraphics.jl/blob/master/src/entries.jl
struct FigureAxes
    figure::Figure
    axes::AbstractArray{<:Axis}
end

struct AxisPlots
    axis::Axis
    plots
end


ylabel(ta) = ""
function ylabel(ta::AbstractDimArray)
    name = prioritized_get(ta.metadata, ["ylabel", :long_name, "long_name"], DD.label(ta))
    units = get(ta.metadata, :units, "")
    units == "" ? name : "$name ($units)"
end

function ylabel(ta::AbstractDimArray{Q}) where {Q<:Quantity}
    name = prioritized_get(ta.metadata, ["ylabel", :long_name, "long_name"], DD.label(ta))
    units = unit(Q)
    units == "" ? name : "$name ($units)"
end

xlabel(da::AbstractDimArray) = prioritized_get(da.metadata, ["xlabel", :long_name, "long_name"], DD.label(dims(da, 1)))
xlabel(das::AbstractVector) = xlabel(das[1])

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
function tplot(gp::GridPosition, ta::AbstractDimMatrix; labeldim=nothing, kwargs...)
    axis = (; ylabel=ylabel(ta))
    labels = latexify.(dims(ta, 2).val.data)
    attributes = Attributes(kwargs...; axis, labels)
    args, merged_attributes = _series(ustrip(ta), attributes, labeldim)
    series(gp, args...; merged_attributes...)
end

# Only add legend when the axis contains multiple labels
function tplot(gp::GridPosition, ta::AbstractDimVector; kwargs...)
    axis = (; ylabel=ylabel(ta), xlabel=xlabel(ta))
    lines(gp, ta; axis, kwargs...)
end

"""
Lay out multiple time series on the same figure across different panels (rows)
"""
function tplot(f, tas::AbstractVector; add_legend=true, legend_position=:outside, legend=(;), link_xaxes=true, rowgap=5, kwargs...)
    aps = map(enumerate(tas)) do (i, ta)
        gp = f[i, 1]
        ap = tplot(gp, ta; kwargs...)
        # Hide redundant x labels
        link_xaxes && i != length(tas) && hidexdecorations!(ap.axis, grid=false)
        ap
    end
    axs = map(ap -> ap.axis, aps)
    link_xaxes && linkxaxes!(axs...)

    add_legend && try
        if legend_position == :outside
            map(enumerate(aps)) do (i, ap)
                Legend(f[i, 1, Right()], ap.axis; legend...)
            end
        else
            axislegend.(axs; position=legend_position, legend...)
        end
    catch
    end
    !isnothing(rowgap) && rowgap!(f.layout, rowgap)
    FigureAxes(f, axs)
end

function tplot(tas; figure=(;), kwargs...)
    f = Figure(; figure...)
    tplot(f, tas; kwargs...)
end


Base.show(io::IO, fg::FigureAxes) = show(io, fg.figure)
Base.display(fg::FigureAxes) = display(fg.figure)

Base.iterate(fg::FigureAxes) = iterate((fg.figure, fg.axes))
Base.iterate(fg::FigureAxes, i) = iterate((fg.figure, fg.axes), i)