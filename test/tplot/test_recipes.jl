@testitem "plot recipes" begin
    using Makie
    @test_nowarn dualplot((rand(3), rand(4)); plotfunc=scatterlines!)
end