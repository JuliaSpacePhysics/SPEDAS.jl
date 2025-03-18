@doc SPEDAS.project_doc("THEMIS", "Time History of Events and Macroscale Interactions during Substorms")
module THEMIS
using ..SPEDAS

load_config() = SPEDAS.@load_project_config "THEMIS.toml"
load_config()

end