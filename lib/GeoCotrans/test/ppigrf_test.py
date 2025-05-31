#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "ppigrf",
# ]
# ///

from datetime import datetime
import ppigrf
import time


def main() -> None:
    date = datetime(2021, 3, 28)

    lon = 5.32415  # degrees east
    lat = 60.39299  # degrees north
    h = 0  # kilometers above sea level
    Be, Bn, Bu = ppigrf.igrf(lon, lat, h, date)  # returns east, north, up
    print(Be, Bn, Bu)

    r = 6500  # kilometers from center of Earth
    theta = 30  # colatitude in degrees
    phi = 4  # degrees east (same as lon)

    # Time the IGRF calculation
    start_time = time.time()
    Br, Btheta, Bphi = ppigrf.igrf_gc(r, theta, phi, date)
    end_time = time.time()
    elapsed_time = (end_time - start_time) * 1000  # Convert to milliseconds
    
    print(f"IGRF calculation result: {Br}, {Btheta}, {Bphi}")
    print(f"Time taken: {elapsed_time:.3f} ms")
    
    # Run multiple times to get average performance
    num_runs = 100
    start_time = time.time()
    for _ in range(num_runs):
        ppigrf.igrf_gc(r, theta, phi, date)
    end_time = time.time()
    avg_time = ((end_time - start_time) * 1000) / num_runs
    
    print(f"Average time over {num_runs} runs: {avg_time:.3f} ms")


if __name__ == "__main__":
    main()
