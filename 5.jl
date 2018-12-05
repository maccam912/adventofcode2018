using Distributed
addprocs(4)

@everywhere include("inputs/5.txt")

@everywhere function scan_and_remove(polymer::String)::String
    for i in 1:length(polymer)-1
        a = polymer[i]
        b = polymer[i+1]
        if (uppercase(a) == uppercase(b)) &&
            ((isuppercase(a) && !isuppercase(b)) ||
            (!isuppercase(a) && isuppercase(b)))
            # Remove these two
            x = polymer[1:i-1]
            y = polymer[i+2:end]
            return join([x,y])
        end
    end
    return polymer
end

@everywhere function aocreduce(polymer::String)::String
    p2 = scan_and_remove(polymer)
    if length(p2) < length(polymer)
        return aocreduce(p2)
    end
    return p2
end

@everywhere function basetypes(polymer::String)::Set{Char}
    retval = Set()
    for c in polymer
        push!(retval, lowercase(c))
    end
    return retval
end

function part_2(polymer::String)
    bases = join(basetypes(polymer))
    results = @distributed (merge) for c in bases
        p2 = replace(polymer, c => "")
        p3 = replace(p2, uppercase(c) => "")
        reduced = aocreduce(p3)
        Dict(c => length(reduced))
    end
    sorted = sort(collect(results), by=x->x[2])
    return sorted
end


p = aocreduce(polymer)
println(length(p))
println(part_2(polymer))
