mutable struct Cart
    x::Int64
    y::Int64
    direction::Char
    next_turn::Char
end

import Base.isless
function isless(cart1::Cart, cart2::Cart)::Bool
    if cart1.y < cart2.y
        return true
    elseif cart1.y == cart2.y
        if cart1.x < cart2.x
            return true
        end
    end
    return false
end

function parse_map()::Tuple{Array{Char,2},Array{Cart,1}}
    lines = []
    for row in readlines(open("inputs/13.txt"))
        push!(lines, row)
    end
    carts = []
    longest_line = maximum(map(x->length(x), lines))
    grid = map(x->' ', zeros(length(lines),longest_line))
    for y in 1:length(lines)
        for x in 1:length(lines[y])
            c = lines[y][x]
            if lines[y][x] == '>'
                cart = Cart(x,y,'E','L')
                c = '-'
                push!(carts, cart)
            elseif lines[y][x] == '<'
                cart = Cart(x,y,'W','L')
                c = '-'
                push!(carts, cart)
            elseif lines[y][x] == 'v'
                cart = Cart(x,y,'S','L')
                c = '|'
                push!(carts, cart)
            elseif lines[y][x] == '^'
                cart = Cart(x,y,'N','L')
                c = '|'
                push!(carts, cart)
            end
            grid[y,x] = c
        end
    end
    return (grid, carts)
end

function check_for_crashes(grid, carts)
    occupied_coords = Set()
    for cart in carts
        if in((cart.x, cart.y), occupied_coords)
            return (true, cart.x-1, cart.y-1)
        end
        push!(occupied_coords, (cart.x, cart.y))
    end
    return (false, 0, 0)
end

function remove_crashed_carts(grid, carts)
    coords = [(cart.x, cart.y) for cart in carts]
    u = unique(coords)
    d=Dict([(i,count(x->x==i,coords)) for i in u])
    crashpoints = filter(x->x[2] > 1, collect(d))
    for point in crashpoints
        deleted = 0
        for cart in length(carts):-1:1
            if (carts[cart].x, carts[cart].y) == point[1]
                println(carts[cart])
                deleteat!(carts,cart)
                deleted += 1
            end
        end
        @assert deleted == 2
    end
end

function move_cart(grid::Array{Char,2}, cart::Cart)
    straight_track = '|'
    curve_right = '/'
    right_turn_new_dir = 'E'
    curve_left = '\\'
    left_turn_new_dir = 'W'
    next_x = cart.x
    next_y = cart.y-1

    if cart.direction == 'S'
        straight_track = '|'
        curve_right = '/'
        right_turn_new_dir = 'W'
        curve_left = '\\'
        left_turn_new_dir = 'E'
        next_x = cart.x
        next_y = cart.y+1
    elseif cart.direction == 'W'
        straight_track = '-'
        curve_right = '\\'
        right_turn_new_dir = 'N'
        curve_left = '/'
        left_turn_new_dir = 'S'
        next_x = cart.x-1
        next_y = cart.y
    elseif cart.direction == 'E'
        straight_track = '-'
        curve_right = '\\'
        right_turn_new_dir = 'S'
        curve_left = '/'
        left_turn_new_dir = 'N'
        next_x = cart.x+1
        next_y = cart.y
    end

    if grid[next_y,next_x] == straight_track
        cart.x = next_x
        cart.y = next_y
    elseif grid[next_y,next_x] == curve_right
        cart.x = next_x
        cart.y = next_y
        cart.direction = right_turn_new_dir
    elseif grid[next_y,next_x] == curve_left
        cart.x = next_x
        cart.y = next_y
        cart.direction = left_turn_new_dir
    elseif grid[next_y,next_x] == '+'
        cart.x = next_x
        cart.y = next_y
        if cart.next_turn == 'L'
            cart.direction = left_turn_new_dir
            cart.next_turn = 'S'
        elseif cart.next_turn == 'R'
            cart.direction = right_turn_new_dir
            cart.next_turn = 'L'
        elseif cart.next_turn == 'S'
            cart.direction = cart.direction
            cart.next_turn = 'R'
        end
    end
end

function run_tick(grid, carts)
    sorted_carts = sort(carts)
    for cart in sorted_carts
        result = move_cart(grid, cart)
        sorted_carts = sort(carts)
        remove_crashed_carts(aocmap...)
    end
    return check_for_crashes(grid,carts)
end

aocmap = parse_map()

while true
    crashes = run_tick(aocmap...)
    if crashes[1]
        println(crashes)
        break
    end
end

remove_crashed_carts(aocmap...)

run_tick(aocmap...)
