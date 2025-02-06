# ---
# title: Basic interactive tplot
# ---

using Dates
using DimensionalData
using SpaceTools
using CairoMakie

t0 = DateTime(2000)
t1 = DateTime(2000, 1, 10)

function func(t0, t1)
    x = t0:Day(1):t1
    y = sin.(1:length(x))
    DimArray(y, Ti(x))
end

f, axes = tplot(func, t0, t1)

# ## Interactive tplot

# Here we simulate a user interacting with the plot by progressively zooming out in time with `tlims!`.
# Note: For real-time interactivity, consider using the `GLMakie` backend instead of `CairoMakie`.

dt = Day(1)
mkpath("assets") #src

record(f, "assets/interactive.mp4", 1:5; framerate=2) do n
    tlims!(t0 - n * dt, t1 + n * dt)
    sleep(0.5)
end;

# ```@raw html
# <video autoplay loop muted playsinline controls src="../assets/interactive.mp4" />
# ```