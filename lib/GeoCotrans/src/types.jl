import Base: String

export AbstractCoordinateSystem, CoordinateVector, coord

abstract type AbstractCoordinateSystem end

struct CoordinateVector{C,T} <: FieldVector{3,T}
    x::T
    y::T
    z::T
    sym::C
end

for sys in (:GDZ, :GEO, :GSM, :GSE, :SM, :GEI, :MAG, :SPH, :RLL, :HEE, :HAE, :HEEQ, :J2000)
    @eval struct $sys <: AbstractCoordinateSystem end
    @eval $sys(x, y, z) = CoordinateVector(promote(x, y, z)..., $sys())
    @eval $sys(𝐫) = CoordinateVector(𝐫..., $sys())
    @eval export $sys
end

@doc """Geocentric Solar Magnetospheric (GSM)\n\nX points sunward from Earth's center. The X-Z plane is defined to contain Earth's dipole axis (positive North).
""" GSM

coord(v::CoordinateVector) = v.sym
Base.String(::Type{S}) where {S<:AbstractCoordinateSystem} = String(nameof(S))
Base.String(::S) where {S<:AbstractCoordinateSystem} = T(S)
