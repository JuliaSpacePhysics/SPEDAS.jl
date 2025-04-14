@doc project_doc("PSP", "Parker Solar Probe")
module PSP
using ..SPEDAS: @load_project_config, project_doc
using SpaceDataModel: Project, DataSet
using Unitful

global psp::Project

@load_project_config "PSP.toml"

end