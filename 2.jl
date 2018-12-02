include("util.jl")

inputs = getlines("inputs/2.txt")

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

function compare_strings(a::String, b::String)::Tuple{Int64,Array{Char}}
    in_common = []
    difference = 0
    for i in 1:length(a)
        if a[i] == b[i]
            push!(in_common, a[i])
        else
            difference += 1
        end
    end
    return (difference, in_common)
end

function get_pairs(inputs)
    pairlist::Array{Tuple{String,String}} = []
    for i in 1:(length(inputs)-1)
        for j in (i+1):length(inputs)
            push!(pairlist, (inputs[i],inputs[j]))
        end
    end
    return pairlist
end


twos = filter(has_two, inputs)
threes = filter(has_three, inputs)
println(length(twos)*length(threes))

difflist = map(x -> compare_strings(x...), get_pairs(inputs))
diff_of_one = filter(x -> x[1] == 1, difflist)
println(join(diff_of_one[1][2]))
