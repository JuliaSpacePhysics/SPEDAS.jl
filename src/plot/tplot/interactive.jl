get_xrange(limit) = (limit.origin[1], limit.origin[1] + limit.widths[1])

"""
Interactive plotting functionality for time series.
This file contains functions for interactive plotting of time series data.
"""

# https://github.com/MakieOrg/Makie.jl/pull/4630

function iviz_api!(ax::Axis, to_plotspec, trange; delay=DEFAULTS.delay)
    specs = Observable(to_plotspec(trange))
    plots = plotlist!(ax, specs)
    reset_limits!(ax)

    axislimits = ax.finallimits
    # Keep track of the previous range
    prev_xrange = Observable(get_xrange(axislimits[]))

    function update(lims)
        xrange = get_xrange(lims)
        # Update if new range extends beyond previously loaded range
        prev_xmin, prev_xmax = prev_xrange[]
        needs_update = xrange[1] < prev_xmin || xrange[2] > prev_xmax

        if needs_update
            trange = x2t.(xrange)
            specs[] = to_plotspec(trange)
            prev_xrange[] = xrange
        end
    end

    on(Debouncer(update, delay), axislimits)

    return plots
end

iviz_api(f, args...; kwargs...) = iviz_api!(current_axis(), f, args...; kwargs...)