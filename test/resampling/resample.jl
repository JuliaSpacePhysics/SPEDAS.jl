@testitem "resample" begin
    # Test 1D array
    arr1d = collect(1:100)
    resampled1d = resample(arr1d, 50)  # default dim=1
    @test length(resampled1d) == 50
    @test resampled1d[1] == 1
    @test resampled1d[end] == 100
    # Test when n > original length
    @test resample(arr1d, 200) === arr1d  # Should return original array

    # Test 3D array with different dimensions
    arr3d = reshape(1:600, 100, 3, 2)
    # Resample first dimension
    resampled3d_1 = resample(arr3d, 50)  # default dim=1
    @test size(resampled3d_1) == (50, 3, 2)
    @test resampled3d_1[end, :, :] == arr3d[end, :, :]

    # Resample second dimension
    resampled3d_2 = resample(arr3d, 2, dim=2)
    @test size(resampled3d_2) == (100, 2, 2)
    @test resampled3d_2[:, end, :] == arr3d[:, end, :]
end

@testitem "tresample" begin
    using DimensionalData

    # Test DimArray with time dimension first
    nt = 100
    ny = 51
    da = DimArray(rand(nt, ny), (Ti(1:nt), Y(1:ny)))
    resampled_da = tresample(da, 50)
    @test size(resampled_da, 1) == 50  # Check time dimension is resampled
    @test size(resampled_da, 2) == ny  # Y dimension unchanged

    # Test DimArray with time dimension second
    da2 = DimArray(rand(ny, nt), (Y(1:ny), Ti(1:nt)))
    resampled_da2 = tresample(da2, 50)
    @test size(resampled_da2, 1) == ny  # Y dimension unchanged
    @test size(resampled_da2, 2) == 50  # Check time dimension is resampled

    # Test error for DimArray without time dimension
    da3 = DimArray(rand(ny, ny), (Y(1:ny), X(1:ny)))
    @test_throws ArgumentError tresample(da3, 50)
end
