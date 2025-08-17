# https://github.com/nsioulas/MHDTurbPy/blob/main/functions/calc_diagnostics.py
# incompressible MHD [https://en.wikipedia.org/wiki/Magnetohydrodynamic_turbulence] 
# Elsässer variables

Alfven_velocity(B, ρ) =
    @. B / sqrt(μ0 * ρ) |> upreferred

function Elsässer(u, B, ρ)
    return u + Alfven_velocity(B, ρ), u - Alfven_velocity(B, ρ)
end

function norm²(x)
    return sum(x .* x)
end

function σ_c(z⁺, z⁻)
    z⁺² = norm²(z⁺)
    z⁻² = norm²(z⁻)
    return (z⁺² - z⁻²) / (z⁺² + z⁻²)
end

σ_c(u, B, n) = σ_c(Elsässer(u, B, n)...)