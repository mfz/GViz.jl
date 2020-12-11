# adapted from Winston.jl

using Cairo

# function to draw marker symbols

const symbol_funcs = Dict(
    "asterisk" => (c, x, y, r) -> (
        move_to(c, x, y+r);
        line_to(c, x, y-r);
        move_to(c, x+0.866r, y-0.5r);
        line_to(c, x-0.866r, y+0.5r);
        move_to(c, x+0.866r, y+0.5r);
        line_to(c, x-0.866r, y-0.5r)
    ),
    "circle" => (c, x, y, r) -> (
        new_sub_path(c);
        circle(c, x, y, r)
    ),
    "cross" => (c, x, y, r) -> (
        move_to(c, x+r, y+r);
        line_to(c, x-r, y-r);
        move_to(c, x+r, y-r);
        line_to(c, x-r, y+r)
    ),
    "diamond" => (c, x, y, r) -> (
        move_to(c, x, y+r);
        line_to(c, x+r, y);
        line_to(c, x, y-r);
        line_to(c, x-r, y);
        close_path(c)
    ),
    "dot" => (c, x, y, r) -> (
        new_sub_path(c);
        rectangle(c, x-r, y-r, 2r, 2r)
    ),
    "plus" => (c, x, y, r) -> (
        move_to(c, x+r, y);
        line_to(c, x-r, y);
        move_to(c, x, y+r);
        line_to(c, x, y-r)
    ),
    "square" => (c, x, y, r) -> (
        new_sub_path(c);
        rectangle(c, x-0.866r, y-0.866r, 1.732r, 1.732r)
    ),
    "triangle" => (c, x, y, r) -> (
        move_to(c, x, y+r);
        line_to(c, x+0.866r, y-0.5r);
        line_to(c, x-0.866r, y-0.5r);
        close_path(c)
    ),
    "down-triangle" => (c, x, y, r) -> (
        move_to(c, x, y-r);
        line_to(c, x+0.866r, y+0.5r);
        line_to(c, x-0.866r, y+0.5r);
        close_path(c)
    ),
    "right-triangle" => (c, x, y, r) -> (
        move_to(c, x+r, y);
        line_to(c, x-0.5r, y+0.866r);
        line_to(c, x-0.5r, y-0.866r);
        close_path(c)
    ),
    "left-triangle" => (c, x, y, r) -> (
        move_to(c, x-r, y);
        line_to(c, x+0.5r, y+0.866r);
        line_to(c, x+0.5r, y-0.866r);
        close_path(c)
    ),
)

# function symbols(cc::Cairo.CairoContext, x, y;
#                  kind = "circle", size = 1, line_width = 0.1,
#                  line_rgba = (0,0,0,1), fill_rgba = nothing)
    
#     symbol_func = get(symbol_funcs, kind, "circle")
    
#     Cairo.save(cc)
#     Cairo.set_line_width(cc, line_width)
#     Cairo.set_dash(cc, Float64[])
#     Cairo.new_path(cc)
#     for i = 1:min(length(x),length(y))
#         symbol_func(cc, x[i], y[i], size)
#     end
#     if fill_rgba != nothing
#         Cairo.set_source_rgba(cc, fill_rgba...)
#         Cairo.fill_preserve(cc)
#     end
#     Cairo.set_source_rgba(cc, line_rgba...)
#     Cairo.stroke(cc)
#     Cairo.restore(cc)
# end


# function curve(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray;
#                line_width = 1,
#                line_rgba = (0,0,0,1))
    
#     n = min(length(x), length(y))
#     n > 0 || return

#     Cairo.save(cc)
#     Cairo.set_line_width(cc, line_width)
#     Cairo.set_source_rgba(cc, line_rgba...)
#     new_path(cc)

#     lo = 1
#     while lo < n
#         while lo <= n && !(isfinite(x[lo]) && isfinite(y[lo]))
#             lo += 1
#         end

#         hi = lo + 1
#         while hi <= n &&  (isfinite(x[hi]) && isfinite(y[hi]))
#             hi += 1
#         end
#         hi -= 1

