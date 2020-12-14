var documenterSearchIndex = {"docs":
[{"location":"#GViz.jl","page":"Home","title":"GViz.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Purpose","page":"Home","title":"Purpose","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GViz.jl is a julia library to visualize genomic data using tracks. The library is implemented on top of the Cairo vector graphics library.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The user specifies track objects","category":"page"},{"location":"","page":"Home","title":"Home","text":"GenomicAxis\nDataTrack (for x, y data)\nGeneTrack (for genes)","category":"page"},{"location":"","page":"Home","title":"Home","text":"that are plotted to a PDF file using plotTracks.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Internally, each display consists of a number of nested reference frames. Each reference frame has a coordinate system and an environment for parameters.  Both attributes and data are stored in the environment. A child reference frame is mapped onto its parent reference frame using scaling and translation transformations. When trying to look up an attribute in a reference frame's environment that does not exists there, its parents' environments are checked recursively.","category":"page"},{"location":"#Examples","page":"Home","title":"Examples","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using GViz\n\nchrom_ = \"chr20\"\nbpStart_ = 31400000\nbpEnd_ = 31550229\n\ngp = GenomicAxis(;height=1cm, margin_top = 8mm)\ngt = GeneTrack(chrom_, bpStart_, bpEnd_)\ndt = DataTrack(x = range(bpStart_, bpEnd_, length=1000), y = rand(1000),\n               ymin = -0.05, ymax = 1.05, title = \"Random data\", height=5cm )\n\nplotTracks([gp, dt, gt, gp], \"/tmp/test1.pdf\", bpStart_, bpEnd_;\n\t   defaultparams..., width=20cm)","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: )","category":"page"},{"location":"","page":"Home","title":"Home","text":"using GViz\nusing GorJulia\n\nchrom_ = \"chr20\"\nbpStart_ = 31400000\nbpEnd_ = 31550229\n\ngp = GenomicAxis(;height=1cm, margin_top = 8mm)\n\ngt = GeneTrack(chrom_, bpStart_, bpEnd_)\n\nhmeth = GorFile(GViz.pkgpath(\"data\", \"PofO_ASM.gor\");\n                first = (chrom_, bpStart_), last = (chrom_, bpEnd_)) |> Tables.columns\n\nhmt = DataTrack(x = hmeth[:Pos],\n                layers = [Dict(:y => hmeth[:mfrac], :fill => \"blue\"),\n                          Dict(:y => hmeth[:pfrac], :fill => \"red\")],\n                ymin=0, ymax = 1, title=\"ASM\",\n                size=1, margin_top=0mm, color=\"white\")\n\nzt = DataTrack(x = hmeth[:Pos], y = -log10.(hmeth[:pval]),\n               ymin=0, ymax = 20, title=\"ASM -log10(p)\",\n               size=1, margin_top=0mm, geom = :col, color = \"darkblue\")\n\nplotTracks([gp, zt, hmt, gt], \"/tmp/test2.pdf\", bpStart_, bpEnd_; defaultparams..., width=25cm)\n","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: )","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GenomicAxis\nDataTrack\nGeneTrack\nplotTracks","category":"page"},{"location":"#GViz.GenomicAxis","page":"Home","title":"GViz.GenomicAxis","text":"GenomicAxis(;params...)\n\nCreate a genomic axis for the track plots.\n\nParameters\n\n:axis_line_width\n:axis_color\n:axis_font\n:axis_tick_length\n:width width of track\n:height height of track\n:margin_top\n:margin_bottom\n:margin_left\n:margin_right\n\n\n\n\n\n","category":"type"},{"location":"#GViz.DataTrack","page":"Home","title":"GViz.DataTrack","text":"DataTrack(;params...)\n\nCreate a data track consisting of one or multiple layers.\n\nLayer parameters\n\n:x \n:y\n:color\n:fill \n:size \n:linetype\n:alpha\n:shape \n:asterisk\n:circle\n:cross\n:diamond\n:dot\n:plus\n:square\n:triangle\n:down-triangle\n:right-triangle\n:left-triangle\n:geom\n:point\n:line\n:col\n\nIf a single layer is used, the parameters are specified directly. If multiple layers are used, the parameters for each layer are specified in a separate dictionary, and a vector of layer  dictionaries can be supplied as parameter :layers.\n\nTrack parameters\n\nThe following parameters affect the track as a whole\n\n:title track title\n:title_color\n:title_font\n:ymin minimum y-value to plot, or nothing\n:ymax maximum y-value to plot, or nothing\n:axis_line_width\n:axis_color\n:axis_font\n:axis_tick_length\n:base_line_y y-coordinates for horizontal line, or nothing\n:base_line_color\n:base_line_width\n:width width of track\n:height height of track\n:margin_top\n:margin_bottom\n:margin_left\n:margin_right\n\n\n\n\n\n","category":"type"},{"location":"#GViz.GeneTrack","page":"Home","title":"GViz.GeneTrack","text":"GeneTrack(chrom, bpStart, bpEnd; \n          gtf = GViz.pkgpath(\"data\", \"gencode.v35.annotation.gtf.bgz\"),\n          params...)\n\nCreate a track with genes based on GTF file gtf.\n\nParameters\n\n:gtf path to tabix-indexed GTF file with genes\n:feature_label_spacing\n:feature_label_font\n:feature_label_color\n:feature_height\n:feature_fill\n:title track title\n:title_color\n:title_font\n:width width of track\n:height height of track\n:margin_top\n:margin_bottom\n:margin_left\n:margin_right\n\n\n\n\n\n","category":"function"},{"location":"#GViz.plotTracks","page":"Home","title":"GViz.plotTracks","text":"plotTracks(tracks::Vector{T}, path, xmin, xmax;\n                track_spacing = 5mm, params...)\n\nPlot tracks into PDF file at path.\n\n\n\n\n\n","category":"function"}]
}