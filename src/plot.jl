xlabel_sources = (:xlabel, "xlabel")
ylabel_sources = (:ylabel, :long_name, "long_name", :label, "LABLAXIS")
yunit_sources = (:yunit, :units)

xlabel(ta) = ""
xlabel(da::AbstractDimArray) = prioritized_get(da.metadata, xlabel_sources, DD.label(dims(da, 1)))
xlabel(das::AbstractVector) = xlabel(das[1])

ylabel(ta) = ""
function ylabel(ta::AbstractDimArray{Q}) where {Q}
    name = prioritized_get(ta, ylabel_sources, DD.label(ta))
    units = is_spectrogram(ta) ? prioritized_get(ta, yunit_sources, "") : unit(Q)
    units == "" ? name : "$name ($units)"
end

function clabel(ta::AbstractDimArray{Q}) where {Q}
    name = get(ta.metadata, "LABLAXIS", "")
    units = get(ta.metadata, :cunit, unit(Q))
    units == "" ? name : "$name ($units)"
end

title(ta) = get(ta.metadata, "CATDESC", "")

function colorrange(da::AbstractDimArray; scale=10)
    cmid = median(da)
    cmax = cmid * scale
    cmin = cmid / scale
    return (cmin, cmax)
end

tlims!(ax, tmin, tmax) = xlims!(ax, DateTime(tmin), DateTime(tmax))
tlims!(tmin, tmax) = tlims!(current_axis(), tmin, tmax)
label_func(labels) = latexify.(labels)

"""Plot attributes for a time array"""
function plot_attributes(ta; add_title=false)
    yscale = get(ta.metadata, "SCALETYP", "identity") |> scale
    axis = (; ylabel=ylabel(ta), xlabel=xlabel(ta), yscale)

    add_title && (axis = (; axis..., title=title(ta)))

    # handle spectrogram
    if !is_spectrogram(ta)
        labels = label_func(dims(ta, 2).val)
        (; axis, labels)
    else
        colorscale = yscale
        (; axis, colorscale)
    end
end

plot_attributes(f::Function, args...) = plot_attributes(f(args...))

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

axes(ta) = ta.metadata["axes"]