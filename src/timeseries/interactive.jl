using InteractiveViz: Continuous1D, iviz, FigureAxisPlotEx

abstract type AbstractRangeFunction end

### 1D range function that takes a range as input and returns an array
# struct RangeFunction1D{F,L} <: InteractiveViz.Continuous1D
struct RangeFunction1D{F,L} <: AbstractRangeFunction
    f::F
    xmin::L
    xmax::L
end

function sample(data::RangeFunction1D, xrange::AbstractRange, yrange; samples=10000)
    xmin = first(xrange)
    xmax = last(xrange)
    x, y = data.f((xmin, xmax))

    # Limit to 10000 points if needed
    if length(x) > samples
        @info "Data resampled to $samples points"
        indices = round.(Int, range(1, length(x), length=samples))
        x = x[indices]
        y = ndims(y) == 1 ? y[indices] : y[:, indices]
    end

    (; x, y)
end

limits(data::RangeFunction1D) = (data.xmin, data.xmax, nothing, nothing)

"""
Remove the resolution-based updates and only update based on axis limit to improve performance
"""
function InteractiveViz.iviz(f, data::RangeFunction1D; delay=0.1)
    lims = limits(data)
    r = range(lims[1], lims[2]; length=2)
    qdata = sample(data, r, nothing)
    x = Observable(qdata.x)
    y = Observable(qdata.y)
    fap = f(x, y)

    if current_axis().limits[] == (nothing, nothing)
        xlims!(current_axis(), lims[1], lims[2])
    end

    reset_limits!(current_axis())

    function update(lims)
        xrange = range(lims.origin[1], lims.origin[1] + lims.widths[1])
        yrange = range(lims.origin[2], lims.origin[2] + lims.widths[2])
        qdata = sample(data, xrange, yrange)
        x.val = qdata.x
        return y[] = qdata.y
    end
    axislimits = current_axis().finallimits
    on(axislimits) do axlimits
        if @isdefined(redraw_limit)
            close(redraw_limit)
        end
        redraw_limit = Timer(x -> update(axlimits), delay)
    end

    return FigureAxisPlotEx(fap, () -> update(axislimits[]), nothing)
end

flatten(x) = collect(Iterators.flatten(x))

function iviz_api(f, tas, t0, t1, args...; delay=0.25, kwargs...)
    specs = Observable(flatten(tplot_spec.(tas, t0, t1, args...; kwargs...)))
    f(specs)

    function update(lims)
        xrange = (lims.origin[1], lims.origin[1] + lims.widths[1])
        trange = x2t.(xrange)
        return specs[] = flatten(tplot_spec.(tas, trange..., args...; kwargs...))
    end

    axislimits = current_axis().finallimits
    on(axislimits) do axlimits
        if @isdefined(redraw_limit)
            close(redraw_limit)
        end
        redraw_limit = Timer(x -> update(axlimits), delay)
    end
    return specs[]
end