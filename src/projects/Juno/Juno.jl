@doc project_doc("Juno", "Juno", "Juno.toml")
module Juno
using ..SPEDAS: @load_project_config, project_doc

@load_project_config "Juno.toml"

end