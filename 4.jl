using Dates
include("util.jl")

lines = getlines("inputs/4.txt")

function get_minute(line)
    m = match(r"^\[\d+-\d+-\d+ \d+:(\d+)\]", line)
    return parse(Int64, m[1])
end

function parse_guard_records(lines)
    m = match(r"^.*Guard #(\d+) begins shift$", lines[1])
    id = m[1]
    asleep::Array{Bool} = []
    curr_minute = 0
    for line in lines[2:end]
        if occursin("falls asleep", line)
            m = get_minute(line)
            for _ in curr_minute:m-1
                push!(asleep, false)
            end
            curr_minute = m
        elseif occursin("wakes up", line)
            m = get_minute(line)
            for _ in curr_minute:m-1
                push!(asleep, true)
            end
            curr_minute = m
        end
    end
    for _ in curr_minute:59
        push!(asleep, false)
    end
    return (parse(Int64, id), asleep)
end

function parse_lines(lines)
    lines = order_lines(lines)
    guard_info = [lines[1]]
    records = []
    for line in lines[2:end]
        if occursin("begins shift", line)
            push!(records, parse_guard_records(guard_info))
            guard_info = [line]
        else
            push!(guard_info, line)
        end
    end
    push!(records, parse_guard_records(guard_info))
    return records
end

function order_lines(lines)
    lines_dict::Dict{DateTime, String} = Dict()
    for line in lines
        pattern = "[yyyy-mm-dd HH:MM"
        datepart = split(line, "] ")[1]
        date = Dates.DateTime(datepart, pattern)
        lines_dict[date] = line
    end
    return [i[2] for i in sort(collect(lines_dict), by=x -> x[1])]
end

function time_asleep_fn(arr::Array{Bool})::Int64
    x = map(x -> begin
        if x
            return 1
        else
            return 0
        end
    end, arr)
    return sum(x)
end

function guard_asleep_at_minute_n(guard_id::Int64, results)
    guard_records = filter(x -> x[1]==guard_id, results)
    days_asleep_at_minute = zeros(60)
    for record in guard_records
        for minute in 0:59
            if record[2][minute+1]
                days_asleep_at_minute[minute+1] += 1
            end
        end
    end
    return (maximum(days_asleep_at_minute), guard_id, argmax(days_asleep_at_minute)-1)
end


function part_1(results)
    time_asleep::Dict{Int64,Int64} = Dict()
    for guard in results
        time_asleep[guard[1]] = 0
    end

    for result in results
        time_asleep[result[1]] += time_asleep_fn(result[2])
    end

    guard_asleep_most = sort(collect(time_asleep), by=x->-x[2])[1][1]

    guard_records = filter(x -> x[1]==guard_asleep_most, results)
    days_asleep_at_minute = zeros(60)
    for record in guard_records
        for minute in 0:59
            if record[2][minute+1]
                days_asleep_at_minute[minute+1] += 1
            end
        end
    end
    return guard_asleep_most*(argmax(days_asleep_at_minute)-1)
end

function part_2(results)
    part_2_results = []
    for guard_id in Set([r[1] for r in results])
        push!(part_2_results, guard_asleep_at_minute_n(guard_id, results))
    end
    a = sort(collect(part_2_results), by=x->-x[1])
    return a[1][2]*a[1][3]
end

results = parse_lines(lines)
time_asleep_list = part_1(results)
part_2(results)
