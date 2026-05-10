@testitem "current_density numeric" begin
    using Dates
    using DimensionalData

    ts = DateTime(2020):Second(1):DateTime(2020) + Second(4)
    B = DimArray(hcat(ones(5), 0:4, zeros(5)), (Ti(ts), Dim{:comp}([:x, :y, :z])))
    V = DimArray(hcat(zeros(5), zeros(5), ones(5)), (Ti(ts), Dim{:comp}([:x, :y, :z])))

    out = current_density(B, V)

    @test out.Jx[1] ≈ 1 / (4π * 1e-7)
    @test out.Jx[1] isa Float64
end

@testitem "current_density unitful" begin
    using Dates
    using DimensionalData
    using Unitful

    ts = DateTime(2020):Second(1):DateTime(2020) + Second(4)
    B = DimArray(hcat(ones(5), 0:4, zeros(5)) .* u"nT", (Ti(ts), Dim{:comp}([:x, :y, :z])))
    V = DimArray(hcat(zeros(5), zeros(5), ones(5)) .* u"km/s", (Ti(ts), Dim{:comp}([:x, :y, :z])))

    out = current_density(B, V)
    expected = uconvert(u"nA/m^2", (1u"nT/s") / (Unitful.μ0 * 1u"km/s"))

    @test uconvert(u"nA/m^2", out.Jx[1]) ≈ expected
    @test Unitful.dimension(out.Jx[1]) == Unitful.dimension(1u"A/m^2")
end
