

## Trace field line

```@example mag_model
using CairoMakie
using IRBEM

# Set up model and input
model = MagneticField(options=[0,0,0,0,0])
LLA = Dict(
    "x1" => 651.0,
    "x2" => 63.0,
    "x3" => 15.9,
    "dateTime" => "2015-02-02T06:12:43"
)
maginput = Dict("Kp" => 40.0)
out = trace_field_line(model, LLA, maginput)

# Extract field line points
POSIT = out.posit
pltDensity = 10
xGEO = POSIT[1, 1:pltDensity:end]
yGEO = POSIT[2, 1:pltDensity:end]
zGEO = POSIT[3, 1:pltDensity:end]

# Plot field line
fig = Figure()
ax = Axis3(fig[1, 1], xlabel="x GEO", ylabel="y GEO", zlabel="z GEO",
            limits = ((-5, 5), (-5, 5), (-5, 5)))
scatter!(ax, xGEO, yGEO, zGEO, color=:blue, markersize=10)

# Draw sphere
function draw_sphere!(ax)
    u = range(0, 2π, length=40)
    v = range(0, π, length=20)
    xs = cos.(u') .* sin.(v)
    ys = sin.(u') .* sin.(v)
    zs = ones(40)' .* cos.(v) 
    wireframe!(ax, xs, ys, zs, color=:black)
end

# Draw sphere
draw_sphere!(ax)
fig
```