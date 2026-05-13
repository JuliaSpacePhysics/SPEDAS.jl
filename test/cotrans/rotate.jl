@testitem "rotate" begin
    using DimensionalData
    using Dates
    using LinearAlgebra

    ts = DateTime(2020):Second(1):DateTime(2020) + Second(2)
    da = DimArray([1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0], (Ti(ts), Dim{:comp}([:x, :y, :z])))

    # 90-degree rotation around z: x→y, y→-x
    Rz = [0.0 -1.0 0.0; 1.0 0.0 0.0; 0.0 0.0 1.0]
    mats = [Rz for _ in ts]
    mats_da = DimArray(mats, (Ti(ts),))

    result = rotate(da, mats_da)
    @test size(result) == size(da)
    @test result[1, :] ≈ [0.0, 1.0, 0.0]   # x=[1,0,0] → [0,1,0]
    @test result[2, :] ≈ [-1.0, 0.0, 0.0]  # y=[0,1,0] → [-1,0,0]
end

@testitem "select_rotate" begin
    using DimensionalData
    using Dates
    using LinearAlgebra

    ts = DateTime(2020):Second(1):DateTime(2020) + Second(4)
    da = DimArray(hcat(ones(5), zeros(5), zeros(5)), (Ti(ts), Dim{:comp}([:x, :y, :z])))

    # Coarser time grid for rotation matrices
    ts2 = DateTime(2020):Second(2):DateTime(2020) + Second(4)
    Rz = [0.0 -1.0 0.0; 1.0 0.0 0.0; 0.0 0.0 1.0]
    mats_da = DimArray([Rz for _ in ts2], (Ti(ts2),))

    result = select_rotate(da, mats_da)
    @test size(result) == size(da)
    # x=[1,0,0] rotated by Rz → [0,1,0]
    @test all(r ≈ [0.0, 1.0, 0.0] for r in eachrow(parent(result)))
end
