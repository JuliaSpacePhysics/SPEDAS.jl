@testitem "pspectrum" begin
    using Dates
    using DimensionalData
    using DSP

    ts = DateTime(2020):Second(1):DateTime(2020) + Second(99)
    da = DimArray(sin.(1:100), (Ti(ts),))

    y = pspectrum(da; nfft=16)
    raw = pspectrum(parent(da), ts; nfft=16)
    y_default = pspectrum(da)

    @test size(y) == (9, 11)
    @test raw.power == parent(y)
    @test raw.time == dims(y, Ti).val
    @test raw.freq == dims(y, Dim{:frequency}).val
    @test size(y_default, 1) == 129
    @test dims(y, Ti)[1] == DateTime("2020-01-01T00:00:08")
    @test dims(y, Dim{:frequency})[1] == 0.0

    ts_time = Time(0):Nanosecond(500_000_000):Time(0) + Nanosecond(500_000_000 * 99)
    raw_time = pspectrum(sin.(1:100), ts_time; nfft=16)
    @test raw_time.time[1] == Time(0) + Second(4)

    multi = DimArray(hcat(sin.(1:100), cos.(1:100)), (Ti(ts), Dim{:comp}([:x, :y])))
    multi_spec = pspectrum(multi; nfft=16)
    @test size(multi_spec) == (9, 11, 2)
    @test dims(multi_spec, Dim{:frequency}).val == raw.freq
    @test dims(multi_spec, Ti).val == raw.time
    @test dims(multi_spec, Dim{:comp}).val == [:x, :y]
end
