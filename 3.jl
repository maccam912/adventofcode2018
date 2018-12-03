include("util.jl")

lines = getlines("inputs/3.txt")

function line_parser(line)
    (id::String, location::String) = split(line, " @ ")
    id = SubString(id, 2)
    (offset::String, size::String) = split(location, ": ")
    (offset_x::String, offset_y::String) = split(offset, ",")
    (size_x::String, size_y::String) = split(size, "x")
    return (parse(Int64, id),
    parse(Int64, offset_x),
    parse(Int64, offset_y),
    parse(Int64, size_x),
    parse(Int64, size_y))
end

function full_size(line::NTuple{5, Int64})
    width = 1 + line[2] + line[4]
    height = 1 + line[3] + line[5]
    return (width, height)
end

function full_width(line::NTuple{5, Int64})
    return full_size(line)[1]
end

function full_height(line::NTuple{5, Int64})
    return full_size(line)[2]
end

rows = line_parser.(lines)

max_width = maximum(full_width.(rows))
max_height = maximum(full_height.(rows))

cloth = zeros(max_height, max_width)

function add_claim_to_cloth(row::NTuple{5,Int64})
    rows = (1 + row[3]):(row[5]+row[3])
    cols = (1 + row[2]):(row[2]+row[4])
    cloth[rows,cols] .+= 1.;
end

add_claim_to_cloth.(rows)

function num_overlapped_sq_inches()
    overlapped_inches = 0
    for inch in cloth
        if inch > 1.
            overlapped_inches += 1
        end
    end
    return overlapped_inches
end

num_overlapped_sq_inches()

function intact_claim(row::NTuple{5, Int64})::Bool
    rows = (1 + row[3]):(row[5]+row[3])
    cols = (1 + row[2]):(row[2]+row[4])
    subsquare = cloth[rows,cols]
    if maximum(subsquare) <= 1.
        return true
    else
        return false
    end
end

intact_claims = filter(intact_claim, rows)
