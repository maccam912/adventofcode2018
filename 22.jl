using LightGraphs, SimpleWeightedGraphs

const Y_INC = 16807
const X_INC = 48271
const DEPTH = 8103
const TARGET_X = 9
const TARGET_Y = 758
const WIDTH = TARGET_X*20
const HEIGHT = TARGET_Y+40

mutable struct Rescuer
    x::Int64
    y::Int64
    tool::String
end

function print_risks(grid)
    s = ""
    for y in 1:size(grid)[1]
        for x in 1:size(grid)[2]
            if x == 11 && y == 11
                s *= 'X'
            elseif grid[y,x] == 0
                s *= '.'
            elseif grid[y,x] == 1
                s *= '='
            elseif grid[y,x] == 2
                s *= '|'
            end
        end
        s *= '\n'
    end
    println(s)
end

erosion_level(x) = (x+DEPTH) % 20183
risk_level(x) = x % 3

function make_grid()::Array{BigInt,2}
    grid::Array{BigInt,2} = zeros(HEIGHT,WIDTH)
    for y in BigInt(1):BigInt(HEIGHT)
        for x in BigInt(1):BigInt(WIDTH)
            if x == 1 && y == 1
                grid[y,x] = erosion_level(0)
            elseif x == (TARGET_X+1) && y == (TARGET_Y+1)
                grid[y,x] = erosion_level(0)
            elseif y == 1
                grid[y,x] = erosion_level((x-1)*Y_INC)
            elseif x == 1
                grid[y,x] = erosion_level((y-1)*X_INC)
            else
                grid[y,x] = erosion_level(grid[y,x-1]*grid[y-1,x])
            end
        end
    end
    return grid
end

grid = make_grid()
risks = risk_level.(grid)[1:TARGET_Y+1,1:TARGET_X+1]
print_risks(risks)
part_1 = sum(risks)

function make_lookups()
    coords_to_gnode = Dict()
    gnode_to_coords = Dict()
    counter = 1
    for z in 0:2
        for y in 1:HEIGHT
            for x in 1:WIDTH
                coords_to_gnode[(x,y,z)] = counter
                gnode_to_coords[counter] = (x,y,z)
                counter += 1
            end
        end
    end
    return coords_to_gnode, gnode_to_coords
end
coords_to_gnode, gnode_to_coords = make_lookups()

for i in 1:40*40*3
    if coords_to_gnode[gnode_to_coords[i]] != i
        AssertError(i)
    end
end

using ProgressMeter
function simple_graph()
    grid = risk_level.(make_grid())
    g = SimpleWeightedGraph(HEIGHT*WIDTH*3)
    for i in 2:HEIGHT*WIDTH*3
        rem_edge!(g, i-1, i)
        rem_edge!(g, i, i-1)
    end
    @showprogress for y in 1:HEIGHT
        for x in 1:WIDTH
            add_edge!(g, coords_to_gnode[(x,y,0)], coords_to_gnode[(x,y,1)], 7)
            add_edge!(g, coords_to_gnode[(x,y,1)], coords_to_gnode[(x,y,2)], 7)
            add_edge!(g, coords_to_gnode[(x,y,2)], coords_to_gnode[(x,y,0)], 7)
        end
    end
    # 0 = rocky, torch, (climbing)
    # 1 = wet, climbing, (neither)
    # 2 = narrow, neither, (torch)
    @showprogress for y in 1:HEIGHT
        for x in 1:WIDTH
            if x > 1
                # connect left
                _x = x-1
                _y = y
                type_left = grid[_y,_x]
                type_here = grid[y,x]
                if type_left in [0,2] && type_here in [0,2] # torch fine in both
                    add_edge!(g, coords_to_gnode[(_x,_y,0)], coords_to_gnode[(x,y,0)], 1)
                end
                if type_left in [0,1] && type_here in [0,1]
                    add_edge!(g, coords_to_gnode[(_x,_y,1)], coords_to_gnode[(x,y,1)], 1)
                end
                if type_left in [2,1] && type_here in [2,1]
                    add_edge!(g, coords_to_gnode[(_x,_y,2)], coords_to_gnode[(x,y,2)], 1)
                end
            end
            if y > 1
                # connect up
                _x = x
                _y = y-1
                type_up = grid[_y,_x]
                type_here = grid[y,x]
                if type_up in [0,2] && type_here in [0,2] # torch fine in both
                    add_edge!(g, coords_to_gnode[(_x,_y,0)], coords_to_gnode[(x,y,0)], 1)
                end
                if type_up in [0,1] && type_here in [0,1]
                    add_edge!(g, coords_to_gnode[(_x,_y,1)], coords_to_gnode[(x,y,1)], 1)
                end
                if type_up in [2,1] && type_here in [2,1]
                    add_edge!(g, coords_to_gnode[(_x,_y,2)], coords_to_gnode[(x,y,2)], 1)
                end
            end
        end
    end
    return g
end

function part_2()
    grid = risk_level.(make_grid())
    g = simple_graph()
    println("built graph")
    a = coords_to_gnode[(1,1,0)]
    b = coords_to_gnode[(2,1,0)]
    path = enumerate_paths(dijkstra_shortest_paths(g, coords_to_gnode[(1,1,0)]), coords_to_gnode[(TARGET_X+1,TARGET_Y+1,0)])
    #path = a_star(g, coords_to_gnode[(1,1,0)], coords_to_gnode[(TARGET_X+1,TARGET_Y+1,0)])
    for p in path
        x,y,z = gnode_to_coords[p]
        println(grid[y,x])
        if z == 0
            println(string(x) * ", " * string(y) * ": torch")
        elseif z == 1
            println(string(x) * ", " * string(y) * ": climbing")
        elseif z == 2
            println(string(x) * ", " * string(y) * ": neither")
        end
    end
    weights = []
    for step in 2:length(path)
        n1 = path[step-1]
        n2 = path[step]
        w = g.weights[n1,n2]
        push!(weights, w)
    end
    return sum(weights)
end

p2 = part_2()
