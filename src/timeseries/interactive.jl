using InteractiveViz: Continuous1D, iviz

### 1D range function that takes a range as input and returns an array
struct RangeFunction1D{F,L} <: InteractiveViz.Continuous1D
    f::F
    xmin::L
    xmax::L
end

function InteractiveViz.sample(data::RangeFunction1D, xrange::AbstractRange, yrange; samples=10000)
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

InteractiveViz.limits(data::RangeFunction1D) = (data.xmin, data.xmax, nothing, nothing)

struct RangeFunction2D{F,L} <: InteractiveViz.Continuous2D
    f::F
    xmin::L
    xmax::L
    ymin::L
    ymax::L
end

function InteractiveViz.sample(data::RangeFunction2D, xrange::AbstractRange, yrange::AbstractRange)
    xmin = first(xrange)
    xmax = last(xrange)
    x, y, z = data.f((xmin, xmax))
    (; x, y, z)
end

InteractiveViz.limits(data::RangeFunction2D) = (data.xmin, data.xmax, data.ymin, data.ymax)