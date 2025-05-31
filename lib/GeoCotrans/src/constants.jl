const R🜨 = 6371.2  # Earth Radius in km

const EARTH_A = 6378.1370             # semi-major axis in km
const EARTH_F = 1.0 / 298.257223563     # flattening
const EARTH_B = EARTH_A * (1.0 - EARTH_F)  # semi-minor axis
const EARTH_A2 = EARTH_A * EARTH_A
const EARTH_B2 = EARTH_B * EARTH_B
const EARTH_A2_B2_DIFF = EARTH_A2 - EARTH_B2
