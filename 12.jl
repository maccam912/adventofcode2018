exit()
using ProgressMeter
include("util.jl")

function make_plantsrow(initial_state::String)::Tape
    t = Tape()
    idx = 0
    for c in initial_state
        if c == '#'
            t[idx] = true
        elseif c == '.'
            t[idx] = false
        end
        idx += 1
    end
    t.min = 0
    t.max = length(initial_state)
    return t
end

function translate_char(c::Char)::Bool
    if c == '#'
        return true
    else
        return false
    end
end

function parse_rule(rule::String)::Pair{Array{Bool},Bool}
    parts = split(rule, " => ")
    i = parts[1]
    o = parts[2]
    _i = map(translate_char, collect(i))
    _o = translate_char(o[1])
    return _i => _o
end

function apply_rule(rule::String, t::Tape)
    parsed_rule = parse_rule(rule)
    for idx in t.min:t.max
        subarr = t.current[idx-2:idx+2]
        if parsed_rule[1] == subarr
            if idx < t.min
                t.min = t.min -= 2
                extend(t.current,t.min,t.min)
                extend(t.next,t.min,t.min)
            end
            if idx > t.max
                t.max = t.max += 2
                extend(t.current,t.max,t.max)
                extend(t.next,t.max,t.max)
            end
            t.next[idx] = parsed_rule[2]
        end
    end
end

function apply_rules(rules::Array{String}, t::Tape)
    for i in t.min-5:t.max+5
        t.next[i] = false
    end
    for rule in rules
        apply_rule(rule, t)
    end
    temp = t.current
    t.current = t.next
    t.next = temp
end

function print_row(t::Tape)
    retval::Array{Char} = []
    for i in -2:50
        if t[i]
            push!(retval, '#')
        else
            push!(retval, '.')
        end
    end
    println(join(retval))
end

function part_1(n)
    include("inputs/12.txt")
    row = make_plantsrow(initial_state)
    extend(row.current,-1000,1000)
    extend(row.next,-1000,1000)
    row.min = -1000
    row.max = 1000
    #print_row(row)
    scores = []
    @showprogress for generation in 1:n
        apply_rules(rules, row)
        #print_row(row)
        sum = 0
        for idx in row.min:row.max
            if row[idx]
                sum += idx
            end
        end
        push!(scores, (generation, sum))
        #print
    end
    #println(sum)
    return scores
end

println("###")
score = part_1(200)


_scores = map(x->x[2], collect(score))

using Plots
plot(_scores)
