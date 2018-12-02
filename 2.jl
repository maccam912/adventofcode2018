include("util.jl")

inputs = getlines("inputs/2_test.txt")

function string_to_dict(i::String)::Dict{Char,Int64}
    retval = Dict()
    for c in i
        if in(c,keys(retval))
            retval[c] += 1
        else
            retval[c] = 1
        end
    end
    return retval
end

function has_n(i::String, n::Int64)::Bool
    d = string_to_dict(i)
    vals = Set(values(d))
    if in(n, vals)
        return true
    else
        return false
    end
end

function has_two(i::String)::Bool
    return has_n(i, 2)
end

function has_three(i::String)::Bool
    return has_n(i, 3)
end

twos = filter(has_two, inputs)
threes = filter(has_three, inputs)
println(length(twos)*length(threes))
