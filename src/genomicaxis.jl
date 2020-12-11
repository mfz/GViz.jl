export GenomicPos,
    GenomicAxis

# ---- Genomic axis --------------------------------------------------------

"""
    GenomicAxis(;params...)


Create a genomic axis for the track plots.

# Parameters

- `:axis_line_width`
- `:axis_color`
- `:axis_font`
- `:axis_tick_length`

- `:width` width of track
- `:height` height of track

- `:margin_top`
- `:margin_bottom`
- `:margin_left`
- `:margin_right`

"""
struct GenomicAxis <: AbstractRefFrame
    # AbstractRefFrame
    transform::AbstractTransform
    children::Vector{AbstractRefFrame}
    params::Dict
    
    function GenomicAxis(;params...)
        new(Translation(0., 0.), AbstractRefFrame[], Dict(params))
    end
end

GenomicPos = GenomicAxis

function draw(cc::Cairo.CairoContext, tc::Vector{T}, gp::GenomicPos, xmin, xmax) where T <: AbstractRefFrame

    width = getparam(tc, :width)
    height = getparam(tc, :height, 1cm)
    
    units = Rect(xmin, 0, xmax - xmin, 1)
    bbox = Rect(getparam(tc, :margin_left),
                getparam(tc, :margin_top),
                width - getparam(tc, :margin_left) - getparam(tc, :margin_right),
                1)

    datactx = RefFrame(transform = Scaling(bbox, units))

    xticks = _ticks_default_linear([xmin, xmax])

    devx, devy = user2dev(vcat(tc, datactx), xticks, repmat([0], length(xticks)))

    axis_line_width = getparam(tc, :axis_line_width)
    Cairo.set_source_rgba(cc, rgba(getparam(tc, :axis_color))...)
    Cairo.set_font_face(cc, getparam(tc, :axis_font))
    Cairo.set_line_width(cc, axis_line_width)
                         
    Cairo.move_to(cc, devx[1] - axis_line_width/2, devy[1])
    Cairo.line_to(cc, devx[end] + axis_line_width/2, devy[end])

    for i in 1:length(devx)
        Cairo.move_to(cc, devx[i], devy[i] - getparam(tc, :axis_tick_length))
        Cairo.line_to(cc, devx[i], devy[i])
        Cairo.text(cc, devx[i], devy[i] - 2*getparam(tc, :axis_tick_length), _format_ticklabel(xticks[i]),
                   halign="center", valign="bottom")
    end

    Cairo.stroke(cc)

    user2dev(gp, Rect(0.0, 0.0, width, height))
end

