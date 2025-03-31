using TestItems, TestItemRunner
@run_package_tests

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(
        SPEDAS;
        ambiguities=(exclude=[Base.show],)
    )
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
