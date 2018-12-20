function part_1(s)
    directions = Dict('N' => (0, -1), 'S' => (0, 1), 'E' => (1, 0), 'W' => (-1, 1))
    stack = []
    room::Dict{Tuple{Int64,Int64},Set{Tuple{Int64,Int64}}} = Dict()
    current_location = (0,0)
    for c in s
        println(stack)
        if c == '('
            # push current location to stack
            push!(stack, current_location)
        elseif c == ')'
            # go back to location you were at when you saw (
            current_location = pop!(stack)
        elseif c == '|'
            # go back to location with ( but don't pop
            current_location = stack[end]
        else
            delta = directions[c]
            nx = current_location[1] + delta[1]
            ny = current_location[2] + delta[2]
            try
                push!(room[(nx,ny)], current_location) # door from current_loc to next_loc
            catch
                room[(nx,ny)] = Set([current_location])
            end
            current_location = (nx, ny)
        end
    end
    return room
end

function draw_room(room)
    minx = minimum([i[1] for i in keys(room)])
    maxx = maximum([i[1] for i in keys(room)])
    miny = minimum([i[2] for i in keys(room)])
    maxy = maximum([i[2] for i in keys(room)])
    println(minx)
    println(maxx)
    println(miny)
    println(maxy)
    grid::Array{Char,2} = map(x->'?', zeros(1+2*(maxy-miny+1),1+2*(maxx-minx+1)))
    for y in 1:maxy-miny
        for x in 1:maxx-minx
            _y = 2*y
            _x = 2*x
            grid[_y,_x] = '.'
            # if n
            try
                if (minx+x,miny+y-1) in room[(minx+x,miny+y)]
                    grid[_y,_x-1] = '-'
                end
                if (minx+x,miny+y+1) in room[(minx+x,miny+y)]
                    grid[_y,_x+1] = '-'
                end
                if (minx+x-1,miny+y) in room[(minx+x,miny+y)]
                    grid[_y-1,_x] = '|'
                end
                if (minx+x+1,miny+y) in room[(minx+x,miny+y)]
                    grid[_y+1,_x] = '|'
                end
            catch
            end
        end
    end
    grid = map(x-> if x == '?' return '#' else return x end, grid)
    for line in 1:size(grid)[1]
        println(join(grid[line,:]))
    end
    #return grid
end

room = part_1("ENWWW(NEEE|SSE(EE|N))")
draw_room(room)
