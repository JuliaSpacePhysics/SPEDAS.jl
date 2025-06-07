@testitem "tsort" begin
    using DimensionalData

    times = [3.0, 1.0, 2.0]
    t = Ti(times)
    y = Y(1:3)
    da = rand(t, y)
    result = tsort(da)
    @test parent(dims(result, Ti)) == sort(times)
    @test result[Ti(1)] == da[Ti(2)]
    @test result[Ti(3)] == da[Ti(1)]
end

@testitem "tmean, tmedian" begin
    using DimensionalData
    using Statistics
    using Dates

    t = Ti(Millisecond.(1:4))
    y = Y(1:2)
    da1 = rand(t)
    da2 = rand(t, y)

    @test_throws InexactError mean(t)

    @test tmean(da1) == mean(da1)
    @test tmean(da2) == vec(mean(da2, dims = 1))

    @test tmedian(da1) == median(da1)
    @test tmedian(da2) == vec(median(da2, dims = 1))
end