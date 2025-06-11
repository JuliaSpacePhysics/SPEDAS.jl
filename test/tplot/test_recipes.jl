@testsnippet MakieShare begin
    using Makie
    using Unitful
end

@testitem "plot recipes" setup = [MakieShare] begin
    @test_nowarn dualplot((rand(3), rand(4)); plotfunc = scatterlines!)
end

@testitem "LinesPlot" setup = [MakieShare] begin
    using DimensionalData
    using Dates
    @test_nowarn linesplot((rand(3), rand(4)))
    ys = [[1, 2, 4] [3, 4, 10]]
    @test_nowarn linesplot(ys)
    @test_nowarn linesplot([10, 20, 30], ys)
    @test_nowarn linesplot([[1, 2, 4], [3, 4, 10, 11]])

    t = Ti(range(DateTime(2000), step = Hour(1), length = 4))
    A = rand(t, Y(1:5))
    Au = A * 1u"nT"
    # somehow this does not work
    @test_throws ArgumentError linesplot(Au)

    @test_nowarn let
        f = Figure()
        ax = Axis(f[1, 1]; SPEDAS.axis_attributes(Au)...)
        linesplot!(ax, t.val, Au)
        f
    end
end

@testitem "PanelPlot" setup = [MakieShare] begin
    # Create sample data
    n = 24
    data1 = rand(n) * 4u"km/s"  # Vector with units
    data2 = rand(n) * 4u"km/s"  # Same units
    data3 = rand(n) * 1u"eV"    # Different units
    data4 = rand(n, 4)           # Matrix (for heatmap)
    f = Figure()
    @test_nowarn tplot_panel(f[1, 1], data1; axis = (; title = "Single time series"))
    @test_nowarn tplot_panel(f[2, 1], [data1, data2]; axis = (; title = "Multiple series"), plotfunc = lines!)
    @test_nowarn tplot_panel(f[3, 1], (data1, data3); axis = (; title = "Dual y-axes"), plotfunc = scatterlines!)
    @test_nowarn tplot_panel(f[1, 2], data4'; axis = (; title = "Series"), plotfunc = series!)
    @test_nowarn tplot_panel(f[2, 2], [data4, data1, data2]; axis = (; title = "Heatmap with overlays"))
    @test_nowarn tplot_panel(f[3, 2], data2, data3; axis = (; title = "XY plot (fallback)"))
end
