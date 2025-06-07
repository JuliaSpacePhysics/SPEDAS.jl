# https://github.com/MakieOrg/Makie.jl/blob/master/src/basic_recipes/series.jl
# https://github.com/rafaqz/DimensionalData.jl/blob/main/ext/DimensionalDataMakie.jl

struct NoDimConversion <: Makie.ConversionTrait end

@recipe LinesPlot begin
    labels = nothing
    # Makie.MakieCore.documented_attributes(Lines)...
    # resample = 10000
end

MakieCore.conversion_trait(::Type{<:LinesPlot}) = NoDimConversion()

function plot2spec(::Type{<:LinesPlot}, da::AbstractMatrix; labels = labels(da))
    da = resample(da)
    x = makie_x(da)
    return map(enumerate(eachcol(parent(da)))) do (i, y)
        S.Lines(x, y; label = get(labels, i, nothing))
    end
end

function plot2spec(::Type{<:LinesPlot}, da::AbstractVector; labels = nothing, label = nothing)
    label = @something label labels to_value(SPEDAS.label(da))
    return S.Lines(makie_x(da), parent(da); label)
end

function MakieCore.convert_arguments(::Type{<:LinesPlot}, x::AbstractVector, ys::AbstractMatrix)
    A = parent(ys)
    curves = map(i -> (x, view(A, :, i)), 1:size(A, 2))
    return (curves,)
end

"""Convert the vector of vectors into a single vector of curves"""
MakieCore.convert_arguments(T::Type{<:LinesPlot}, ys::Tuple) = reduce(vcat, convert_arguments.(T, ys))
MakieCore.convert_arguments(T::Type{<:LinesPlot}, ys::AbstractVector{<:AbstractArray}) = reduce(vcat, convert_arguments.(T, ys))

function MakieCore.plot!(plot::LinesPlot)
    curves = plot[1]
    return map(eachindex(curves[])) do i
        positions = lift(c -> c[i], plot, curves)
        x = lift(x -> x[1], positions)
        y = lift(x -> x[2], positions)
        lines!(plot, x, y)
    end
end

"""
    linesplot(gp, ta)

Plot a multivariate time series on a panel
"""
function linesplot(gp::Drawable, ta; axis = (;), add_title = DEFAULTS.add_title, kwargs...)
    ax = Axis(gp; axis_attributes(ta; add_title)..., axis...)
    plots = linesplot!(ax, ta; kwargs...)
    return PanelAxesPlots(gp, AxisPlots(ax, plots))
end
