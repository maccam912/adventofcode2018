include("cpu.jl")

p = read_program("inputs/21.txt")

function part_1()::CPU
    c = CPU([0,0,0,0,0,0])
    darr::Array{Int64} = []
    while true
        #push!(ips, c.registers[p.ip+1])
        try
            ins = p.lines[c.registers[p.ip+1]]
            pi = c.registers[p.ip+1]
            run_instruction(c, ins)
            c.registers[p.ip+1] += 1
            # if ins.c == 5
            #     pip = c.registers[p.ip+1]
            #     if pi > pip
            #         println("Jumping from " * string(pi) * " to " * string(pip))
            #         println(p.lines[pi])
            #         println(p.lines[pip])
            #         sleep(0.01)
            #     end
            # end
            if ins.b == 0 && ins.op != "seti"
                if c.registers[3] in darr
                    println(darr[end-5:end])
                    break
                else
                    push!(darr, c.registers[3])
                end
                if length(darr) % 100 == 0
                    println(length(darr))
                end
                #sleep(0.01)
            end
        catch
            return c
        end
    end
    return c
end

@time c = part_1()
