# DataTrack
#

export DataTrack, plotTracks, pdf


"""
    DataTrack(;params...)

Create a data track consisting of one or multiple layers.


# Layer parameters


  - `:x` 
  - `:y`
  - `:color`
  - `:fill` 
  - `:size` 
  - `:linetype`
  - `:alpha`
  - `:shape` 
    - `:asterisk`
    - `:circle`
    - `:cross`
    - `:diamond`
    - `:dot`
    - `:plus`
    - `:square`
    - `:triangle`
    - `:down-triangle`
    - `:right-triangle`
    - `:left-triangle`

  - `:geom`
    - `:point`
    - `:line`
    - `:col`

 
If a single layer is used, the parameters are specified directly.
If multiple layers are used, the parameters for each layer are
specified in a separate dictionary, and a vector of layer 
dictionaries can be supplied as parameter `:layers`.


# Track parameters

The following parameters affect the track as a whole

- `:title` track title
- `:title_color`
- `:title_font`

- `:ymin` minimum y-value to plot, or `nothing`
- `:ymax` maximum y-value to plot, or `nothing`

- `:axis_line_width`
- `:axis_color`
- `:axis_font`
- `:axis_tick_length`

- `:base_line_y` y-coordinates for horizontal line, or `nothing`
- `:base_line_color`
- `:base_line_width`

- `:width` width of track
- `:height` height of track

- `:margin_top`
- `:margin_bottom`
- `:margin_left`
- `:margin_right`

"""
struct DataTrack <: AbstractRefFrame
    # AbstractRefFrame
    transform::AbstractTransform
    children::Vector{AbstractRefFrame}
    params::Dict
    
    function DataTrack(;params...)
        new(Translation(0., 0.), AbstractRefFrame[], Dict(params))
    end
end

"""
    pdf(ref::AbstractRefFrame, path, xmin, xmax; absolute = true)

"""
function pdf(ref::AbstractRefFrame, path, xmin, xmax; absolute = true)
    s = Cairo.CairoRecordingSurface()
    cc = Cairo.CairoContext(s)
    bbox = draw(cc, AbstractRefFrame[ref], ref, xmin, xmax)
    if absolute
        bbox = union(Rect(0,0,0,0), bbox)
    end
    pdfs = Cairo.CairoPDFSurface(path, bbox.w, bbox.h)
    pdfcc = CairoContext(pdfs)
    Cairo.set_source_surface(pdfcc, s, -bbox.x, -bbox.y)
    Cairo.rectangle(pdfcc, 0, 0, bbox.w, bbox.h)
    Cairo.fill(pdfcc)
    Cairo.finish(pdfs)
    Cairo.destroy(pdfcc)
    Cairo.destroy(cc)    
end


"""
    plotTracks(tracks::Vector{T}, path, xmin, xmax;
                    track_spacing = 5mm, params...)

Plot `tracks` into PDF file at `path`.
"""
function plotTracks(tracks::Vector{T}, path, xmin, xmax;
                    track_spacing = 5mm, params...) where T <: AbstractRefFrame

    s = Cairo.CairoRecordingSurface()
    cc = Cairo.CairoContext(s)

    # keep track of union of bounding boxes
    ubbox = nothing
    
    offset = 0.0
    for track in tracks
        ref = RefFrame(transform = Translation(0.0, offset),
                       children = [track]; params...)
        bbox = draw(cc, [ref], ref, xmin, xmax)
        
        offset = offset + bbox.h + track_spacing
        if ubbox == nothing ubbox = bbox end
        ubbox = union(ubbox, bbox)
    end

    pdfs = Cairo.CairoPDFSurface(path, ubbox.w, ubbox.h)
    pdfcc = CairoContext(pdfs)
    Cairo.set_source_surface(pdfcc, s, ubbox.x, ubbox.y)
    Cairo.rectangle(pdfcc, 0, 0, ubbox.w, ubbox.h)
    Cairo.fill(pdfcc)
    Cairo.destroy(pdfcc)
    Cairo.destroy(cc)
    Cairo.finish(pdfs)

end
        
function draw(cc::Cairo.CairoContext, tc::Vector{T}, ref::AbstractRefFrame, xmin, xmax) where T <: AbstractRefFrame
    ubbox = nothing
    for c::AbstractRefFrame in ref.children
        bbox = draw(cc, vcat(tc, c), c, xmin, xmax)
        if ubbox == nothing ubbox = bbox end
        ubbox = union(ubbox, bbox)

        #Cairo.rectangle(cc, bbox.x, bbox.y, bbox.w, bbox.h)
        #Cairo.stroke(cc)
    end
    user2dev(ref, ubbox)
end


