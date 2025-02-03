using InteractiveViz: Continuous1D, iviz

### 1D range function that takes a range as input and returns an array
struct RangeFunction1D{F,L} <: InteractiveViz.Continuous1D
    f::F
    xmin::L
    xmax::L
end

function InteractiveViz.sample(data::RangeFunction1D, xrange::AbstractRange, yrange)
    xmin = first(xrange)
    xmax = last(xrange)
    x, y = data.f((xmin, xmax))

    # Limit to 10000 points if needed
    if length(x) > 10000
        indices = round.(Int, range(1, length(x), length=10000))
        x = x[indices]
        y = selectdim(y, 2, indices)
    end

    (; x, y)
end

InteractiveViz.limits(data::RangeFunction1D) = (data.xmin, data.xmax, nothing, nothing)
