mutable struct LinkedListNode{T}
    data::T
    prev::Union{LinkedListNode,Nothing}
    next::Union{LinkedListNode,Nothing}
end

mutable struct LinkedList{T}
    head::LinkedListNode{T}
    tail::LinkedListNode{T}
    length::Int64
end

import Base.push!
function push!(xs::LinkedList, x)
    newnode = LinkedListNode(x, xs.tail, nothing)
    xs.tail.next = newnode
    xs.tail = newnode
    xs.length += 1
end

function check_length(a::LinkedList)::Bool
    length = 1
    h = a.head
    nums = [h.data]
    while h.next != nothing
        h = h.next
        length += 1
        push!(nums, h.data)
    end
    if a.length > 21
        println(nums)
    end
    if a.length != length
        println("Something broke")
        return false
    end
    return true
end

import Base.insert!
function insert!(a::LinkedList, idx, obj)
    node = a.head
    for i in 1:idx
        node = node.next
    end
    p = node.prev
    newnode = LinkedListNode(obj, p, node)
    p.next = newnode
    node.prev = newnode
    a.length += 1
    #check_length(a)
end

import Base.circshift!
function circshift!(a::LinkedList, num::Int64)
    lastnode = a.tail
    if num < 0
        lastnode = a.head
        for i in 1:(-1*num)
            lastnode = lastnode.next
        end
    else
        for i in 1:num-1
            lastnode = lastnode.prev
        end
    end
    new_front = lastnode
    new_back = lastnode.prev
    a.tail.next = a.head
    a.head.prev = a.tail
    a.head = new_front
    a.tail = new_back
    new_front.prev = nothing
    new_back.next = nothing
    #check_length(a)
end

import Base.length
function length(a::LinkedList)::Int64
    return a.length
end

import Base.getindex
function getindex(a::LinkedList, idx::Int64)
    if idx > 0
        h = a.head
        for i in 1:idx-1
            h = h.next
        end
        return h.data
    else
        h = a.tail
        for i in 2:(abs(idx))
            h = h.prev
        end
        return h.data
    end
end

function getindex(a::LinkedList, idxs::UnitRange{Int64})
    result = []
    for idx in idxs.start:idxs.stop
        push!(result, a[idx])
    end
    return result
end

import Base.deleteat!
function deleteat!(a::LinkedList, idx::Int64)
    if idx > 0
        h = a.head
        for i in 1:idx-1
            h = h.next
            if h == nothing
                return
            end
        end
        h.prev.next = h.next
        h.next.prev = h.prev
        a.length -= 1
    else
        h = a.tail
        for i in 1:abs(idx)
            h = h.prev
            if h == nothing
                return
            end
        end
        h.prev.next = h.next
        h.next.prev = h.prev
        a.length -= 1
    end
    #check_length(a)
end

function getlines(path)::Array{String}
    retval = []
    open(path) do file
        for line in eachline(file)
            push!(retval, line)
        end
    end
    return retval
end

import Base.setindex!

mutable struct TapeDict{T}
    data::Dict{Int64,T}
    default::T
    min::Int64
    max::Int64
end

function getindex(t::TapeDict, i::Int64)
    try
        return t.data[i]
    catch err
        if isa(err, KeyError)
            if i < t.min
                t.min = i
            elseif i > t.max
                t.max = i
            end
            t.data[i] = t.default
            return t.default
        end
    end
end

function getindex(t::TapeDict, is::UnitRange{Int64})
    return [t[i] for i in is]
end

function setindex!(t::TapeDict, x, i::Int64)
    t.data[i] = x
    if i < t.min
        t.min = i
    elseif i > t.max
        t.max = i
    end
end

mutable struct InfiniteBitArray
    pos::BitArray{1}
    neg::BitArray{1}
    zero::Bool
    default::Bool
    min::Int64
    max::Int64
end

function extend(t::InfiniteBitArray, min::Int64, max::Int64)
    if max > t.max
        for _ in t.max:(2*max)
            push!(t.pos, t.default)
        end
        t.max = 2*max
    end
    if min < t.min
        for _ in t.min:-1:(2*min)
            push!(t.neg, t.default)
        end
        t.min = 2*min
    end
end

function getindex(t::InfiniteBitArray, idx::Int64)
    extend(t, idx, idx)
    if idx == 0
        return t.zero
    elseif idx > 0
        return t.pos[idx]
    else
        return t.neg[abs(idx)]
    end
end

function getindex(t::InfiniteBitArray, is::UnitRange{Int64})
    extend(t,is.start,is.stop)
    if is.start < 0
        if is.stop < 0
            return t.neg[abs(is.start):-1:abs(is.stop)]
        elseif is.stop == 0
            part_a = t.neg[abs(is.start):-1:1]
            push!(part_a, t.zero)
            return part_a
        else # is.stop > 0
            part_a = t.neg[abs(is.start):-1:1]
            push!(part_a, t.zero)
            part_c = t.pos[1:is.stop]
            return vcat(part_a, part_c)
        end
    elseif is.start == 0
        part_a = [t.zero]
        part_b = t.pos[1:is.stop]
        return vcat(part_a, part_b)
    else
        return t.pos[is.start:is.stop]
    end
end

function setindex!(t::InfiniteBitArray, v::Bool, idx::Int64)
    extend(t,idx,idx)
    if idx == 0
        t.zero = v
    elseif idx > 0
        t.pos[idx] = v
    else #idx < 0
        t.neg[abs(idx)] = v
    end
end

mutable struct Tape
    current::InfiniteBitArray
    next::InfiniteBitArray
    min::Int64
    max::Int64
end

function getindex(t::Tape, idx::Int64)::Bool
    return t.current[idx]
end

function getindex(t::Tape, is::UnitRange{Int64})::Bool
    return t.current[is]
end

function setindex!(t::Tape, v::Bool, idx::Int64)
    t.current[idx] = v
end

function Tape()
    current = InfiniteBitArray([], [], false, false, 0, 0)
    next = InfiniteBitArray([], [], false, false, 0, 0)
    return Tape(current, next, 0, 0)
end
