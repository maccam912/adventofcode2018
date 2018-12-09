using Profile, ProfileView

include("util.jl")

mutable struct Circle
    marbles::LinkedList{Int64}
    next_marble::Int64
end

function rotate_marbles(c::Circle, idx::Int64)
    pre = c.marbles[idx:end]
    post = c.marbles[1:idx-1]
    c.marbles = vcat(pre,post)
end

function insert_marble(circle::Circle)::Int64
    marble_to_insert = circle.next_marble
    if marble_to_insert % 23 == 0
        score = marble_to_insert + circle.marbles[-6]
        deleteat!(circle.marbles, -6)
        circshift!(circle.marbles, 6)
        #rotate_marbles(circle, mod(-5,length(circle)))
        circle.next_marble += 1
        return score
    else
        insert!(circle.marbles, 2, marble_to_insert)
        circshift!(circle.marbles, -2)
        #rotate_marbles(circle, 3)
        circle.next_marble += 1
        return 0
    end
end

function part_1(num_players::Int64, last_marble::Int64)
    a = LinkedListNode(3, nothing, nothing)
    b = LinkedListNode(0, a, nothing)
    c = LinkedListNode(2, b, nothing)
    d = LinkedListNode(1, c, nothing)
    c.next = d
    b.next = c
    a.next = b
    circle = Circle(LinkedList(a,d,4), 4)
    player_scores::Array{Int64} = zeros(num_players)
    player = 1
    while circle.next_marble <= last_marble
        if circle.next_marble % 72170 == 0
            #println(circle.next_marble/72170)
        end
        player_scores[player] += insert_marble(circle)
        player += 1
        player = (player % num_players)
        if player == 0
            player = num_players
        end
    end
    maximum(player_scores)
end

part_1(10,25)
part_1(10,1618)
part_1(13,7999)
part_1(17,1104)
part_1(470,72170)
part_2 = part_1(470,72170*100)

Profile.clear()
@profile part_1(470,72170*100)
ProfileView.view()

@time part_2 = part_1(470,72170*100)
