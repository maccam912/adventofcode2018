#' # Solving Day 23 with Julia

#' [Day 23](https://adventofcode.com/2018/day/23) of the [Advent of Code](https://adventofcode.com/) this year
#' was a tough problem I had trouble solving. The basic idea is that a
#' thousand tiny nanobots, each with a 3D location in space and a range representing
#' the maximum [manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry)
#' they could interact with, were going to teleport me as long as I was in range of the
#' nanobot that was doing the teleporting. Not knowing for sure which bot that would be,
#' participants had to find the point in 3D space that had the most overlapping nanobots' ranges.
#' My first brute-force approach was to get the cube containing all the nanobots and check
#' each point within. If two or more points have the number of nanobots' overlapping ranges, choose
#' the point closest to 0,0,0 and the answer is the manhattan distance between this point and 0,0,0.
#'
#' After realizing my input had nanobots' locations listed as pos=<-66538252,24214519,54774103>, r=94247941
#' I knew the bruteforce approach wouldn't work. We're talking about a cube thats about
BigInt(100000000)^3
#' ((100 million cubed = 1 septillion) units I'll need to check! Way too many. Some people came up with clever ways to do this. I decided to try
#' [BlackBoxOptim.jl](https://github.com/robertfeldt/BlackBoxOptim.jl).

#' ## Setup
#' After making a structure for my nanobots
struct Nanobot
    x::Int64
    y::Int64
    z::Int64
    r::Int64
end

#' and reading the input:
function getlines(path)::Array{String}
    retval = []
    open(path) do file
        for line in eachline(file)
            push!(retval, line)
        end
    end
    return retval
end
#' I parsed the lines to get positions for my nanobots:
function parse_input()::Array{Nanobot,1}
    lines = getlines("23.txt")
    re = r"^pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)$"
    nanobots = []
    for line in lines
        matches = match(re, line)
        try
            parts = [parse(Int64, matches[i]) for i in 1:4]
            nanobot = Nanobot(parts...)
            push!(nanobots, nanobot)
        catch
            println(line)
        end
    end
    return nanobots
end
nanobots = parse_input()

#' Helper to calculate Manhattan distance:
function mdist(x,y,z,x2,y2,z2)::Int64
    return abs(x-x2)+abs(y-y2)+abs(z-z2)
end

#' Scoring function to get score of a point in 3D space (this actually returns a function. I didn't want
#' to be doing the nanobot parse_input() function every time):
function score()
    nanobots = parse_input()
    return (w) -> begin
        x = round(w[1])
        y = round(w[2])
        z = round(w[3])
        score = 0
        for n in nanobots
            if mdist(x,y,z,n.x,n.y,n.z) <= n.r
                score += 1
            end
        end
        return float(1000-score)+(float(mdist(x,y,z,0,0,0))/848312125.0)
    end
end
score_func = score()
#' *Note: I will be passing in a 3D point as an array of floating point numbers since
#' that is what BlackBoxOptim will do. In the function I split it into x, y, and z components
#' before rounding them to their integer values and using those. The final score I return is mostly
#' just the score of that point (the number of nanobots it is in range of) with a small part (less than 1 total)
#' to break ties so that two points with the same score will tell me the points that are closer to 0,0,0.*
#' ## The Magic
#' Next up we will be
using BlackBoxOptim
#'
#' BlackBoxOptim needs a range that it will check in. From some other code (not copied here) I found the minimum
#' and maximum values for any of the x, y, and z points for any of the nanobots, including the range they could communicate with.
#' My minimum will be
range_min = -300000000.0
#' and my maximum will be
range_max = 400000000.0
#' (again, both floating point numbers since that is what BlackBoxOptim needs)
#'
#' At this point all the hard work is done. Now you just need to make the optimizer and run it:
res = bboptimize(score_func;
    Method=:adaptive_de_rand_1_bin,
    SearchRange = (range_min,range_max),
    NumDimensions = 3,
    MaxTime = 60.0,
    TraceInterval = 10.0,
    PopulationSize=1000,
    TraceMode=:compact)
#'
#' The first argument is the function to optimize. Given a vector (in this case 3 dimensions) with each
#' value in the search range find the vector that returns a minimum score from the function.
#' The method I have here was just suggested to me by the BlackBoxOptim docs. I have no idea what it's actually doing.
#' I set the max time to 10 minutes and population size to 1000 because I was about to run off to lunch. Even though I
#' got back before the ten minutes was up I was able to see it had converged on a solution and stopped it early,
#' using the best intermediate results it had at that point.
#'
point = map(x->convert(Int64,round(x)), best_candidate(res))
println(point)
println(score_func([point[1],point[2],point[3]]))
#' Pop that through the mdist function to get the distance from 0,0,0 and I had my answer.
mdist(0,0,0,point...)