#         if lo < hi
#             Cairo.move_to(cc, x[lo], y[lo])
#             for i = (lo+1):hi
#                 Cairo.line_to(cc, x[i], y[i])
#                 if i < hi && (i & 127) == 0
#                     Cairo.stroke(cc)
#                     Cairo.move_to(cc, x[i], y[i])
#                 end
#             end
#             Cairo.stroke(cc)
#         end

#         lo = hi + 1
#     end
#     Cairo.restore(cc)
# end


# function bars(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray;
#               line_width = 1,
#               line_rgba = (0,0,0,1))

#     Cairo.save(cc)
#     Cairo.set_line_width(cc, line_width)
#     Cairo.set_source_rgba(cc, line_rgba...)
#     new_path(cc)
    
#     for i = 1:min(length(x),length(y))
#         Cairo.move_to(cc, x[i], 0)
#         Cairo.line_to(cc, x[i], y[i])
#     end

#     Cairo.stroke(cc)
#     Cairo.restore(cc)
# end  


# ---- implement layer geometries

function points(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray;
                alpha = 1.0, color = "black", fill = "red", shape = "circle", size = 2, linewidth = 0.1)

    @assert length(x) == length(y) "x and y must be of same length: $(length(x)) != $(length(y))"
    #info("points: x = $x, y = $y")
    alphas = along(alpha, x)
    colors = along(color, x)
    fills = along(fill, x)
    shapes = along(shape, x)
    sizes = along(size, x)
    #info("fills = $fills")
    Cairo.save(cc)
    Cairo.set_line_width(cc, linewidth)
    Cairo.set_dash(cc, Float64[])
    Cairo.new_path(cc)
    
    for i = 1:length(x)
        symbol_funcs[shapes[i]](cc, x[i], y[i], sizes[i])
        if fills[i] != nothing
            Cairo.set_source_rgba(cc, rgba(fills[i], alphas[i])...)
            Cairo.fill_preserve(cc)
        end
        Cairo.set_source_rgba(cc, rgba(colors[i], alphas[i])...)
        Cairo.stroke(cc)
    end
    Cairo.restore(cc)
    
end


function lines(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray;
               alpha = 1.0, color = "black", linetype = "dash", size = 0.1)

    @assert length(x) == length(y) "x and y must be of same length: $(length(x)) != $(length(y))"    
    n = length(x)

    Cairo.save(cc)
    Cairo.set_line_width(cc, size)
    Cairo.set_source_rgba(cc, rgba(color, alpha)...)
    Cairo.set_line_type(cc, linetype)
    
    new_path(cc)

    lo = 1
    while lo < n
        while lo <= n && !(isfinite(x[lo]) && isfinite(y[lo]))
            lo += 1
        end

        hi = lo + 1
        while hi <= n &&  (isfinite(x[hi]) && isfinite(y[hi]))
            hi += 1
        end
        hi -= 1

        if lo < hi
            Cairo.move_to(cc, x[lo], y[lo])
            for i = (lo+1):hi
                Cairo.line_to(cc, x[i], y[i])
                if i < hi && (i & 127) == 0
                    Cairo.stroke(cc)
                    Cairo.move_to(cc, x[i], y[i])
                end
            end
            Cairo.stroke(cc)
        end

        lo = hi + 1
    end
    Cairo.restore(cc)
end



function cols(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray, basey;
              alpha = 1.0, color = "black", linetype = "dash", size = 0.1)

    @assert length(x) == length(y) "x and y must be of same length: $(length(x)) != $(length(y))"
    alphas = along(alpha, x)
    colors = along(color, x)
    linetypes = along(linetype, x)
    sizes = along(size, x)
    
    Cairo.save(cc)
    new_path(cc)
    
    for i = 1:length(x)
        Cairo.set_source_rgba(cc, rgba(colors[i], alphas[i])...)
        Cairo.set_line_width(cc, sizes[i])
        Cairo.set_line_type(cc, linetypes[i])
        Cairo.move_to(cc, x[i], basey)
        Cairo.line_to(cc, x[i], y[i])
        Cairo.stroke(cc)
    end
    
    Cairo.restore(cc)
    
end



function along(x, y::AbstractArray)
    if ~(typeof(x) <: AbstractArray)
        return [x for i in 1:length(y)]
    else
        @assert length(x) == length(y) "arrays of incompatible length"
        x
    end
end



