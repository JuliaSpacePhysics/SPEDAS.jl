using TestItemRunner

@run_package_tests

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(
        SPEDAS;
        ambiguities = (exclude = [Base.show],)
    )
end

@testitem "cotrans" begin
    using Dates, DimensionalData
    using IRBEM
    times = [DateTime("2010-02-25T00:00:00"), DateTime("2010-02-25T23:59:00")]
    gei_data = [
        -26968.025  -27617.074
        19010.012   18887.152
        -4950.914   -5013.512
    ]
    pos = DimArray(
        gei_data, (X(1:3), Ti(times));
        metadata = Dict("COORDINATE_SYSTEM" => "GEI")
    )
    @test SPEDAS.get_coord(pos) == "GEI"

    geo = cotrans(:GEO, pos)
    expected = [
        32500.703796760055  32964.60545865276
        -5688.5140178849615 -5723.818569392979
        -4950.9140625       -5013.51220703125
    ]
    @test geo ≈ expected
    @test geo isa DimArray
    @test SPEDAS.get_coord(geo) == "GEO"

    @test cotrans(:GEI => :GEO, pos) ≈ expected
    geo_irbem = cotrans(:GEO, pos; backend = IRBEM)
    @test geo_irbem ≈ expected
    @test geo_irbem isa DimArray
    @test SPEDAS.get_coord(geo_irbem) == "GEO"
end
