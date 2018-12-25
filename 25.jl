using LightGraphs
include("util.jl")

struct Point
    x::Real
    y::Real
    z::Real
    t::Real
end

function mdist(x::Point,y::Point)::Integer
    return abs(x.x-y.x)+abs(x.y-y.y)+abs(x.z-y.z)+abs(x.t-y.t)
end

function parse_points()::Dict{Integer,Point}
    retval::Dict{Integer,Point} = Dict()
    pointnum = 1
    for line in getlines("inputs/25.txt")
        parts = map(x->parse(Int64,x), split(line, ","))
        retval[pointnum] = Point(parts...)
        pointnum += 1
    end
    return retval
end

function make_graph(points::Dict{Integer,Point})::SimpleGraph
    g = SimpleGraph(length(points))
    for i in 1:length(points)
        p = points[i]
        for j in 1:length(points)
            q = points[j]
            if mdist(p,q) <= 3
                add_edge!(g, i, j)
            end
        end
    end
    return g
end

points = parse_points()
g = make_graph(points)
part_1 = length(connected_components(g))
