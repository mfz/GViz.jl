function geom_point(cc::Cairo.CairoContext, ctxs::Vector{<:AbstractRefFrame})

    x, y = user2dev(ctxs,
                    getparam(ctxs, :x; fail = true),
                    getparam(ctxs, :y; fail = true))

    shape = getparam(ctxs, :shape, "circle")
    color = getparam(ctxs, :color, "black")
    fill = getparam(ctxs, :fill, nothing)
    alpha = getparam(ctxs, :alpha, 1.0)
    size = getparam(ctxs, :size, 2.0)

    points(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray;
           alpha = alpha, color = color, fill = fill, shape = shape, size = size)
end


function geom_line(cc::Cairo.CairoContext, ctxs::Vector{<:AbstractRefFrame})

    x, y = user2dev(ctxs,
                    getparam(ctxs, :x; fail = true),
                    getparam(ctxs, :y; fail = true))

    color = getparam(ctxs, :color, "black")
    alpha = getparam(ctxs, :alpha, 1.0)
    linetype = getparam(ctxs, :linetype, "solid")
    size = getparam(ctxs, :size, 1.0)
    

    lines(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray;
           alpha = alpha, color = color, size = size, linetype = linetype)
end


function geom_col(cc::Cairo.CairoContext, ctxs::Vector{<:AbstractRefFrame})

    x, y = user2dev(ctxs,
                    getparam(ctxs, :x; fail = true),
                    getparam(ctxs, :y; fail = true))

    basex, basey = user2dev(ctxs, 0, 0)
    
    color = getparam(ctxs, :color, "black")
    alpha = getparam(ctxs, :alpha, 1.0)
    linetype = getparam(ctxs, :linetype, "solid")
    size = getparam(ctxs, :size, 1.0)
    

    cols(cc::Cairo.CairoContext, x::AbstractArray, y::AbstractArray, basey;
           alpha = alpha, color = color, size = size, linetype = linetype)
end



const geometry_funcs = Dict(:point => geom_point,
                            :line => geom_line,
                            :col => geom_col)


function geometry(cc::Cairo.CairoContext, ctxs::Vector{<:AbstractRefFrame})
    geom = getparam(ctxs, :geom, :point)
    @assert haskey(geometry_funcs, geom) "Unknown geometry: $geom"
    geometry_funcs[geom](cc, ctxs)
end


