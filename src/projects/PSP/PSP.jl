@doc project_doc("PSP", "Parker Solar Probe", "PSP.toml")
module PSP
using ..SPEDAS: @load_project_config, project_doc

@load_project_config "PSP.toml"

end