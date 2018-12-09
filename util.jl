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
        for i in 1:(abs(idx))
            h = h.prev
        end
        return h.data
    end
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
