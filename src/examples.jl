
using GViz

gp = GenomicPos(;height=1cm, margin_top = 8mm)
dt = DataTrack(x = [0,1,2,3,4,5],
               y = [7, 10, 20, 30, 40, 42],
               fill = ["red", "green", "blue","red", "green", "blue"],
               size = [3,1,2,3,4,5], alpha = 0.3,
               layers = [Dict(:geom => :line, :size => 1, :color => "black", :alpha => 1.0),
                         Dict(:geom => :point)])

#doc = RefFrame(;width=20cm, height = 3cm, defaultparams...)
#p0 = RefFrame(transform = Translation(0cm, 0cm), children=[gp])
#p1 = RefFrame(transform=Translation(0cm, 2cm), children=[dt], title="Track1")
#p2 = RefFrame(transform=Translation(0cm, 5.5cm), children=[dt], title="Track2")
#
#push!(doc.children, p0)
#push!(doc.children, p1)
#push!(doc.children, p2)
#
#pdf(doc, "/tmp/dt.pdf", 0, 5; absolute=true)

plotTracks([gp, dt, dt, gp], "/tmp/dt.pdf", -0.1, 5.2; defaultparams..., ymin=0, ymax=50)


dt = DataTrack()

p5 = RefFrame(children=[dt], title = "Track 5",
              shape="diamond", size=1, symbol_line_width = 0,
              fill = "red",
              x = range(0; stop = 5, length = 500), y = rand(500))

plotTracks([gp, dt, p5], "/tmp/dt.pdf", 0, 5; track_spacing = 2mm,defaultparams..., width=20cm, title="default", x = [0,1,2,3,4,5],y = [7, 10, 20, 30, 40, 42])

# chr18:80,139,089-80,265,529
plotTracks([gp], "/tmp/dt.pdf", 80139089, 80265529; defaultparams...)


# ---- GenomicFeatureTrack

chrom_ = "chr20"
bpStart_ = 31400000
bpEnd_ = 31550229

gp = GenomicPos(;height=1cm, margin_top = 8mm)

gfs = genes(GTFFile(tabix(GViz.pkgpath("data", "gencode.v35.annotation.gtf.bgz"),
                          chrom_, bpStart_, bpEnd_)))
gt = GenomicFeatureTrack(;features = gfs, title = "Genes", feature_height=5mm, feature_fill = "darkgreen",
                         feature_label_spacing=1mm, feature_label_color = "black")

gt = GeneTrack(chrom_, bpStart_, bpEnd_;)
               title = "Genes",
               feature_height=5mm,
               feature_fill = "darkgreen",
               feature_label_spacing=1mm,
               feature_label_color = "black")

dt = DataTrack(x = range(bpStart_, bpEnd_, length=1000), y = rand(1000),
               ymin = -0.05, ymax = 1.05, ylab = "Intensity", title = "Random data", height=5cm )

plotTracks([gp, dt, gt, gp], "/tmp/dt.pdf", bpStart_, bpEnd_; defaultparams..., width=20cm)


# ---- gorfile

using GorJulia

meth = GorFile(GViz.pkgpath("data", "methylationFraction.gor.tsv");
               first = (chrom_, bpStart_), last = (chrom_, bpEnd_)) |> Tables.columns

mt = DataTrack(x = meth[:Pos], y = meth[:methFrac], ymin=0, ymax = 1, title="Methylation",
               margin_top=0mm, color="red", fill="red", size=1)
plotTracks([gp, mt, gt], "/tmp/dt.pdf", bpStart_, bpEnd_; defaultparams..., width=20cm)


# ---- multiple layer dicts in DataTrack

hmeth = GorFile(GViz.pkgpath("data", "PofO_ASM.gor");
                first = (chrom_, bpStart_), last = (chrom_, bpEnd_)) |> Tables.columns

hmt = DataTrack(x = hmeth[:Pos],
                layers = [Dict(:y => hmeth[:mfrac], :fill => "blue"),
                          Dict(:y => hmeth[:pfrac], :fill => "red")],
                ymin=0, ymax = 1, title="ASM",
                size=1, margin_top=0mm, color="white")

zt = DataTrack(x = hmeth[:Pos], y = -log10.(hmeth[:pval]), ymin=0, ymax = 20, title="ASM -log10(p)",
               size=1, margin_top=0mm, geom = :col, color = "darkblue")

plotTracks([gp, zt,mt, hmt, gt], "/tmp/dt.pdf", bpStart_, bpEnd_; defaultparams..., width=25cm)
