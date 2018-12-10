using SparseArrays, StatPlots
include("util.jl")

mutable struct Point
    position::Tuple{Int64,Int64}
    velocity::Tuple{Int64,Int64}
end

function make_sky()::Array{Point}
    points::Array{Point} =  []
    for line in getlines("inputs/10_test.txt")
        m = match(r"position=<\s*(-?\d+),\s*(-?\d+)>\s*velocity=<\s*(-?\d+),\s*(-?\d+)>", line)
        p = Point((parse(Int64,m[1]),parse(Int64,m[2])),(parse(Int64,m[3]),parse(Int64,m[4])))
        push!(points, p)
    end
    return points
end

function make_all_positive(a::Array{Tuple{Int64,Int64}})::Array{Tuple{Int64,Int64}}
    xmin = Inf
    ymin = Inf
    for t in a
        if t[1] < xmin
            xmin = t[1]
        end
        if t[2] < ymin
            ymin = t[2]
        end
    end
    newpoints::Array{Tuple{Int64,Int64}} = []
    for t in a
        push!(newpoints, ((t[1]-xmin)+1, (t[2]-ymin)+1))
    end
    return newpoints
end

function fast_forward_point(p::Point,seconds::Int64)::Tuple{Int64,Int64}
    x = p.position[1] + seconds*p.velocity[1]
    y = p.position[2] + seconds*p.velocity[2]
    return (x,y)
end

function make_grid(a::Array{Tuple{Int64,Int64}})::Array{Int64,2}
    xmax = 0
    ymax = 0
    for t in a
        if t[1] > xmax
            xmax = t[1]
        end
        if t[2] > ymax
            ymax = t[2]
        end
    end
    grid = zeros(ymax,xmax)
    for t in a
        grid[1+ymax-t[2],t[1]] = 1
    end
    return grid
end

function get_sky_at(init::Array{Point}, seconds::Int64)::Array{Tuple{Int64,Int64}}
    newpoints = fast_forward_point.(init, seconds)
    newview = make_all_positive(newpoints)
    return newview
end

function get_size(a::Array{Tuple{Int64,Int64}})::Int64
    xmax = 0
    ymax = 0
    for p in a
        if p[1] > xmax
            xmax = p[1]
        end
        if p[2] > ymax
            ymax = p[2]
        end
    end
    return xmax*ymax
end

function get_message(init::Array{Point})::Array{Int64,2}
    skies = []
    for n in 0:100000
        if n % 1000 == 0
            println(n)
        end
        s = get_sky_at(init, n)
        area = get_size(s)
        push!(skies, (area,s))
    end
    smallest_sky = sort(skies, by=x->x[1])[1]
    return make_grid(smallest_sky[2])
end

sky = make_sky()
message = get_message(sky)
heatmap(message)
