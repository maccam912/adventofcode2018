using ProgressMeter, Plots
include("util.jl")
const N = 50+2

import Base.zero
function zero(::Type{Char})::Char
    return '.'
end

function setup()::Array{Char,2}
    lines = getlines("inputs/18.txt")
    retval = zeros(Char,N,N)
    for lnum=1:length(lines)
        for cnum=1:length(lines[lnum])
            retval[lnum+1,cnum+1] = lines[lnum][cnum]
        end
    end
    return retval
end

function localstep(smallgrid::Array{Char,2})::Char
    if smallgrid[2,2] == '.'
        numtrees = 0
        for cell in smallgrid
            if cell == '|'
                numtrees += 1
            end
        end
        if numtrees >= 3
            return '|'
        else
            return '.'
        end
    elseif smallgrid[2,2] == '|'
        numlumberyards = 0
        for cell in smallgrid
            if cell == '#'
                numlumberyards += 1
            end
        end
        if numlumberyards >= 3
            return '#'
        else
            return '|'
        end
    elseif smallgrid[2,2] == '#'
        numlumberyards = 0
        numtrees = 0
        for cell in smallgrid
            if cell == '#'
                numlumberyards += 1
            elseif cell == '|'
                numtrees += 1
            end
        end
        if numlumberyards >= 2 && numtrees >= 1
            return '#'
        else
            return '.'
        end
    end
end

function timestep(grid::Array{Char,2})::Array{Char,2}
    retval = zeros(Char,N,N)
    @sync for col in 2:N-1
        @async for row in 2:N-1
            smallgrid = grid[row-1:row+1,col-1:col+1]
            retval[row,col] = localstep(smallgrid)
        end
    end
    return retval
end

function print_grid(grid)
    s = ""
    for row in 2:N-1
        s *= join(grid[row,2:N-1])
        s *= "\n"
    end
    println(s)
end

function run_10_mins(grid)
    for i in 1:10
        grid = timestep(grid)
        print_grid(grid)
    end
    return grid
end

function num_char(grid, char)::Int64
    c = 0
    for x in grid
        if x == char
            c += 1
        end
    end
    return c
end

function part_1(grid)::Int64
    numwood = num_char(grid, '|')
    numlumber = num_char(grid, '#')
    #println(numwood)
    #println(numlumber)
    return numwood*numlumber
end

function get_scores(grid)
    scores = []
    @showprogress for i in 1:10000
        grid = timestep(grid)
        push!(scores, part_1(grid))
    end
    return scores
end

grid = setup()

scores = get_scores(grid)
part_1(grid)

cycle = scores[5013:5040]
function get_cycle_data()
    data = []
    for d in 1:300
        data = vcat(data, cycle)
    end
    return data
end
data = get_cycle_data()
plot(scores[5000:5100])
plot!(data[5000:5100])

function get_value_at(x::Int64, cycle)
    _x = x % length(cycle)
    return cycle[_x]
end

function part_2(cycle)
    return get_value_at(1000000000, cycle)
end

println(part_2(cycle))
