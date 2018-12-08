include("util.jl")

lines = getlines("inputs/8.txt")
line = lines[1]
nums = map(x->parse(Int64,x), split(line, " "))

mutable struct Node
    children::Array{Node}
    metadata::Array{Int64}
end

function getnode(xs::Array{Int64})::Tuple{Node,Array{Int64}}
    numnodes = xs[1]
    nummetadatas = xs[2]
    thisnode = Node([],[])
    newxs = xs[3:end]
    for n in 1:numnodes
        node, newxs = getnode(newxs)
        push!(thisnode.children, node)
    end
    for m in 1:nummetadatas
        push!(thisnode.metadata, newxs[1])
        newxs = newxs[2:end]
    end
    return thisnode, newxs
end

function sumtree(x::Node)::Int64
    this_sum = sum(x.metadata)
    for c in x.children
        this_sum += sumtree(c)
    end
    return this_sum
end

function part_2_sumtree(x::Node)::Int64
    if length(x.children) == 0
        return sumtree(x)
    else
        this_sum = 0
        for m in x.metadata
            try
                cnode = x.children[m]
                this_sum += part_2_sumtree(cnode)
            catch
                this_sum += 0
            end
        end
        return this_sum
    end
end

tree = getnode(nums)[1]

part_1 = sumtree(tree)
@time part_1 = sumtree(tree)
part_2 = part_2_sumtree(tree)
@time part_2 = part_2_sumtree(tree)
