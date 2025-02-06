xlabel_sources = (:xlabel, "xlabel")
ylabel_sources = (:ylabel, :long_name, "long_name", :label, "LABLAXIS")
yunit_sources = (:yunit, :units)

xlabel(ta) = ""
xlabel(da::AbstractDimArray) = prioritized_get(da.metadata, xlabel_sources, DD.label(dims(da, 1)))

ylabel(ta) = ""
function ylabel(ta::AbstractDimArray{Q}) where {Q}
    name = prioritized_get(ta, ylabel_sources, DD.label(ta))
    units = is_spectrogram(ta) ? prioritized_get(ta, yunit_sources, "") : string(unit(Q))
    units == "" ? name : "$name ($units)"
end

function clabel(ta::AbstractDimArray{Q}) where {Q}
    name = get(ta.metadata, "LABLAXIS", "")
    units = get(ta.metadata, :cunit, unit(Q))
    isnothing(units) ? name : "$name ($units)"
end

label(ta::AbstractDimArray) = prioritized_get(ta, ylabel_sources, DD.label(ta))
labels(ta::AbstractDimMatrix) = dims(ta, 2).val

title(ta) = get(ta.metadata, "CATDESC", "")

"""Format datetime ticks with time on top and date on bottom."""
format_datetime(dt) = Dates.format(dt, "HH:MM:SS\nyyyy-mm-dd")

function colorrange(da::AbstractDimArray; scale=10)
    cmid = median(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

label_func(labels) = latexify.(labels)

axis_attributes(ta; add_title=false) = (;)
"""Axis attributes for a time array"""
function axis_attributes(ta::AbstractDimArray; add_title=false)
    attrs = Attributes()
    s = scale(ta)
    xl = xlabel(ta)
    yl = ylabel(ta)
    isnothing(s) || (attrs[:yscale] = s)
    isempty(yl) || (attrs[:ylabel] = yl)
    isempty(xl) || (attrs[:xlabel] = xl)
    add_title && (attrs[:title] = title(ta))
    attrs
end

axis_attributes(tas::AbstractVector; add_title=false) = axis_attributes(tas[1]; add_title)

"""Plot attributes for a time array (axis + labels)"""
function plot_attributes(ta::AbstractDimArray; add_title=false)
    attrs = Attributes()
    attrs[:axis] = axis_attributes(ta; add_title)

    # handle spectrogram
    if !is_spectrogram(ta)
        if ndims(ta) == 2
            attrs[:labels] = label_func(labels(ta))
        else
            attrs[:label] = label_func(label(ta))
        end
    else
        s = scale(ta)
        isnothing(s) || (attrs[:colorscale] = s)
    end
    attrs
end

plot_attributes(ta; add_title=false) = Attributes(; axis=axis_attributes(ta; add_title))
plot_attributes(f::Function, args...; kwargs...) = plot_attributes(f(args...); kwargs...)

"""
Only add legend when the axis contains multiple labels
"""
function add_legend!(gp, ax; min=2, position=Right(), kwargs...)
    plots, labels = Makie.get_labeled_plots(ax; merge=false, unique=false)
    length(plots) < min && return
    Legend(gp[1, 1, position], ax; kwargs...)
end

function scale(x::String)
    if x == "linear"
        identity
    elseif x == "log10" || x == "log"
        log10
    end
end
scale(::Nothing) = nothing
scale(da::AbstractDimArray) = scale(get(da.metadata, "SCALETYP", nothing))

axes(ta) = ta.metadata["axes"]

function tlims!(ax, tmin, tmax)
    if ax.dim1_conversion[] isa Makie.DateTimeConversion
        xlims!(ax, tmin, tmax)
    else
        xlims!(ax, t2x(tmin), t2x(tmax))
    end
end
tlims!(tmin, tmax) = tlims!(current_axis(), tmin, tmax)