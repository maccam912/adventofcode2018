using ProgressMeter, BlackBoxOptim
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

function score()
    nanobots = parse_input()
    return (w) -> begin
        x = round(w[1])
        y = round(w[2])
        z = round(w[3])
        score = 0
        for n in nanobots
            if mdist(x,y,z,n.x,n.y,n.z) <= n.r
                score += 1
            end
        end
        return float(1000-score)+(float(mdist(x,y,z,0,0,0))/848312125.0)
    end
end

nanobots = parse_input()
radii = sort(collect(nanobots), by=x->-x.r)
biggest_radius = radii[1]
minx, maxx, miny, maxy, minz, maxz = minmaxxyz(nanobots, biggest_radius.r)
fitness_func(f) = f[1]+(f[2]/mdist(0,0,0,maxx,maxy,maxz))

function part_2()
    nanobots = parse_input()
    radii = sort(collect(nanobots), by=x->-x.r)
    biggest_radius = radii[1]
    minx, maxx, miny, maxy, minz, maxz = minmaxxyz(nanobots, biggest_radius.r)
    mi = minimum([minx,miny,minz])
    ma = maximum([maxx,maxy,maxz])
    score_func = score()
    res = bboptimize(score_func; Method=:adaptive_de_rand_1_bin_radiuslimited, SearchRange = (float(mi),float(ma)), NumDimensions = 3, MaxTime = 1800.0, PopulationSize=1000)
    return res
end

part_1()
results = part_2()
results
