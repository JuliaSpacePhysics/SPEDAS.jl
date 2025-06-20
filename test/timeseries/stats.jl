@testitem "groupby_dynamic" begin
    using Dates
    using SPEDAS: groupby_dynamic

    times = 1:1000
    dt = 24
    @test length(groupby_dynamic(times, dt)[1]) == 42
    times = Hour.(times)
    @test length(groupby_dynamic(times, Hour(dt))[1]) == 42
    times += DateTime(2010)
    @test length(groupby_dynamic(times, Hour(dt))[1]) == 42

    using JET
    @test_opt groupby_dynamic(times, Hour(dt))
    @test_call groupby_dynamic(times, Hour(dt))

    using Chairmarks
    verbose = true
    verbose && @info "groupby_dynamic" @b(groupby_dynamic($times, Hour($dt)))
end

@testitem "timeseries statistics" begin
    using DimensionalData
    using SPEDAS.NaNStatistics
    using Statistics

    using Dates

    t = Ti(Millisecond.(0:3))
    y = Y(1:2)
    da1 = rand(t)
    da2 = rand(t, y)

    @test_throws InexactError mean(t)

    # tmean
    @test tmean(da1) == mean(da1)
    @test tmean(da1, Millisecond(2)) == [mean(da1[1:2]), mean(da1[3:4])]
    @test tmean(da2) == vec(mean(da2, dims = 1))
    @test tmean(da2, Millisecond(2)) == [mean(parent(da2)[1:2, :], dims = 1); mean(parent(da2)[3:4, :], dims = 1)]

    # tmedian
    @test tmedian(da1) == median(da1)
    @test tmedian(da1, Millisecond(2)) == [median(da1[1:2]), median(da1[3:4])]
    @test tmedian(da2) == vec(median(da2, dims = 1))

    # tsum, tvar, tstd, tsem
    @test tsum(da2) == vec(sum(da2, dims = 1))
    @test tvar(da1) == var(da1)
    @test tstd(da1) == std(da1)
    @test tsem(da1) == nansem(da1)

    # DimStack
    @test tmean(DimStack((da1, da2))) == (; layer1 = tmean(da1), layer2 = tmean(da2))

    using Chairmarks
    verbose = false
    da_bench1 = rand(Ti(1:1000))
    verbose && @info "tmean" @b(tmean($da_bench1))
    da_bench = DimArray(rand(1000, 3), (Ti(1:1000), Y(1:3)))
    verbose && @info "tmean" @b(tmean($da_bench, 10))
end
