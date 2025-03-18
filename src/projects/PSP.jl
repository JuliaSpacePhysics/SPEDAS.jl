@doc SPEDAS.project_doc("PSP", "Parker Solar Probe")
module PSP
using ..SPEDAS

load_config() = SPEDAS.@load_project_config "PSP.toml"
load_config()

end
