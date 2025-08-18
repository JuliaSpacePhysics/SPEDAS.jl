@testitem "mva_eigen basic functionality with synthetic data" begin
    using LinearAlgebra
    using DimensionalData
    using Unitful

    # Test with a simple 3D magnetic field data where we know the expected result
    # Create synthetic data with known variance structure
    Bl = cosd.(0:30:180)
    Bm = sind.(0:30:180)
    Bn = 0.1 .* ones(7)
    B = hcat(Bl, Bm, Bn)

    F = mva_eigen(B; check = true)

    # Check that we get 3 eigenvalues and 3 eigenvectors
    @test length(F.values) == 3
    @test size(F.vectors) == (3, 3)
    # Check that eigenvalues are sorted in descending order (default behavior)
    @test F.values[1] >= F.values[2] >= F.values[3]
    @test F.vectors[:, 1] ≈ [1.0, 0.0, 0.0] || F.vectors[:, 1] ≈ [-1.0, 0.0, 0.0]
    @test F.vectors[:, 2] ≈ [0.0, 1.0, 0.0] || F.vectors[:, 2] ≈ [0.0, -1.0, 0.0]
    @test F.vectors[:, 3] ≈ [0.0, 0.0, 1.0] || F.vectors[:, 3] ≈ [0.0, 0.0, -1.0]
    # Check that eigenvectors are orthonormal
    @test F.vectors' * F.vectors ≈ I
    @test abs(det(F.vectors)) ≈ 1
    @test mva(B) .* diag(F.vectors)' ≈ B # Note: eigenvectors are only unique up to sign

    # Dimensional data
    B1 = DimArray(B * u"nT", (Ti(0:6), Y(1:3)))
    B2 = DimArray(collect(B') * u"nT", (Y(1:3), Ti(0:6)))
    F1 = mva_eigen(B1)
    F2 = mva_eigen(B2)
    @test F1.values ≈ F2.values
    @test F1.vectors ≈ F2.vectors

    # Test edge cases and robustness
    B_const = ones(10, 3)
    F_const = mva_eigen(B_const)
    @test F_const.values == [0, 0, 0]
end

@testitem "right-handed coordinate system check" begin
    using LinearAlgebra: Eigen
    using SPEDAS: is_right_handed

    v1 = [1.0, 0.0, 0.0]
    v2 = [0.0, 1.0, 0.0]
    v3 = [0.0, 0.0, 1.0]
    v3_left = [0.0, 0.0, -1.0]

    # Test with Eigen object with right-handed system
    F_right = Eigen([3.0, 2.0, 1.0], [v1 v2 v3])
    @test is_right_handed(F_right) == true

    # Test with Eigen object with left-handed system
    F_left = Eigen([3.0, 2.0, 1.0], [v1 v2 v3_left])
    @test is_right_handed(F_left) == false
end