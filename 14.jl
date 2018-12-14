include("util.jl")

recipe1 = LinkedListNode(3, nothing, nothing)
recipe2 = LinkedListNode(7, recipe1, nothing)
recipe1.next = recipe2
recipes = LinkedList(recipe1, recipe2, 2)

function get_digits(x::Int64)::Array{Int64}
    digits = string(x)
    return [parse(Int64, c) for c in digits]
end

elf1 = recipe1
elf2 = recipe2
function dostep(elf1, elf2)
    combined_score = elf1.data+elf2.data
    new_recipes = get_digits(combined_score)
    for digit in new_recipes
        push!(recipes, digit)
    end
    elf1_movement = elf1.data+1
    elf2_movement = elf2.data+1
    for i in 1:(elf1_movement)
        if elf1.next != nothing
            elf1 = elf1.next
        else
            elf1 = recipes.head
        end
    end
    for i in 1:(elf2_movement)
        if elf2.next != nothing
            elf2 = elf2.next
        else
            elf2 = recipes.head
        end
    end
    return elf1,elf2
end

part_1 = 765071
while recipes.length < (part_1+10)
    global elf1, elf2
    elf1,elf2 = dostep(elf1, elf2)
end

a = recipes[part_1+1:part_1+10]

function stringatize(l)
    return join([string(c) for c in l])
end

function check_for(recipes, part_2)
    l = length(part_2)
    if recipes.length <= l
        return false
    end
    last_l = stringatize(recipes[-l:-1])
    next_last_l = stringatize(recipes[-l-1:-2])
    if last_l == part_2
        println(recipes.length-l)
        return true
    elseif next_last_l == part_2
        println(recipes.length-l-1)
        return true
    else
        return false
    end
end

part_2 = "765071"
c = 0
while !(check_for(recipes, part_2))
    global elf1, elf2, c
    c += 1
    if c % 100000 == 0
        println(c)
    end
    elf1,elf2 = dostep(elf1, elf2)
end
