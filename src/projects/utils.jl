function project_doc(mod, name, file=nothing, base_url="https://github.com/JuliaSpacePhysics/SPEDAS.jl/blob/main/config")
    doc = """
Sub-module for **"$(name) ($mod)"**

To load project, project-specific instrument and dataset variables into scope:

```julia
using SPEDAS.$(mod)
```
"""
    if !isnothing(file)
        doc *= "\n\nConfiguration File: [$(file)]($(base_url)/$(file))"
    end
    return doc
end