module GViz

repmat = repeat

pkgpath(paths...) = joinpath(@__DIR__, "..", paths...)
 
include("params.jl")

include("RefFrame.jl")

include("render.jl")
include("ticks2.jl")
include("geometry.jl")
include("colors.jl")

include("datatrack.jl")
include("genomicaxis.jl")

include("GenomicFeatureTrack.jl")

include("AbstractGenomicFeature.jl")
include("GTF.jl")

end
