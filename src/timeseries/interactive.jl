using InteractiveViz: Continuous1D, iviz
using Makie: events, Mouse

abstract type AbstractRangeFunction end

### 1D range function that takes a range as input and returns an array
# struct RangeFunction1D{F,L} <: InteractiveViz.Continuous1D
struct RangeFunction1D{F,L} <: AbstractRangeFunction
    f::F
    xmin::L
    xmax::L
end

function sample(data::RangeFunction1D, xrange; samples=10000)
    xmin = first(xrange)
    xmax = last(xrange)
    x, y = data.f((xmin, xmax))

    # Limit to 10000 points if needed
    if length(x) > samples
        indices = round.(Int, range(1, length(x), length=samples))
        x = x[indices]
        y = collect(selectdim(y, 1, indices))
    end

    (; x, y)
end

limits(data::RangeFunction1D) = (data.xmin, data.xmax, nothing, nothing)

"""
Remove the resolution-based updates and only update based on axis limit to improve performance
"""
function InteractiveViz.iviz(f, data::RangeFunction1D; delay=DEFAULTS.delay)
    lims = limits(data)
    r = range(lims[1], lims[2]; length=2)
    qdata = sample(data, r)
    x = Observable(qdata.x)
    y = Observable(qdata.y)
    fap = f(x, y)

    if current_axis().limits[] == (nothing, nothing)
        xlims!(current_axis(), lims[1], lims[2])
    end

    ax = current_axis()
    reset_limits!(ax)

    axislimits = ax.finallimits
    prev_xrange = Observable(get_xrange(axislimits[]))

    function update(lims)
        xrange = get_xrange(lims)
        # Update if new range extends beyond previously loaded range
        prev_xmin, prev_xmax = prev_xrange[]
        needs_update = xrange[1] < prev_xmin || xrange[2] > prev_xmax

        # Add range check to avoid unnecessary data fetching
        if needs_update
            qdata = sample(data, xrange)
            x.val = qdata.x
            y[] = qdata.y
            prev_xrange[] = xrange
        end
    end

    # Apply the debounced update when axis limits change
    on(Debouncer(update, delay), axislimits)

    return fap
end


# Not working yet, depends on https://github.com/MakieOrg/Makie.jl/issues/4774
struct RangeFunctionData1D{F,L} <: AbstractRangeFunction
    f::F
    xmin::L
    xmax::L
end

function sample(rf::RangeFunctionData1D, xrange; samples=10000)
    xmin = first(xrange)
    xmax = last(xrange)
    data = rf.f((xmin, xmax))
    resample(data, samples)
end

limits(rf::RangeFunctionData1D) = (rf.xmin, rf.xmax, nothing, nothing)

function InteractiveViz.iviz(f, data::RangeFunctionData1D; delay=DEFAULTS.delay)
    lims = limits(data)
    r = range(lims[1], lims[2]; length=2)
    qdata = sample(data, r)
    obs_data = Observable(qdata)
    fap = f(obs_data)

    if current_axis().limits[] == (nothing, nothing)
        xlims!(current_axis(), lims[1], lims[2])
    end

    ax = current_axis()
    reset_limits!(ax)

    axislimits = ax.finallimits
    prev_xrange = Observable(get_xrange(axislimits[]))

    function update(lims)
        xrange = get_xrange(lims)
        # Update if new range extends beyond previously loaded range
        prev_xmin, prev_xmax = prev_xrange[]
        needs_update = xrange[1] < prev_xmin || xrange[2] > prev_xmax

        # Add range check to avoid unnecessary data fetching
        if needs_update
            qdata = sample(data, xrange)
            obs_data[] = qdata
            prev_xrange[] = xrange
        end
    end

    # Apply the debounced update when axis limits change
    on(Debouncer(update, delay), axislimits)

    return fap
end