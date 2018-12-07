include("util.jl")

lines = getlines("inputs/6.txt")

function maxnum()::Int64
    maxnum = 0
    for line in lines
        for num in split(line, ",")
            maxnum = max(maxnum,parse(Int64,num))
        end
    end
    return maxnum
end

const FULL = maxnum()*4
const HALF = floor(maxnum()*2)

function get_coords(lines)::Dict{Symbol,Tuple{Int64,Int64}}
    retval = Dict()
    for line in 1:length(lines)
        coords = split(lines[line], ",")
        x = parse(Int64,coords[1])+HALF
        y = parse(Int64,coords[2])+HALF
        retval[Symbol(line)] = (x,y)
    end
    return retval
end

function closest(x::Int64, y::Int64, coords::Dict{Symbol,Tuple{Int64,Int64}})::Symbol
    distances::Dict{Symbol,Int64} = Dict()
    for s in keys(coords)
        distance = abs(x-coords[s][1])+abs(y-coords[s][2])
        distances[s] = distance
    end
    shortest = sort(collect(distances), by=x->x[2])
    if shortest[1][2] == shortest[2][2]
        return Symbol(".")
    else
        return shortest[1][1]
    end
end

function get_grid(coords::Dict{Symbol,Tuple{Int64,Int64}})::Array{Symbol,2}
    grid::Array{Symbol,2} = map(x -> Symbol("."), zeros(FULL,FULL))
    for i in 1:FULL
        for j in 1:FULL
            grid[j,i] = closest(i,j,coords)
        end
    end
    return grid
end

function total_distance(x::Int64,y::Int64,coords::Dict{Symbol,Tuple{Int64,Int64}})::Int64
    distances = []
    for p in coords
        d = abs(x-p[2][1])+abs(y-p[2][2])
        push!(distances, d)
    end
    return sum(distances)
end

function part_2_region_size(coords::Dict{Symbol,Tuple{Int64,Int64}})
    grid = zeros(FULL,FULL)
    for i in 1:FULL
        for j in 1:FULL
            td = total_distance(i,j,coords)
            if td < 10000
                grid[i,j] = 1
            end
        end
    end
    return grid
end

function largest_area(grid::Array{Symbol,2})
    is::Set{Symbol} = Set([Symbol(".")])
    is = union(is, Set(grid[1,:]))
    is = union(is, Set(grid[FULL,:]))
    is = union(is, Set(grid[:,1]))
    is = union(is, Set(grid[:,FULL]))
    legal = setdiff(Set(grid),is)
    sizes = []
    for s in legal
        g = map(x -> begin
            if x == s
                1
            else
                0
            end
        end, grid)
        push!(sizes, sum(g))
    end
    return sizes
end

coords = get_coords(lines)
grid = get_grid(coords)
a = largest_area(grid)
maximum(a)
sum(part_2_region_size(coords))
