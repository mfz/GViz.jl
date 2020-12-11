import Colors

function rgba(color::AbstractString, alpha::Float64 = 1.0)
    rgb = parse(Colors.RGB{Float64}, color)
    (Colors.red(rgb), Colors.green(rgb), Colors.blue(rgb), alpha)
end

function rgba(color::Colors.Colorant, alpha::Float64 = 1.0)
    convert(Colors.RGB{Float64}, color)
    (Colors.red(rgb), Colors.green(rgb), Colors.blue(rgb), alpha)
end
