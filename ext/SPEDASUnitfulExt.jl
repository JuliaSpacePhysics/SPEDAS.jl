module SPEDASUnitfulExt

using Unitful: Unitful, μ0, upreferred
using SPEDAS: SPEDAS, _current_density

@views function SPEDAS.current_density(B::AbstractArray{<:Unitful.AbstractQuantity}, V::AbstractArray{<:Unitful.AbstractQuantity})
    return _current_density(B, V) do dBdt, Vz
        @. upreferred(dBdt / (μ0 * Vz))
    end
end

end
