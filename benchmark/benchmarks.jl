# Benchmark
using Chairmarks
using DimensionalData
using SPEDAS: SPEDAS, tinterp, tsync

da_bench = DimArray(rand(1000, 3), (Ti(1:1000), Y(1:3)))
t_bench = rand(1:1000, 32)
@info "tinterp" @b(tinterp(da_bench, t_bench))
# 6.396 μs (43 allocs: 3.047 KiB)

da1, da2, da3 = SPEDAS.workload_interp_setup(128)
@info "tsync" @b(tsync(da1, da2, da3))
# 10.709 μs (84 allocs: 10.266 KiB)
