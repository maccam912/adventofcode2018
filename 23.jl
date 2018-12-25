using ProgressMeter
include("util.jl")
const datafile = "inputs/23.txt"
struct Nanobot
    x::Int64
    y::Int64
    z::Int64
    r::Int64
end

function parse_input()::Array{Nanobot,1}
    lines = getlines(datafile)
    re = r"^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)$"
    nanobots = []
    for line in lines
        matches = match(re, line)
        try
            parts = [parse(Int64, matches[i]) for i in 1:4]
            nanobot = Nanobot(parts...)
            push!(nanobots, nanobot)
        catch
            println(line)
        end
    end
    return nanobots
end

function mdist(x,y,z,x2,y2,z2)::Int64
    return abs(x-x2)+abs(y-y2)+abs(z-z2)
end

function part_1()
    nanobots = parse_input()
    radii = sort(collect(nanobots), by=x->-x.r)
    biggest_radius = radii[1]
    in_range = []
    for nanobot in nanobots
        if mdist(biggest_radius.x, biggest_radius.y, biggest_radius.z,
            nanobot.x, nanobot.y, nanobot.z) <= biggest_radius.r
            push!(in_range, nanobot)
        end
    end
    println(length(in_range))
end

function minmaxxyz(nanobots::Array{Nanobot,1},r::Int64)
    x = []
    y = []
    z = []
    for nanobot in nanobots
        push!(x, nanobot.x)
        push!(y, nanobot.y)
        push!(z, nanobot.z)
    end
    return minimum(x)-r,maximum(x)+r,minimum(y)-r,maximum(y)+r,minimum(z)-r,maximum(z)+r
end

function corners(nb::Nanobot)::Array{Tuple{Int64,Int64,Int64}}
    retval = []
    push!(retval, (nb.x+nb.r,nb.y,nb.z))
    push!(retval, (nb.x-nb.r,nb.y,nb.z))
    push!(retval, (nb.x,nb.y+nb.r,nb.z))
    push!(retval, (nb.x,nb.y-nb.r,nb.z))
    push!(retval, (nb.x,nb.y,nb.z+nb.r))
    push!(retval, (nb.x,nb.y,nb.z-nb.r))
    return retval
end

function get_neighborhood(point::Tuple{Int64,Int64,Int64})::Array{Tuple{Int64,Int64,Int64}}
    retval = []
    for z in -15:15
        for y in -15:15
            for x in -15:15
                push!(retval, (point[1]+x,point[2]+y,point[3]+z))
            end
        end
    end
    return retval
end

function score(x::Int64,y::Int64,z::Int64,nb::Array{Nanobot})::Int64
    s = 0
    for n in nb
        if mdist(x,y,z,n.x,n.y,n.z) <= n.r
            s += 1
        end
    end
    return s
end

function part_2()
    nanobots = parse_input()
    corners_lists = corners.(nanobots)
    corners_list::Array{Tuple{Int64,Int64,Int64}} = []
    for c in corners_lists
        for _c in c
            neighborhood = get_neighborhood(_c)
            for n in neighborhood
                push!(corners_list, n)
            end
        end
    end
    scores = []
    @showprogress for c in corners_list
        push!(scores, (c, score(c[1],c[2],c[3],nanobots)))
    end
    scores_2 = map(x->(mdist(x[1][1],x[1][2],x[1][3],0,0,0),x[1],x[2]), scores)
    sorted = sort(scores_2, by=x->-x[3])
    maxscore = sorted[1][3]
    sorted_2 = sort(filter(x->x[3] == maxscore, sorted), by=x->x[1])
    return sorted_2
end


part_1()
clist = part_2()
