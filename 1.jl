function getlines()
    retval = []
    open("inputs/1.txt") do file
        for line in eachline(file)
            push!(retval, line)
        end
    end
    return map(x -> parse(Int64, x), retval)
end

nums = getlines()

sum(nums)

function secondfrequency()
    seen_frequencies = Set([])
    curr_sum = 0
    while true
        for num in nums
            curr_sum += num
            if in(curr_sum, seen_frequencies)
                return curr_sum
            end
            push!(seen_frequencies, curr_sum)
        end
    end
end
