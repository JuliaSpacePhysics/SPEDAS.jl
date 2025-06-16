@testitem "tinterp interpolation" begin
    using Dates, DimensionalData

    # create a simple linearly increasing series
    times = [DateTime(2020, 1, 1), DateTime(2020, 1, 2), DateTime(2020, 1, 3)]
    da = DimArray(0:2, (Ti(times),))

    # single DateTime interpolation
    t1 = DateTime(2020, 1, 1, 12)
    res1 = tinterp(da, t1)
    @test res1 ≈ 0.5

    # multiple DateTime interpolation
    t2 = [DateTime(2020, 1, 1, 6), DateTime(2020, 1, 2, 18)]
    res2 = tinterp(da, t2)
    @test isa(res2, DimArray)
    @test parent(res2) ≈ [0.25, 1.75]
    @test all(dims(res2, Ti) .== t2)

    # create 3×2 series with numeric time dimension
    da3 = DimArray([1.0 4.0; 2.0 5.0; 3.0 6.0], (Ti(times), Y([10, 20])))

    # interpolate at two points
    res = tinterp(da3, t2)
    @test isa(res, AbstractDimArray)
    @test size(res) == (2, 2)
    @test all(dims(res, Ti) .== t2)
    @test parent(res) ≈ [1.25 4.25; 2.75 5.75]
end

@testitem "tsync function" begin
    using Dates, DimensionalData

    a_sync, b_sync, c_sync = SPEDAS.workload_interp()

    # Check that all synchronized arrays have the same time dimension
    @test parent(dims(a_sync, Ti)) == parent(dims(b_sync, Ti)) == parent(dims(c_sync, Ti))

    # Check that the time range is the intersection of all input arrays
    @test dims(a_sync, Ti)[1] == DateTime(2020, 1, 2)
    @test dims(a_sync, Ti)[end] == DateTime(2020, 1, 3)

    # Check that values from the first and second array are preserved
    @test a_sync == [2, 3]
    @test b_sync == [10, 11]
    # The values should be interpolated at DateTime(2020, 1, 2) and DateTime(2020, 1, 3)
    expected_values = [
        5.5 9;
        6.5 11
    ]
    @test parent(c_sync) ≈ expected_values

    using JET
    @test_opt broken = true SPEDAS.workload_interp() # runtime dispatch
    @test_call broken = true SPEDAS.workload_interp() # runtime dispatch
end
