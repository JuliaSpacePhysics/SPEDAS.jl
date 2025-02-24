# https://github.com/nsioulas/MHDTurbPy/blob/main/functions/calc_diagnostics.py
# incompressible MHD [https://en.wikipedia.org/wiki/Magnetohydrodynamic_turbulence] 
# Elsässer variables
function Elsässer(u, B, sign=1)
    return u + sign .* B, u - sign .* B
end

function norm²(x)
    return sum(x .* x)
end

function σ_c(z⁺, z⁻)
    z⁺² = norm²(z⁺)
    z⁻² = norm²(z⁻)
    return (z⁺² - z⁻²) / (z⁺² + z⁻²)
end

σ_c(u, B, sign) = σ_c(Elsässer(u, B, sign)...)