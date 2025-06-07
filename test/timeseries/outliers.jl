# References
# - https://www.mathworks.com/help/matlab/ref/isoutlier.html
# - https://www.mathworks.com/help/matlab/ref/filloutliers.html

@testitem "find outliers" begin
    using LinearAlgebra
    A = [57, 59, 60, 100, 59, 58, 57, 58, 300, 61, 62, 60, 62, 58, 57]
    @test findall(find_outliers(A)) == [4, 9]
    @test findall(find_outliers(A, :mean)) == [9]

    # Use Moving Detection Method
    x = -2π:0.1:2π
    A = sin.(x)
    A[47] = 0
    @test findall(find_outliers(A, :median, 5)) == [47]
    @test findall(find_outliers(A, :median, (2, 2))) == [47]
    @test findall(find_outliers(A, :mean, 12)) == [47]

    # Detect Outliers in Matrix
    A = rand(5, 5) + 200I
    @test sum(diag(find_outliers(A))) == 5
end

@testitem "replace outliers" begin
    A = [57, 59, 60, 100, 59, 58, 57, 58, 300, 61, 62, 60, 62, 58, 57]
    Af = Float32.(A)

    @test isnan(replace_outliers(Af)[4])

    # Test interpolation
    @test replace_outliers(Af, :linear)[[4, 9]] == [59.5, 59.5]

    # Test other methods
    @test replace_outliers(A, :nearest)[[4, 9]] == [60, 58]
    @test replace_outliers(A, :previous)[[4, 9]] == [60, 58]
    @test replace_outliers(A, :next)[[4, 9]] == [59, 61]

    # Specify Outlier Locations
    detect = find_outliers(A)
    @test replace_outliers(A, :next, detect)[[4, 9]] == [59, 61]
end
