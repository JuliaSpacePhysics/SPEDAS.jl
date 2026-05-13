@testitem "amap" begin
    using DimensionalData
    using Dates

    ts1 = DateTime(2020):Second(1):DateTime(2020) + Second(4)
    ts2 = DateTime(2020) + Second(1):Second(1):DateTime(2020) + Second(3)
    a = DimArray(Float64[1, 2, 3, 4, 5], (Ti(ts1),))
    b = DimArray(Float64[10, 20, 30], (Ti(ts2),))

    result = amap(+, a, b)
    @test result ≈ [12.0, 23.0, 34.0]
    @test dims(result, Ti).val == collect(ts2)
end

@testitem "set_coord dim update" begin
    using DimensionalData

    da = DimArray(ones(3, 3), (Ti(1:3), Dim{:GEI_comp}([:x, :y, :z]));
                  name=:B_GEI, metadata=Dict("COORDINATE_SYSTEM" => "GEI"))
    result = set_coord(da, "GSE")

    @test SPEDAS.get_coord(result) == "GSE"
    @test string(result.name) == "B_GSE"
    @test string(DimensionalData.name(dims(result, 2))) == "GSE_comp"
end
