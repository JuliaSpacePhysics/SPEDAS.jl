# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/ablines.jl

@recipe DualPlot begin
    plotfunc = scatterlines!
    color2 = Makie.wong_colors()[end-1]  # Default color for second axis
    linestyle2 = :dash              # Default linestyle for second axis
    marker2 = :rect               # Default marker for second axis
end

function Makie.plot!(p::DualPlot)
    data = p[1][]
    pf = p.plotfunc[]

    pf(p, data[1])

    gp = gridposition(current_axis())
    ax2 = make_secondary_axis!(gp; color=p.color2)
    # Plot on the second axis with distinctive styling
    pf(ax2, data[2];
        color=p.color2,
        linestyle=p.linestyle2,
        marker=p.marker2,
    )
end

"Setup the panel with both primary and secondary y-axes"
function dualplot(
    gp, ax1tas, ax2tas, plot_func::Function, args...;
    color2=Makie.wong_colors()[6],
    axis=(;),
    add_title=DEFAULTS.add_title, kwargs...
)
    # Primary axis
    ax1 = Axis(gp; axis_attributes(ax1tas, args...; add_title)..., axis...)
    plots1 = plot_func(ax1, ax1tas, args...; kwargs...)

    # Secondary axis
    ax2 = make_secondary_axis!(gp; color=color2, axis_attributes(ax2tas, args...; add_title=false)...)
    plots2 = plot_func(ax2, ax2tas, args...; color=color2, kwargs...)
    return PanelAxesPlots(gp, [AxisPlots(ax1, plots1), AxisPlots(ax2, plots2)])
end

dualplot(gp, data, args...; kwargs...) = dualplot(gp, data[1], data[2], tplot_panel!, args...; kwargs...)

"Create and configure a secondary y-axis"
function make_secondary_axis!(gp; color=Makie.wong_colors()[6], kwargs...)
    ax2 = Axis(gp;
        yaxisposition=:right,
        yticklabelcolor=color,
        ylabelcolor=color,
        rightspinecolor=color,
        ytickcolor=color,
        kwargs...
    )
    hidespines!(ax2)
    hidexdecorations!(ax2)
    return ax2
end