# draw y-axis at xpos using ticklabels at tickypos
# tc should include mapping to user coordinates
function yaxis(cc::Cairo.CairoContext, tc::Vector{T}, xpos, tickypos, ticklabels;
               offset = 2mm, label = "") where T <: AbstractRefFrame

    devx, devy = user2dev(tc, repmat([xpos], length(tickypos)), tickypos)
    devx .-= offset
          
    axis_line_width = getparam(tc, :axis_line_width)
    Cairo.set_source_rgba(cc, rgba(getparam(tc, :axis_color))...)
    Cairo.set_font_face(cc, getparam(tc, :axis_font))
    Cairo.set_line_width(cc, axis_line_width)
                         
    Cairo.move_to(cc, devx[1], devy[1] + axis_line_width/2)
    Cairo.line_to(cc, devx[end], devy[end] - axis_line_width/2)

    for i in 1:length(tickypos)
        Cairo.move_to(cc, devx[i] - getparam(tc, :axis_tick_length), devy[i])
        Cairo.line_to(cc, devx[i], devy[i])
        Cairo.text(cc, devx[i] - 2*getparam(tc, :axis_tick_length), devy[i], string(ticklabels[i]),
                   halign="right", valign="center")
    end
    
    Cairo.stroke(cc)
end

# draw baseline at position at env var :base_line_y
function baseline(cc::Cairo.CairoContext, tc::Vector{T}) where T <: AbstractRefFrame
    if getparam(tc, :base_line_y) != nothing
        Cairo.set_source_rgba(cc, rgba(getparam(tc, :base_line_color))...)
        Cairo.set_line_width(cc, getparam(tc, :base_line_width))

        base_line_y = getparam(tc, :base_line_y)
        s = transform(tc[end])
        xmin = s.to.x ##tc[end].units.x
        xmax = s.to.x + s.to.w ##tc[end].units.x + tc[end].units.w
        bl_x, bl_y = user2dev(tc, [xmin, xmax], [base_line_y, base_line_y])

        Cairo.move_to(cc, bl_x[1], bl_y[1])
        Cairo.line_to(cc, bl_x[2], bl_y[2])
        
        Cairo.stroke(cc)
    end   
end



# draw DataTrack
function draw(cc::Cairo.CairoContext, tc::Vector{T}, dt::DataTrack, xmin, xmax) where T <: AbstractRefFrame
    # tc already contains dt as last element
    
    layers = getparam(tc, :layers, params(dt))

    if ~ (typeof(layers) <: AbstractArray)
        layers = [layers]
    end

    # scale
    ymin = getparam(tc, :ymin, nothing)
    ymax = getparam(tc, :ymax, nothing)
    
    ymin == nothing && (ymin = minimum([minimum(getparam(vcat(tc, RefFrame(;l...)), :y)) for l in layers]))
    ymax == nothing && (ymax = maximum([maximum(getparam(vcat(tc, RefFrame(;l...)), :y)) for l in layers]))
    
    xspan = xmax - xmin
    yspan = ymax - ymin

    width = getparam(tc, :width)
    height = getparam(tc, :height)
    
    units = Rect(xmin, ymax, xspan, -yspan)
    bbox = Rect(getparam(tc, :margin_left),
                getparam(tc, :margin_top),
                width - getparam(tc, :margin_left) - getparam(tc, :margin_right),
                height - getparam(tc, :margin_top) - getparam(tc, :margin_bottom))

    datactx = RefFrame(transform = Scaling(bbox, units))

    # Cairo stuff

    # draw baseline
    baseline(cc, vcat(tc, datactx))

    # draw yaxis
    yticks = _ticks_default_linear([ymin, ymax])
    yaxis(cc, vcat(tc, datactx), xmin, yticks, _format_ticklabel.(yticks); offset = 2mm, label = getparam(tc, :ylab, ""))

    # title
    title = getparam(tc, :title, "")
    if title != ""
        Cairo.set_source_rgba(cc, rgba(getparam(tc, :title_color))...)
        Cairo.set_font_face(cc, getparam(tc, :title_font))
        xp, yp = user2dev(tc, 0.0, bbox.h/2)
        Cairo.text(cc, xp, yp, title, halign="center", valign="top", angle = 90.0)
        Cairo.stroke(cc)
    end

    # plot data using CairoRecordingSurface
    s = Cairo.CairoRecordingSurface()
    fcc = Cairo.CairoContext(s)    

    for l in layers
        ctxs = vcat(tc, RefFrame(transform = Scaling(bbox, units); l...))

        # dispatch on geometry
        geometry(fcc, ctxs)

    end
    
    # copy relevant bbox from CairoRecordingSurface
    dbbox = user2dev(tc, bbox)
    Cairo.set_source_surface(cc, s, 0, 0)
    Cairo.rectangle(cc, dbbox.x, dbbox.y, dbbox.w, dbbox.h)
    Cairo.fill(cc)
    Cairo.destroy(fcc)
    Cairo.finish(s)    
 
    user2dev(dt, Rect(0.0, 0.0, width, height))
end
