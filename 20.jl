using ParserCombinator

mutable struct Direction
    current::Char
    next::Array{Direction}
end

function unwrap_any(a)
    if typeof(a) == Array{Any,1}
        return unwrap_any(a[1])
    end
    return a
end

function Direction(d::Array)::Direction
    return Direction(d[1][1], [])
end

function Joiner(a)
    if length(a) == 1
        return a
    elseif length(a) == 2
        a2 = collect(Iterators.flatten(a[2]))
        for n in a2
            push!(a[1].next, n[1][1])
        end
        return a2
    else
        println("LEngth more than 2")
        println(typeof(a))
        println(unwrap_any(a[2]))
    end
end

Dir = p"[NSEW]"|> Direction
All = Delayed()
Normal = Delayed()
Branch = Delayed()

Normal.matcher = Dir + Star(All) |> Joiner
Branch.matcher = E"(" + All + Star(E"|" + All) + E")" |> identity
All.matcher = Normal | Branch |> identity
Parser = All + Eos()

parse_one("N(S)W", Parser)
