_dict2nt(d::Dict; f=identity) = NamedTuple((Symbol(key), f(value)) for (key, value) in d)

project_doc(mod, name) = """
Sub-module for **"$(name) ($mod)"**

To load project, project-specific instrument and dataset variables into scope:

```julia
using SPEDAS.$(mod)
```
"""