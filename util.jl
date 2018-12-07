function getlines(path)::Array{String}
    retval = []
    open(path) do file
        for line in eachline(file)
            push!(retval, line)
        end
    end
    return retval
end
