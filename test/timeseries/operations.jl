@testitem "tsort, tclip, tview" begin
    using DimensionalData

    times = [3.0, 1.0, 2.0]
    t = Ti(times)
    y = Y(1:3)
    da = rand(t, y)
    result = tsort(da)
    @test parent(dims(result, Ti)) == sort(times)
    @test result[Ti(1)] == da[Ti(2)]
    @test result[Ti(3)] == da[Ti(1)]

    # tclip
    @test_throws "Cannot use an interval or `Between` with `Unordered`" tclip(da, 1.0, 2.0) == da[2:3, :]
    @test tclip(result, 1.0, 2.0) == parent(da[2:3, :])

    # tview
    @test_throws "Cannot use an interval or `Between` with `Unordered`" tview(da, 1.0, 2.0)
    @test tview(result, 1.0, 2.0) == parent(da[2:3, :])

    # Benchmark
    using Chairmarks
    tclip_bench = @b tclip($result, 1.0, 2.0)
    tview_bench = @b tview($result, 1.0, 2.0)
    @test tclip_bench.allocs > tview_bench.allocs
    @test tclip_bench.time > tview_bench.time
    @info tclip_bench, tview_bench

    using JET
    @test_opt broken = true tsort(da) # TODO: `set` is not type-stable
    @test_call tsort(da)
    @test_opt tclip(result, 1.0, 2.0)
    @test_call tclip(result, 1.0, 2.0)
    @test_opt tview(result, 1.0, 2.0)
    @test_call tview(result, 1.0, 2.0)
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
