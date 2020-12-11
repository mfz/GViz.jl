using GViz
using Documenter

makedocs(;
    modules=[GViz],
    authors="Florian Zink <zink.florian@gmail.com> and contributors",
    repo="https://github.com/mfz/GViz.jl/blob/{commit}{path}#L{line}",
    sitename="GViz.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mfz.github.io/GViz.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mfz/GViz.jl",
)
