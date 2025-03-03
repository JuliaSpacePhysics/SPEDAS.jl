"""
Interactive plotting functionality for time series.
This file contains functions for interactive plotting of time series data.
"""

# https://github.com/MakieOrg/Makie.jl/pull/4630

"""
Transform a function that handles time range to a function that handles x range (time values) and return x and y values.
"""
function time2value_transform(xrange, f)
    trange = x2t.(xrange)
    da = f(trange...)
    return t2x(da), vs(da)
end

time2value_transform(f) = (xrange) -> time2value_transform(xrange, f)

# function tplot_panel(gp, ::FunctionPlot, fs::AbstractVector, tmin::DateTime, tmax::DateTime; axis=(;), add_title=false, kwargs...)
#     ax = Axis(gp; axis_attributes(fs, tmin, tmax; add_title)..., axis...)
#     plots = iviz_api!(ax, fs, tmin, tmax; kwargs...)
#     return PanelAxesPlots(gp, AxisPlots(ax, plots))
# end

# tplot_panel!(ax, ::FunctionPlot, fs::AbstractVector, tmin::DateTime, tmax::DateTime; kwargs...) =
#     iviz_api!(ax, fs, tmin, tmax; kwargs...)
