using Distributed
addprocs()
using ProgressMeter

@everywhere function get_hundreds_digit(x::Int64)::Int64
    _x = floor(x/100.0)
    return _x % 10
end

@everywhere function power_at_coordinates(x::Int64,y::Int64,serial_number::Int64)::Int64
    rack_id = x+10
    power_level = rack_id*y
    power_level += serial_number
    power_level *= rack_id
    power_level = get_hundreds_digit(power_level)
    power_level -= 5
    return power_level
end

@everywhere function power_cell_grid(serial_number::Int64)::Array{Int64,2}
    grid = zeros(300,300)
    for x in 1:300
        for y in 1:300
            grid[y,x] = power_at_coordinates(x,y,serial_number)
        end
    end
    return grid
end

@everywhere function find_largest_total_power(serial_number::Int64,square_size::Int64)::Pair{Tuple{Int64,Int64},Int64}
    grid = power_cell_grid(serial_number)
    subgrid_power = Dict()
    for x in 1:301-square_size
        for y in 1:301-square_size
            subgrid = grid[y:y+square_size-1,x:x+square_size-1]
            subgrid_power[(x,y)] = sum(subgrid)
        end
    end
    most_power = sort(collect(subgrid_power), by=x->-x[2])
    return most_power[1]
end

function part_2(serial_number::Int64)
    high_scores = Dict()
    futures = []
    @showprogress for square_size in 1:300
        future = @spawn find_largest_total_power(serial_number,square_size)
        push!(futures, (square_size, future))
    end
    @showprogress for f in futures
        high_scores[f[1]] = fetch(f)
    end
    high_score = sort(collect(high_scores), by=x->-x[2][2][2])
    return high_score[1]
end

part_1 = find_largest_total_power(18,3)
@time part_2(18)
