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

@testitem "dropna" begin
    using DimensionalData
    # Test case 1: Matrix with NaN
    data = [1.0 2.0; NaN 4.0; 5.0 6.0]
    da = DimArray(data, (Ti(4:6), Dim{:var}(1:2)))
    result = dropna(da)
    @test size(result) == (2, 2)
    @test result.data == [1.0 2.0; 5.0 6.0]

    # Test case 2: All NaN in one time point
    data = [NaN 2.0; NaN NaN; 5.0 6.0]
    da = DimArray(data, (Ti(1:3), Dim{:var}(1:2)))
    result = dropna(da)
    @test size(result) == (1, 2)
    @test result.data == [5.0 6.0]
end

@testitem "tmask" begin
    using DimensionalData

    times = [1.0, 2.0, 3.0, 4.0, 5.0]
    values = [10.0 15.0; 20.0 25.0; 30.0 35.0; 40.0 45.0; 50.0 55.0]
    da = DimArray(values, (Ti(times), Y(1:2)))

    result = tmask(da, 2.0, 3.0)
    # Check that times 2 and 3 are NaN for all variables
    @test all(isnan.(result[2:3, :]))
    # Check that other times are unchanged
    @test result[1, :] == values[1, :]
    @test result[4:5, :] == values[4:5, :]
end
