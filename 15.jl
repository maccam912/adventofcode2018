abstract type Unit end

mutable struct Goblin <: Unit
    hp::Int64
    ap::Int64
end

mutable struct Elf <: Unit
    hp::Int64
    ap::Int64
end

mutable struct Empty <: Unit end
mutable struct Wall <: Unit end

mutable struct Node{T}
    loc::Tuple{Int64,Int64}
    data::T
    neighbors::Dict{String,Node{T}}
end

mutable struct Graph{T}
    data::Dict{Tuple{Int64,Int64},Node{T}}
    width::Int64
    height::Int64
end

function make_grid()
    f = open("inputs/15_test.txt", "r")
    lines = readlines(f)
    ysize = length(lines)
    xsize = maximum(length.(lines))
    d::Dict{Tuple{Int64,Int64},Node{Unit}} = Dict()
    graph = Graph(d,xsize,ysize)
    for row in 1:ysize
        for col in 1:xsize
            neighbors::Dict{String,Node{Unit}} = Dict()
            newnode = Node((col,row),Empty(),neighbors)
            graph.data[(col,row)] = newnode
            if row > 1
                # connect above
                nodeabove = graph.data[(col,row-1)]
                nodeabove.neighbors["south"] = newnode
                newnode.neighbors["north"] = nodeabove
            end
            if col > 1
                # connect left
                nodeleft = graph.data[(col-1,row)]
                nodeleft.neighbors["east"] = newnode
                newnode.neighbors["west"] = nodeleft
            end
        end
    end
    for y in 1:length(lines)
        for x in 1:length(lines[y])
            c = lines[y][x]
            if c == '#'
                # remove edges
                node = graph.data[(x,y)]
                try
                    n = node.neighbors["north"]
                    delete!(n.neighbors, "south")
                    delete!(node.neighbors, "north")
                catch
                end
                try
                    n = node.neighbors["south"]
                    delete!(n.neighbors, "north")
                    delete!(node.neighbors, "south")
                catch
                end
                try
                    n = node.neighbors["west"]
                    delete!(n.neighbors, "east")
                    delete!(node.neighbors, "west")
                catch
                end
                try
                    n = node.neighbors["east"]
                    delete!(n.neighbors, "west")
                    delete!(node.neighbors, "east")
                catch
                end
                delete!(graph.data, (x,y))
            elseif c == 'G'
                goblin = Goblin(200,3)
                graph.data[(x,y)].data = goblin
            elseif c == 'E'
                elf = Elf(200,3)
                graph.data[(x,y)].data = elf
            end
        end
    end

    return graph
end

function path(currentloc::Tuple{Int64,Int64},visited::Set{Tuple{Int64,Int64}},target::Tuple{Int64,Int64},grid::Graph{Unit})::Array{Tuple{Int64,Int64}}
    options = []
    try
        north = grid.data[currentloc].neighbors["north"]
        if north.loc == target
            return [north.loc]
        elseif !(in(north.loc, visited))
            v2 = copy(visited)
            push!(v2,currentloc)
            push!(vcat([currentloc], path(north.loc, v2, target, grid)), options)
        end
    catch
    end
    try
        west = grid.data[currentloc].neighbors["west"]
        if west.loc == target
            return [west.loc]
        elseif !(in(west.loc, visited))
            v2 = copy(visited)
            push!(v2,currentloc)
            push!(vcat([currentloc], path(west.loc, v2, target, grid)), options)
        end
    catch
    end
    try
        east = grid.data[currentloc].neighbors["east"]
        if east.loc == target
            return [east.loc]
        elseif !(in(east.loc, visited))
            v2 = copy(visited)
            push!(v2,currentloc)
            push!(vcat([currentloc], path(east.loc, v2, target, grid)), options)
        end
    catch
    end
    try
        south = grid.data[currentloc].neighbors["south"]
        if south.loc == target
            return [south.loc]
        elseif !(in(south.loc, visited))
            v2 = copy(visited)
            push!(v2,currentloc)
            push!(vcat([currentloc], path(south.loc, v2, target, grid)), options)
        end
    catch
    end
    shortest = sort(map(x->(length(x),x), options), by=x->x[1])[1]
    return shortest
end

function _empty(x)
    if x == (0,0)
        return true
    else
        return false
    end
