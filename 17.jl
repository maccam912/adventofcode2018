using ProgressMeter, Images, Plots
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

function timestep(grid::Array{Char,2}, movedir::Int64, bounds::Array{Int64})::Int64
    count = 0
    for y in size(grid)[1]:-1:1
        if movedir > 0
            xitr = size(grid)[2]:-1:bounds[1]
        else
            xitr = bounds[1]:size(grid)[2]
        end
        for x in xitr
            if grid[y,x] in ",W"
                count += 1
            end
            if y == size(grid)[1] && grid[y,x] == 'W'
                # Any water on bottom row is gone
                grid[y,x] = ','
            elseif grid[y,x] == 'W' && grid[y+1,x] in ",."
                # Any water with room under it moves down
                grid[y,x] = ','
                grid[y+1,x] = 'W'
            elseif grid[y,x] == 'W' && grid[y,x+movedir] in ",."
                # Any water that can't go down but has room left/right goes there
                if y > 1 && grid[y-1,x+movedir] != 'W'
                    grid[y,x] = ','
                    grid[y,x+movedir] = 'W'
                end
            elseif grid[y,x] == 'W' && grid[y,x-movedir] in ",."
                # Any water that can't go down but has room left/right goes there
                if y > 1 && grid[y-1,x-movedir] != 'W'
                    grid[y,x] = ','
                    grid[y,x-movedir] = 'W'
                end
            end
        end
    end
    if grid[1,500] in ",."
        grid[1,500] = 'W'
    end
    return count
end

function convert_to_color(x::Char)::RGB
    if x == '#'
        return RGB(0.5,0,0)
    elseif x == 'W'
        return RGB(0,0,1)
    elseif x == ','
        return RGB(0,0,0.5)
    else
        return RGB(1,1,1)
    end
end

function part_1(grid::Array{Char,2},bounds::Array{Int64})#::Array{Int64}
    scores::Array{Int64} = []
    l = 10000
    #frames::Array{Array{Char,2}} = []
    @showprogress for i in 1:l
        movedir = rand([-1,1])
        push!(scores, timestep(grid,movedir,bounds))
        #if i % 10 == 0
        #    push!(frames, grid[bounds[3]:bounds[4],bounds[1]:bounds[2]])
        #end
        #println(i[1:13,494:507])
    end
    #return frames, scores
    return scores
end

function convert_frames(frames::Array{Array{Char,2},1})
    output = map(x->RGB(1,1,1),zeros(size(frames[1])...,length(frames)))
    @showprogress for z in 1:length(frames)
        for y in 1:size(frames[1])[2]
            for x in 1:size(frames[1])[1]
                output[x,y,z] = convert_to_color(frames[z][x,y])
            end
        end
    end
    newframes = []
    @showprogress for i in 1:length(frames)
        push!(newframes, output[:,:,i])
    end
    return newframes
end

parsed_lines, grid = read_input()
bounds = get_bounds(parsed_lines)

# run for 1000 timesteps
frames, scores = part_1(grid,bounds)
realscores = part_1(grid,bounds)
plot(realscores)
println(realscores[end])
ff = convert_to_color.(grid)
plot(ff)
_frames = convert_frames(frames)
anim = @animate for f in _frames
    plot(f);
end
gif(anim, "anim.gif", fps=15)

plot(scores)
