dimtype_eltype(d) = (DimensionalData.basetypeof(d), eltype(d))
dimtype_eltype(d, query) = dimtype_eltype(dims(d, query))

"""
    tclip(d, t0, t1)

Clip a dimension or `DimArray` to a time range `[t0, t1]`.
"""
tclip(d, t0, t1) = d[DateTime(t0)..DateTime(t1)]
function tclip(da::AbstractDimArray, t0, t1; query=TimeDim)
    Dim, T = dimtype_eltype(da, query)
    return da[Dim(T(t0) .. T(t1))]
end

"""
    tview(d, t0, t1)

View a dimension or `DimArray` in time range `[t0, t1]`.
"""
tview(d, t0, t1) = @view d[DateTime(t0)..DateTime(t1)]
function tview(da::AbstractDimArray, t0, t1; query=TimeDim)
    Dim, T = dimtype_eltype(da, query)
    return @view da[Dim(T(t0) .. T(t1))]
end

"""
    tmask!(da, t0, t1)

Mask all data values within the specified time range `[t0, t1]` with NaN.
"""
function tmask!(da, t0, t1; query=TimeDim)
    Dim, T = dimtype_eltype(da, query)
    da[Dim(T(t0) .. T(t1))] .= NaN
    return da
end

tmask(da, args...; kwargs...) = tmask!(deepcopy(da), args...; kwargs...)

"""
    tshift(x; dim=TimeDim, t0=nothing, new_dim=nothing)

Shift the `dim` of `x` by `t0`.
"""
function tshift(x::AbstractDimArray, t0=nothing; dim=TimeDim, new_dim=nothing)
    td = dims(x, dim)
    times = parent(lookup(td))
    t0 = @something t0 first(times)
    new_dim = @something new_dim Dim{Symbol("Time after ", t0)}
    set(x, dim => new_dim(times .- t0))
end

for f in (:tclip, :tview, :tmask!, :tmask)
    @eval $f(da, trange; kwargs...) = $f(da, trange...; kwargs...)
    @eval $f(da1, da2::AbstractDimArray) = $f(da1, timerange(da2))
end

for f in (:tclip, :tview, :tmask!, :tmask, :tshift)
    @eval $f(args...; kwargs...) = da -> $f(da, args...; kwargs...)
end


"""
    tclips(xs...; trange=common_timerange(xs...))

Clip multiple arrays to a common time range `trange`.

If `trange` is not provided, automatically finds the common time range
across all input arrays.
"""
tclips(xs::Vararg{Any,N}; trange=common_timerange(xs...)) where N =
    ntuple(i -> tclip(xs[i], trange...), N)

tviews(xs::Vararg{Any,N}; trange=common_timerange(xs...)) where N =
    ntuple(i -> tview(xs[i], trange...), N)