end

function update_grid(direction::String,coords::Tuple{Int64,Int64},paths::Array{Tuple{Int64,Int64},2},grid::Graph, target::Tuple{Int64,Int64})
    try
        node = grid.data[coords].neighbors[direction]
        if paths[node.loc...] == (0,0) && (node.loc == target || typeof(grid.data[node.loc...].data) == Empty)
            paths[node.loc...] = coords
            return true
        end
        return false
    catch
        return false
    end
end

function _path(target::Tuple{Int64,Int64},start::Tuple{Int64,Int64},grid::Graph{Unit})
    paths::Array{Tuple{Int64,Int64},2} = map(x->(0,0),zeros(grid.height,grid.width))
    paths[start...] = (-1,-1)
    active = [start]
    while length(active) > 0
        n = active[1]
        deleteat!(active,1)
        for direction in ["west", "north", "south", "east"]
            result = update_grid(direction, n, paths, grid, target)
            if result
                push!(active, grid.data[n].neighbors[direction].loc)
            end
        end
    end
    if paths[target...] == (0,0)
        return []
    end
    retval = []
    push!(retval, target)
    while retval[end] != (-1,-1)
        push!(retval, paths[retval[end]...])
    end
    return retval[2:end-1]
end

function nearest_target(x::Tuple{Int64,Int64},grid::Graph)
    target = Elf
    if typeof(grid.data[x].data) == Elf
        target = Goblin
    end
    println(target)
    targets = []
    for pair in grid.data
        if typeof(pair[2].data) == target
            push!(targets, pair[1])
        end
    end
    paths = [_path(x,y,grid) for y in targets]
    distances = [length(x) for x in paths]
    if length(distances) == 0
        return x
    end
    attack_positions = []
    if minimum(distances) == 1
        # skip move
        return x
    else
        # find closest attack position
        println("closing in")
        for target in targets
            push!(attack_positions, (target[1]+1,target[2]))
            push!(attack_positions, (target[1],target[2]+1))
            push!(attack_positions, (target[1],target[2]-1))
            push!(attack_positions, (target[1]-1,target[2]))
        end
        attack_positions = filter(y->length(_path(x,y,grid)) > 0, attack_positions)
        println(attack_positions)
    end
    closest_distance = minimum(map(y->length(_path(x,y,grid)), attack_positions))
    println(closest_distance)
    positions = filter(y->length(_path(x,y,grid))==closest_distance, attack_positions)
    println(positions)
    if length(positions) == 0
        return x
    end
    position_to_go_to = positions[end]
    return position_to_go_to
end

function move(x::Tuple{Int64,Int64}, grid::Graph)
    println("moving " * string(x))
    nt = nearest_target(x,grid)
    draw_grid(grid)
    if x != nt
        println("Actually moving")
        _p = _path(x,nt,grid)
        println(_p)
        p = _p[1]
        u = grid.data[x].data
        grid.data[p].data = u
        grid.data[x].data = Empty()
    end
    println("...")
    draw_grid(grid)
end

function _get_units(grid::Graph)
    units = []
    for row in 1:grid.height
        for col in 1:grid.width
            try
                n = grid.data[(row,col)]
                if typeof(n.data) == Elf || typeof(n.data) == Goblin
                    push!(units, (row,col))
                end
            catch
            end
        end
    end
    return units
end

function move_units(grid::Graph)
    types_left = Set()
    for unit in _get_units(grid)
        push!(types_left, typeof(grid.data[unit].data))
    end
    if length(collect(types_left)) > 1
        for unit in _get_units(grid)
            move(unit, grid)
        end
    end
end

function draw_grid(grid::Graph)
    retval = ""
    for row in 1:grid.height
        for col in 1:grid.width
            try
                if typeof(grid.data[(row,col)].data) == Wall
                    retval *= '#'
                end
                if typeof(grid.data[(row,col)].data) == Empty
                    retval *= '.'
                end
                if typeof(grid.data[(row,col)].data) == Goblin
                    retval *= 'G'
                end
                if typeof(grid.data[(row,col)].data) == Elf
                    retval *= 'E'
                end
            catch
                retval *= '#'
            end
        end
        retval *= '\n'
    end
    print(retval)
end

grid = make_grid();
move_units(grid)
draw_grid(grid)
