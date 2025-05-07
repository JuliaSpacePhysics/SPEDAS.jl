# Radiation Belt Modeling

International Radiation Belt Environment Modeling (IRBEM)

```@example mag_model
using CairoMakie
using IRBEM

# Draw sphere
function draw_sphere!(ax)
    u = range(0, 2π, length=40)
    v = range(0, π, length=20)
    xs = cos.(u') .* sin.(v)
    ys = sin.(u') .* sin.(v)
    zs = ones(40)' .* cos.(v) 
    wireframe!(ax, xs, ys, zs, color=:black)
end
```

## Trace field line

```@example mag_model
# Set up model and input
model = MagneticField(options=[0,0,0,0,0])
LLA = Dict(
    "x1" => 651, "x2" => 63, "x3" => 15.9,
    "dateTime" => "2015-02-02T06:12:43"
)
maginput = Dict("Kp" => 40.0)
out = trace_field_line(model, LLA, maginput)

# Plot field line
fig = Figure()
axis = (xlabel="x GEO", ylabel="y GEO", zlabel="z GEO")
ax = Axis3(fig[1, 1]; axis..., limits=((-5, 5), (-5, 5), (-5, 5)))
positions = Point3f.(eachcol(out.posit)[1:8:end])
scatter!(ax, positions)
draw_sphere!(ax)
fig
```

## Azimuthal field line visualization

```@example mag_model
model = MagneticField(options = [0,0,0,0,0])
maginput = Dict("Kp"=>0.0)
posits = mapreduce(hcat, 0:20:360) do x3
    X = Dict("x1"=>651, "x2"=>55, "x3"=>x3, "dateTime"=>"2015-02-02T06:12:43")
    output = trace_field_line(model, X, maginput)
    output.posit
end

fig = Figure()
ax = Axis3(fig[1, 1])
scatter!(Point3f.(eachcol(posits)[1:3:end]))
draw_sphere!(ax)
fig
```

## Drift shell

```@example mag_model
model = MagneticField(options = [0,0,0,0,0])
X = Dict("x1"=>651, "x2"=>63, "x3"=>20, "dateTime"=>"2015-02-02T06:12:43")
maginput = Dict("Kp"=>40)
output = drift_shell(model, X, maginput)
posits = Point3f.(vec(eachslice(output.posit;dims=(2,3))))

fig = Figure()
ax = Axis3(fig[1, 1])
scatter!(ax, posits)
draw_sphere!(ax)
fig
```
