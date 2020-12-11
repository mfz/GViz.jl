# adapted from Winston.jl 

# TODO: implement M,k,... prefixes; see http://jkorpela.fi/c/eng.html 


import Base.range

function _magform(x)
    # Given x, returns (a,b), where x = a*10^b [a >= 1., b integral].
    if x == 0
        return 0., 0
    end
    a, b = modf(log10(abs(x)))
    a, b = 10^a, Int(b)
    if a < 1.
        a, b = a * 10, b - 1
    end
    if x < 0.
        a = -a
    end
    return a, b
end

grisu(a,b,c) = ((w,x,y) = Base.Grisu.grisu(a,b,c); (y,Base.Grisu.DIGITS[1:w],x))

function _format_ticklabel(x, range=0.; min_pow10=4)
    if x == 0
        return "0"
    end
    neg, digits, b = grisu(x, Base.Grisu.SHORTEST, Int32(0))
    if length(digits) > 5
        neg, digits, b = grisu(x, Base.Grisu.PRECISION, Int32(6))
        n = length(digits)
        while digits[n] == UInt32('0')
            n -= 1
        end
        digits = digits[1:n]
    end
    b -= 1
    if abs(b) >= min_pow10
        s = IOBuffer()
        if neg write(s, '-') end
        if digits != [0x31]
            write(s, Char(digits[1]))
            if length(digits) > 1
                write(s, '.')
                for i = 2:length(digits)
                    write(s, Char(digits[i]))
                end
            end
            #write(s, "\\times ")
        end
        #write(s, "10^{")
        #write(s, dec(b))
        #write(s, '}')
        write(s, "e")
        write(s, string(b))
        return String(take!(s))
    end
    # XXX: @sprint doesn't implement %.*f
    #if range < 1e-6
    #    a, b = _magform(range)
    #    return @sprintf "%.*f" (abs(b),x)
    #end
    s = sprint(show, x; context = :compact => true)
    endswith(s, ".0") ? s[1:end-2] : s
end

range(a::Real, b::Real) = (a <= b) ? (ceil(Int, a):floor(Int, b)) :
                                     (floor(Int, a):-1:ceil(Int, b))

function _ticklist_linear(lo, hi, sep, origin=0.)
    a = (lo - origin)/sep
    b = (hi - origin)/sep
    [ origin + i*sep for i in range(a,b) ]
end

function _ticks_default_linear(lim)
    a, b = _magform(abs(lim[2] - lim[1])/5.)
    if a < (1 + 2)/2.
        x = 1
    elseif a < (2 + 5)/2.
        x = 2
    elseif a < (5 + 10)/2.
        x = 5
    else
        x = 10
    end

    major_div = x * 10.0^b
    return _ticklist_linear(lim[1], lim[2], major_div)
end

function _ticks_default_log(lim)
    a = log10(lim[1])
    b = log10(lim[2])
    r = range(a, b)
    nn = length(r)

    if nn >= 10
        return 10.0 .^ _ticks_default_linear((a,b))
    elseif nn >= 2
        return 10.0 .^ r
    else
        return _ticks_default_linear(lim)
    end
end

_ticks_num_linear(lim, num) = linspace(lim[1], lim[2], num)
_ticks_num_log(lim, num) = logspace(log10(lim[1]), log10(lim[2]), num)

function _subticks_linear(lim, ticks, num=nothing)
    major_div = abs(ticks[end] - ticks[1])/float(length(ticks) - 1)
    if num === nothing
        _num = 4
        a, b = _magform(major_div)
        if 1. < a < (2 + 5)/2.
            _num = 3
        end
    else
        _num = num
    end
    minor_div = major_div/float(_num+1)
    return _ticklist_linear(lim[1], lim[2], minor_div, ticks[1])
end

function _subticks_log(lim, ticks, num=nothing)
    a = log10(lim[1])
    b = log10(lim[2])
    r = range(a, b)
    nn = length(r)

    if nn >= 10
        return 10.0 .^ _subticks_linear((a,b), map(log10,ticks), num)
    elseif nn >= 2
        minor_ticks = Float64[]
        for i in (minimum(r)-1):maximum(r)
            for j in 1:9
                z = j * 10.0^i
                if (lim[1] <= z <= lim[2]) || (lim[1] >= z >= lim[2])
                    push!(minor_ticks, z)
                end
            end
        end
        return minor_ticks
    else
        return _subticks_linear(lim, ticks, num)
    end
end



