[no-cd]
servedocs:
    #!/usr/bin/env -S julia --threads=auto --project=docs/ -i
    using Speasy
    using Pkg
    Pkg.develop(PackageSpec(path=pwd()))
    using LiveServer;
    servedocs(include_dirs=["src/"])