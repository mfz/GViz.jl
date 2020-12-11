export GenomicFeatureTrack, GeneTrack


import DataStructures: heappush!, heappop!



#-----------------------------------------------------------------------------------------------
#
# GenomicFeatureTrack
#

# GenomicFeatures (passed in :features) are organized into lanes of height :lane_height
#
# The GenomicFeatureTrack assigns a lane to each feature,
# and calls drawFeature(cc, tc, feature, lane).
# drawFeature is supposed to draw the feature at y-positions lane-0.5 .. lane + 0.5



"""
    GenomicFeatureTrack(;params...)

GenomicFeatures (passed in :features) assigns each feature to a lane. 
Currently only plotting of genes is implemented.


# Parameters

- `:features` Vector of genomic features to plot
- `:feature_label_spacing`
- `:feature_label_font`
- `:feature_label_color`
- `:feature_height`
- `:feature_fill`

- `:title` track title
- `:title_color`
- `:title_font`

- `:width` width of track
- `:height` height of track

- `:margin_top`
- `:margin_bottom`
- `:margin_left`
- `:margin_right`


# TODO

Change this, such that we can pass in all genomic features with
methods (instead of AbstractGenomicFeatures)

- `bpStart`
- `bpEnd`
- `strand`
- `name`

and also `drawFeature(cc, tc, feature, lane)`

"""
struct GenomicFeatureTrack <: AbstractRefFrame
    # AbstractRefFrame
    transform::AbstractTransform
    children::Vector{AbstractRefFrame}
    params::Dict
    
    function GenomicFeatureTrack(;params...)
        new(Translation(0., 0.), AbstractRefFrame[], Dict(params))
    end
end 


