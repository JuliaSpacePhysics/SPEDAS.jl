@testitem "fac_mat" begin
    using LinearAlgebra
    Itest(mat) = mat ≈ I

    r0 = [0, 3, 4]
    q = fac_mat(r0)
    @test q * q' ≈ I
    @test q * r0 ≈ [0, 0, 5]
    @test q * [3, 0, 0] ≈ [3, 0, 0]

    rs = [[0, 3, 4], [0, 2, 0]]
    qs = fac_mat.(rs)
    @test all(Itest.(qs .* adjoint.(qs)))
end