#----------------------------------------------------------------------
#
# Coordinate transformations
#

# Rectangle at (x, y) with width w and height h
mutable struct Rect
    x::Float64
    y::Float64
    w::Float64
    h::Float64
end

# union of rects = smallest Rect covering rects
function Base.union(r1::Rect, r2::Rect)
    xmin = min(r1.x, r2.x, r1.x + r1.w, r2.x + r2.w)
    xmax = max(r1.x, r2.x, r1.x + r1.w, r2.x + r2.w)
    ymin = min(r1.y, r2.y, r1.y + r1.h, r2.y + r2.h)
    ymax = max(r1.y, r2.y, r1.y + r1.h, r2.y + r2.h)
    Rect(xmin, ymin, xmax - xmin, ymax - ymin)
end


abstract type AbstractTransform end

struct Translation <: AbstractTransform
    x::Float64 # origin of user in device coords
    y::Float64
end

struct Scaling <: AbstractTransform
    from::Rect # device
    to::Rect   # user
end

function user2dev(t::Translation, x, y)
    x .+ t.x, y .+ t.y
end

function dev2user(t::Translation, x, y)
    x .- t.x, y .- t.y
end


function user2dev(s::Scaling, x, y)
    fromx = s.from.x .+ (x .- s.to.x) ./ s.to.w .* s.from.w
    fromy = s.from.y .+ (y .- s.to.y) ./ s.to.h .* s.from.h
    fromx, fromy
end

function dev2user(s::Scaling, x, y)
    tox = s.to.x .+ (x .- s.from.x) ./ s.from.w .* s.to.w
    toy = s.to.y .+ (x .- s.from.y) ./ s.from.h .* s.to.h
    tox, toy
end

#-------------------------------------------------------------
#
# RefFrame
#
# contains transformation into coordinate system
# and environment in `params`
#

abstract type AbstractRefFrame end

struct RefFrame <: AbstractRefFrame
    transform::AbstractTransform
    children::Vector{AbstractRefFrame}
    params::Dict

    function RefFrame(; transform = Translation(0.0, 0.0),
                      children = AbstractRefFrame[],
                      params...)
        new(transform, children, Dict(params))
    end
end


transform(ref::AbstractRefFrame) = ref.transform
params(ref::AbstractRefFrame) = ref.params

# overload coordinate transformations

user2dev(ref::AbstractRefFrame, x, y) = user2dev(transform(ref), x, y)
   
function user2dev(refs::Vector{T}, x, y) where T <: AbstractRefFrame
    for ref::T in reverse(refs)
        x, y = user2dev(ref, x, y)
    end
    x, y
end


function user2dev(ref::AbstractRefFrame, r::Rect)
    x, y = user2dev(transform(ref), [r.x, r.x + r.w], [r.y, r.y + r.h])
    Rect(x[1], y[1], x[2] - x[1], y[2] - y[1])
end


function user2dev(refs::Vector{T}, r::Rect) where T <: AbstractRefFrame
    for ref::T in reverse(refs)
        r = user2dev(ref, r)
    end
    r
end


dev2user(ref::AbstractRefFrame, x, y) = dev2user(transform(ref), x, y)

function dev2user(refs::Vector{T}, x, y) where T <: AbstractRefFrame
    for ref::T in refs
        x, y = dev2user(ref, x, y)
    end
    x, y
end

# resolve parameters along reference frame chain
function getparam(refs::Vector{T}, param, default = nothing; fail = false) where T <: AbstractRefFrame
    for ref::T in reverse(refs)
        if haskey(ref.params, param)
            return ref.params[param]
        end
    end
    fail && error("No such parameter: $param")
    default
end

getparam(ref::AbstractRefFrame, param, default = nothing; fail = false) = getparam([ref], param, default; fail = fail)

