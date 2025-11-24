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
    using CDAWeb
    t0 = "2010-02-25T00:00:00"
    t1 = "2010-02-25T23:59:59"
    pos = DimArray(CDAWeb.get_data("tha_l1_state", "tha_pos", t0, t1))
    geo = gei2geo(pos)
    @test geo.data[:, [1, end]] ≈ [32500.703796760008 32964.60545865282; -5688.514017885206 -5723.818569392612; -4950.9140625 -5013.51220703125]
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
