using Images, Plots
include("util.jl")

function parse_line(line::String)::Dict{Symbol,UnitRange{Int64}}
    parts = split(line, ", ")
    split_parts = [split(part, "=") for part in parts]
    x = 1:1
    y = 1:1
    for part in split_parts
        if part[1] == "x"
            if occursin("..", part[2])
                sides = split(part[2], "..")
                x = parse(Int64, sides[1]):parse(Int64, sides[2])
            else
                x = parse(Int64, part[2]):parse(Int64,part[2])
            end
        elseif part[1] == "y"
            if occursin("..", part[2])
                sides = split(part[2], "..")
                y = parse(Int64, sides[1]):parse(Int64,sides[2])
            else
                y = parse(Int64, part[2]):parse(Int64,part[2])
            end
        end
    end
    return Dict(:x => x, :y => y)
end

function get_bounds(parsed_lines::Array{Dict{Symbol,UnitRange{Int64}}})::Array{Int64}
    xmin = minimum([minimum(d[:x]) for d in parsed_lines])
    xmax = maximum([maximum(d[:x]) for d in parsed_lines])
    ymin = minimum([minimum(d[:y]) for d in parsed_lines])
    ymax = maximum([maximum(d[:y]) for d in parsed_lines])
    return [xmin-1, xmax+1, ymin, ymax]
end

function make_grid(parsed_lines::Array{Dict{Symbol,UnitRange{Int64}}})::Array{Char,2}
    bounds = get_bounds(parsed_lines)
    grid = map(x->'.', zeros(bounds[4],bounds[2]))
    for line in parsed_lines
        for x in line[:x]
            for y in line[:y]
                grid[y,x] = '#'
            end
        end
    end
    return grid
end

function read_input()
    lines = getlines("inputs/17.txt")
    parsed_lines = parse_line.(lines)
    grid = make_grid(parsed_lines)
    return parsed_lines, grid
end

function hasWall(x::Int64,y::Int64,grid::Array{Char,2},direction::Int64)
    if grid[y,x+direction] == '#' && grid[y+1,x] in "#~"
        return true
    elseif grid[y,x+direction] == '.'
        return false
    elseif grid[y+1,x] in ".|"
        return false
    else
        return hasWall(x+direction,y,grid,direction)
    end
end

function hasBothWalls(x::Int64,y::Int64,grid::Array{Char,2})
    if hasWall(x,y,grid,1) && hasWall(x,y,grid,-1)
        return true
    else
        return false
    end
end

function fillside(x::Int64,y::Int64,grid::Array{Char,2},direction::Int64)
    if grid[y,x] == '#'
        return
    else
        grid[y,x] = '~'
        fillside(x+direction,y,grid,direction)
    end
end

function fillLevel(x::Int64,y::Int64,grid::Array{Char,2})
    fillside(x,y,grid,1)
    fillside(x,y,grid,-1)
end

function ffill(x::Int64,y::Int64,grid::Array{Char,2},bounds::Array{Int64,1})
    #println("plotting")
    #plotgrid(grid)
    #sleep(0.025)
    if y < bounds[4]
        if grid[y+1,x] == '.'
            grid[y+1,x] = '|'
            ffill(x,y+1,grid,bounds)
        end
        if grid[y+1,x] in "~#" && grid[y,x+1] == '.'
            grid[y,x+1] = '|'
            ffill(x+1,y,grid,bounds)
        end
        if grid[y+1,x] in "~#" && grid[y,x-1] == '.'
            grid[y,x-1] = '|'
            ffill(x-1,y,grid,bounds)
        end
        if hasBothWalls(x,y,grid)
            fillLevel(x,y,grid)
        end
    end
    return
end

function color_cell(x::Char)::RGB
    if x == '~'
        return RGB(0,0,1)
    elseif x == '|'
        return RGB(0,0,0.5)
    elseif x == '#'
        return RGB(1,0,0)
    else
        return RGB(1,1,1)
    end
end

function plotgrid(grid)
    plt = plot(color_cell.(grid[1:40,480:520]))
    gui(plt)
end

parsed_lines, grid = read_input()
bounds = get_bounds(parsed_lines)
ffill(500,1,grid,bounds)
i = color_cell.(grid[1:40,480:520])

function part_1()
    count = 0
    for row in 1:size(grid)[1]
        for col in 1:size(grid)[2]
            if grid[row,col] in "~|"
                count += 1
            end
        end
    end
    return count
end

c = part_1()
println(c)

function part_2()
    count = 0
    for row in 1:size(grid)[1]
        for col in 1:size(grid)[2]
            if grid[row,col] in "~"
                count += 1
            end
        end
    end
    return count
end

d = part_2()
println(d)
