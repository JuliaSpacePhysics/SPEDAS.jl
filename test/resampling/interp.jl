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