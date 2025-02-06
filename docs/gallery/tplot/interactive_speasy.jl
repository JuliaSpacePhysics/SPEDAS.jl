# ---
# title: Interactive tplot with Speasy
# cover: assets/interactive_speasy.png
# description: Visual exploration of OMNI data
# ---

# ## tplot with Speasy product ID strings

using Speasy
spz = speasy()

using Dates
using SpaceTools
using CairoMakie

t0 = DateTime("2008-09-05T10:00:00")
t1 = DateTime("2008-09-05T22:00:00")
tvars = [
    "cda/OMNI_HRO_1MIN/flow_speed",
    "cda/OMNI_HRO_1MIN/E",
    "cda/OMNI_HRO_1MIN/Pressure"
]
f, axes = tplot(tvars, t0, t1)

# save cover image #src
mkpath("assets") #src
save("assets/interactive_speasy.png", f) #src

# ## Interactive tplot

# Here we simulate a user interacting with the plot by progressively zooming out in time with `tlims!`.
# Note: For real-time interactivity, consider using the `GLMakie` backend instead of `CairoMakie`.

dt = Hour(12)
mkpath("assets") #src

record(f, "assets/interactive_speasy.mp4", 1:5; framerate=1) do n
    tlims!(t0 - n * dt, t1 + n * dt)
    sleep(1)
end;

# ```@raw html
# <video autoplay loop muted playsinline controls src="../assets/interactive_speasy.mp4" />
# ```