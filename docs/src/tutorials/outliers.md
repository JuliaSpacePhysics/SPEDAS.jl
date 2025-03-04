# Remove spikes from signal

The example data is a sine wave with random spikes.

```@example spikes
using Random

"""
    create_sample_data()

Create a sine wave and add random positive and negative spikes.
Returns a DataFrame with columns: `x`, `y`, `rand`, `spike_high`, `spike_low`, and `y_spikey`.
"""
function create_sample_data(; length=1000)
    # Create x values and compute sine wave y values
    x = range(0, stop=2π, length=length)
    y = 2 .* sin.(x)

    rands = rand(Xoshiro(1), length)

    # random values above this trigger a spike:
    RAND_HIGH = 0.98
    # random values below this trigger a negative spike:
    RAND_LOW = 0.02

    # amplitude of the spikes:
    spike_amplitudes =  0.1 .+ 10rand(Xoshiro(2), length)

    # Create random spikes based on threshold conditions
    spike_high = ifelse.(rands .> RAND_HIGH, 1, 0) .* spike_amplitudes
    spike_low  = ifelse.(rands .< RAND_LOW, -1, 0) .* spike_amplitudes
    n_spikes = sum(spike_high .!= 0) + sum(spike_low .!= 0)

    y .+ spike_high .+ spike_low, n_spikes
end
y_spikey, n_spikes = create_sample_data()
```

By default, `replace_outliers` uses a threshold-detection approach based on the median absolute deviation (MAD) to detect spikes. It is also possible to use a filter-based approach (i.e. low-pass filtering).

```@example spikes
using SpaceTools
using CairoMakie
using Test

y_remove_outliers = replace_outliers(y_spikey, detector=find_spikes)
n_removed = sum(isnan.(y_remove_outliers))
@test n_removed == n_spikes

begin
    f = Figure()
    lines(f[1,1],y_spikey)
    lines(f[2,1],y_remove_outliers)
    f
end
```

```@docs
find_spikes
replace_outliers
```
