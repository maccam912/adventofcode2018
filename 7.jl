using Printf
include("util.jl")

lines = getlines("inputs/7.txt")

function parse_step(line::String)::Pair{Char,Char}
    matches = match(r"Step (.) must be finished before step (.) can begin.", line)
    x = matches[1][1]
    y = matches[2][1]
    return x => y
end

function get_steps(lines::Array{String})
    steps::Dict{Char,Array{Char}} = Dict()
    letters::Set{Char} = Set()
    for line in lines
        p = parse_step(line)
        push!(letters, p[1])
        push!(letters, p[2])
        step = get(steps, p[2], [])
        push!(step, p[1])
        steps[p[2]] = step
    end
    for l in letters
        if !(l in keys(steps))
            steps[l] = []
        end
    end
    return steps
end

function and(arr::Array{Bool})::Bool
    for a in arr
        if !a
            return false
        end
    end
    return true
end

function ready(step::Char, steps::Dict{Char,Array{Char}}, runsteps::Array{Char}, takensteps::Array{Char})::Bool
    if step in runsteps
        return false
    elseif step in takensteps
        return false
    else
        return and([(s in runsteps) for s in steps[step]])
    end
end

function run_steps(steps::Dict{Char,Array{Char}})
    runsteps::Array{Char} = []
    sl = sort(collect(keys(steps)))
    println(sl)
    while length(runsteps) < length(sl)
        ts::Array{Char} = []
        readysteps = filter(x->ready(x, steps, runsteps, ts), sl)
        next_step = sort(readysteps)[1]
        push!(runsteps, next_step)
    end
    return runsteps
end

steps = get_steps(lines)
part_1 = run_steps(steps)

mutable struct Worker
    timeleft::Int64
    letter::Char
end

function do_work(steps::Dict{Char,Array{Char}})
    w() = Worker(0,'.')
    workers = [w(),w(),w(),w(),w()]
    base_time = 61
    sl = sort(collect(keys(steps)))
    times::Dict{Char,Int64} = Dict()
    for l in sl
        times[l] = base_time
        base_time += 1
    end

    runsteps::Array{Char} = []
    takensteps::Array{Char} = []
    timetaken = 0
    while length(runsteps) < length(sl)
        for worker in workers
            if worker.timeleft > 1
                worker.timeleft -= 1
            elseif worker.timeleft <= 1
                push!(runsteps,worker.letter)
                readysteps = filter(x->ready(x, steps, runsteps, takensteps), sl)
                if length(readysteps) > 0
                    next_step = sort(readysteps)[1]
                    worker.letter = next_step
                    push!(takensteps, next_step)
                    worker.timeleft = times[next_step]
                else
                    worker.letter = '.'
                end
            end
        end
        s = @sprintf "%s %s %s %s %s %s\n" timetaken workers[1].letter workers[2].letter workers[3].letter workers[4].letter workers[5].letter;
        print(s)
        runsteps = filter(x->x != '.', runsteps)
        timetaken += 1
    end
    println(runsteps)
    println(timetaken-1)
end

do_work(steps)
