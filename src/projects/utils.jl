_dict2nt(d::Dict; f=identity) = NamedTuple((Symbol(key), f(value)) for (key, value) in d)

function project_doc(mod, name, file=nothing, base_url="https://github.com/Beforerr/SPEDAS.jl/blob/main/config")
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