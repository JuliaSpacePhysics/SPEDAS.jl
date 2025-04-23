install:
    #!/usr/bin/env -S sh
    julia --project=docs/ -e '
        using Pkg
        Pkg.develop([
            PackageSpec(url="https://github.com/SciQLop/Speasy.jl"),
            PackageSpec(url="https://github.com/Beforerr/PySPEDAS.jl"),
            PackageSpec(path=pwd())
        ])
        Pkg.instantiate()
    '

[no-cd]
servedocs:
    #!/usr/bin/env -S julia --threads=auto --project=docs/ -i
    import Speasy
    using Pkg
    Pkg.develop(PackageSpec(path=pwd()))
    using LiveServer;
    servedocs(include_dirs=["src/"])