function draw(cc::Cairo.CairoContext, tc::Vector{T}, gt::GenomicFeatureTrack, xmin, xmax) where T <: AbstractRefFrame

    # this is supposed to compute the height of bbox from the number of lanes required
    
    gfs = getparam(tc, :features)
    sort!(gfs)

    # determine tracks
    
    # user coords are not yet set here
    # compute scale for user coords / device coords
    # here we assume that only translations are used going to root window
    scale = (xmax - xmin) / (getparam(tc, :width) - getparam(tc, :margin_left) - getparam(tc, :margin_right))

    heap = []
    maxtrack = 0
    track = 0
    tracks = Int64[]

    # specify font to be used such that we can determine extent of labels
    Cairo.set_font_face(cc, getparam(tc, :feature_label_font, "SansSerif 6"))

    # could use duck typing instead of requiring AbstractGenomicFeature
    # use function barrier for speed if needed
    for gf::AbstractGenomicFeature in gfs
        label = name(gf)
        if strand(gf) == '+' label = label * ">" end
        if strand(gf) == '-' label = "<" * label end
        labelwidth = textwidth(cc, label) * scale # label width in user coords
        if length(heap) == 0
            track = 1
        elseif heap[1][1] < (bpStart(gf) - labelwidth - getparam(tc, :feature_label_spacing, 0mm)*scale)
            track = heap[1][2]
            heappop!(heap)
        else
            track = length(heap) + 1
        end
        heappush!(heap, (bpEnd(gf), track))

        if track > maxtrack
            maxtrack = track
        end

        push!(tracks, track)
    end

    # now tracks[i] contains track for feature gfs[i]

    # set up scaling
    lane_height = getparam(tc, :feature_height, 6mm)
    width = getparam(tc, :width)
    height = lane_height * maxtrack
       
    bbox = Rect(getparam(tc, :margin_left),
                getparam(tc, :margin_top),
                width - getparam(tc, :margin_left) - getparam(tc, :margin_right),
                height - getparam(tc, :margin_top) - getparam(tc, :margin_bottom))
    units = Rect(xmin, 0.5, xmax - xmin, maxtrack)
    datactx = RefFrame(transform = Scaling(bbox, units))

    # Cairo stuff
    # title
    title = getparam(tc, :title, "")
    if title != ""
        Cairo.set_source_rgba(cc, rgba(getparam(tc, :title_color))...)
        Cairo.set_font_face(cc, getparam(tc, :title_font))
        xp, yp = user2dev(tc, 0.0, bbox.h/2)
        Cairo.text(cc, xp, yp, title, halign="center", valign="top", angle = 90.0)
        Cairo.stroke(cc)
    end

    # features
    # do this on CairoRecordingsurface, then copy
    s = Cairo.CairoRecordingSurface()
    fcc = Cairo.CairoContext(s)
    
    feature_rgba = rgba(getparam(tc, :feature_fill, "light blue"), 1.0)
    feature_label_font = getparam(tc, :feature_label_font)
    feature_label_rgba = rgba(getparam(tc, :feature_label_color, "light grey"))
    feature_label_spacing = getparam(tc, :feature_label_spacing, 0mm)
    
    
    for (gf::AbstractGenomicFeature, lane) in zip(gfs, tracks)

        xp, yp = user2dev(vcat(tc, datactx), [bpStart(gf), bpEnd(gf)], [lane, lane])
        
        Cairo.set_font_face(fcc, feature_label_font)
        Cairo.set_source_rgba(fcc, feature_label_rgba...)
        label = name(gf)
        if strand(gf) == '+' label = label * ">" end
        if strand(gf) == '-' label = "<" * label end
        Cairo.text(fcc, xp[1] - feature_label_spacing, (yp[1] + yp[2])/2, label, halign="right", valign="center")
        Cairo.stroke(fcc)

        # test textextent
        #labelwidth = textwidth(cc, label) * scale
        #Cairo.save(cc)
        #Cairo.set_source_rgba(cc, 0.5, 0.5, 0.5, 0.3)
        #myx, myy = user2dev(vcat(tc, datactx), [bpStart(gf) - labelwidth, bpStart(gf)], [lane - 0.5, lane + 0.5])
        #Cairo.rectangle(cc, myx[1] - feature_label_spacing, myy[1], myx[2] - myx[1], myy[2] - myy[1])
        #Cairo.fill(cc)
        #Cairo.restore(cc)
        
        Cairo.set_source_rgba(fcc, feature_rgba...)
        Cairo.set_line_width(fcc, 1)
        Cairo.move_to(fcc, xp[1], yp[1])
        Cairo.line_to(fcc, xp[2], yp[2])
        Cairo.stroke(fcc)

        coding, noncoding = cdss(gf), exons(gf)
        for (start, stop) in coding
            xp, yp = user2dev(vcat(tc, datactx), [start, stop], [lane - 0.45, lane + 0.45])
            Cairo.rectangle(fcc, xp[1], yp[1], xp[2] - xp[1], yp[2] - yp[1])
        end
        for (start, stop) in noncoding
            xp, yp = user2dev(vcat(tc, datactx), [start, stop], [lane - 0.25, lane + 0.25])
            Cairo.rectangle(fcc, xp[1], yp[1], xp[2] - xp[1], yp[2] - yp[1])
        end        
        Cairo.fill(fcc) 
        
    end

    # copy relevant bbox from CairoRecordingSurface
    dbbox = user2dev(tc, bbox)
    Cairo.set_source_surface(cc, s, 0, 0)
    Cairo.rectangle(cc, dbbox.x, dbbox.y, dbbox.w, dbbox.h)
    Cairo.fill(cc)
    Cairo.destroy(fcc)
    Cairo.finish(s)
    
    user2dev(gt, Rect(0.0, 0.0, width, height))    
end

"""
    GeneTrack(chrom, bpStart, bpEnd; 
              gtf = GViz.pkgpath("data", "gencode.v35.annotation.gtf.bgz"),
              params...)

Create a track with genes based on GTF file `gtf`.


# Parameters

- `:gtf` path to tabix-indexed GTF file with genes

- `:feature_label_spacing`
- `:feature_label_font`
- `:feature_label_color`
- `:feature_height`
- `:feature_fill`

- `:title` track title
- `:title_color`
- `:title_font`

- `:width` width of track
- `:height` height of track

- `:margin_top`
- `:margin_bottom`
- `:margin_left`
- `:margin_right`


"""
GeneTrack(chrom, bpStart, bpEnd;
          gtf = GViz.pkgpath("data", "gencode.v35.annotation.gtf.bgz"),
          title = "Genes",
          params...) =
              GenomicFeatureTrack(;features = genes(GTFFile(tabix(gtf, chrom, bpStart, bpEnd))),
                                  title = title,
                                  params...)


