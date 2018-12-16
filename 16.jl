mutable struct CPU
    a::Int64
    b::Int64
    c::Int64
    d::Int64
end

import Base.==
function ==(x::CPU, y::CPU)::Bool
    if x.a == y.a && x.b == y.b && x.c == y.c && x.d == y.d
        return true
    else
        return false
    end
end

struct Op
    instruction::Int64
    a::Int64
    b::Int64
    c::Int64
end

include("util.jl")

function parse_registers(line::String)::CPU
    matches = match(r".*\[(\d+), (\d+), (\d+), (\d+)\]", line)
    return CPU(parse(Int64, matches[1]), parse(Int64, matches[2]), parse(Int64, matches[3]), parse(Int64, matches[4]))
end

function parse_op(line::String)::Op
    matches = match(r"(\d+) (\d+) (\d+) (\d+)", line)
    return Op(parse(Int64, matches[1]), parse(Int64, matches[2]), parse(Int64, matches[3]), parse(Int64, matches[4]))
end

function chunk_input()
    lines = getlines("inputs/16a.txt")
    chunks = []
    while length(lines) > 2
        before = lines[1]
        op = lines[2]
        after = lines[3]
        push!(chunks, (before, op, after))
        deleteat!(lines, 1)
        deleteat!(lines, 1)
        deleteat!(lines, 1)
        try
            deleteat!(lines, 1)
        catch
        end
    end
    parsed_chunks = []
    for chunk in chunks
        before = parse_registers(chunk[1])
        op = parse_op(chunk[2])
        after = parse_registers(chunk[3])
        push!(parsed_chunks, (before, op, after))
    end
    return parsed_chunks
end

function run_instruction(before::CPU, op::Op, i::String)::CPU
    r = [before.a, before.b, before.c, before.d]
    if i == "addr"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] + r[op.b+1]
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "addi"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] + op.b
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "mulr"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] * r[op.b+1]
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "muli"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] * op.b
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "banr"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] & r[op.b+1]
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "bani"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] & op.b
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "borr"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] | r[op.b+1]
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "bori"
        c = CPU(before.a, before.b, before.c, before.d)
        val = r[op.a+1] | op.b
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "setr"
        c = CPU(before.a, before.b, before.c, before.d)
        val = 0
        if op.a == 0
            val = before.a
        elseif op.a == 1
            val = before.b
        elseif op.a == 2
            val = before.c
        elseif op.a == 3
            val = before.d
        end
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "seti"
        c = CPU(before.a, before.b, before.c, before.d)
        val = op.a
        if op.c == 0
            c.a = val
        elseif op.c == 1
            c.b = val
        elseif op.c == 2
            c.c = val
        elseif op.c == 3
            c.d = val
        end
        return c
    elseif i == "gtir"
        c = CPU(before.a, before.b, before.c, before.d)
        if op.a > r[op.b+1]
            if op.c == 0
                c.a = 1
            elseif op.c == 1
                c.b = 1
            elseif op.c == 2
                c.c = 1
            elseif op.c == 3
                c.d = 1
            end
        else
            if op.c == 0
                c.a = 0
            elseif op.c == 1
                c.b = 0
            elseif op.c == 2
                c.c = 0
            elseif op.c == 3
                c.d = 0
            end
        end
        return c
    elseif i == "gtri"
        c = CPU(before.a, before.b, before.c, before.d)
        if r[op.a+1] > op.b
            if op.c == 0
                c.a = 1
            elseif op.c == 1
                c.b = 1
            elseif op.c == 2
                c.c = 1
            elseif op.c == 3
                c.d = 1
            end
        else
            if op.c == 0
                c.a = 0
            elseif op.c == 1
                c.b = 0
            elseif op.c == 2
                c.c = 0
            elseif op.c == 3
                c.d = 0
            end
        end
        return c
    elseif i == "gtrr"
        c = CPU(before.a, before.b, before.c, before.d)
        if r[op.a+1] > r[op.b+1]
            if op.c == 0
                c.a = 1
            elseif op.c == 1
                c.b = 1
            elseif op.c == 2
                c.c = 1
            elseif op.c == 3
                c.d = 1
            end
        else
            if op.c == 0
                c.a = 0
            elseif op.c == 1
                c.b = 0
            elseif op.c == 2
                c.c = 0
            elseif op.c == 3
                c.d = 0
            end
        end
        return c
    elseif i == "eqir"
        c = CPU(before.a, before.b, before.c, before.d)
        if op.a == r[op.b+1]
            if op.c == 0
                c.a = 1
            elseif op.c == 1
                c.b = 1
            elseif op.c == 2
                c.c = 1
            elseif op.c == 3
                c.d = 1
            end
        else
            if op.c == 0
                c.a = 0
            elseif op.c == 1
                c.b = 0
            elseif op.c == 2
                c.c = 0
            elseif op.c == 3
                c.d = 0
            end
        end
        return c
    elseif i == "eqri"
        c = CPU(before.a, before.b, before.c, before.d)
        if r[op.a+1] == op.b
            if op.c == 0
                c.a = 1
            elseif op.c == 1
                c.b = 1
            elseif op.c == 2
                c.c = 1
            elseif op.c == 3
                c.d = 1
            end
        else
            if op.c == 0
                c.a = 0
            elseif op.c == 1
                c.b = 0
            elseif op.c == 2
                c.c = 0
            elseif op.c == 3
                c.d = 0
            end
        end
        return c
    elseif i == "eqrr"
        c = CPU(before.a, before.b, before.c, before.d)
        if r[op.a+1] == r[op.b+1]
            if op.c == 0
                c.a = 1
            elseif op.c == 1
                c.b = 1
            elseif op.c == 2
                c.c = 1
            elseif op.c == 3
                c.d = 1
            end
        else
            if op.c == 0
                c.a = 0
            elseif op.c == 1
                c.b = 0
            elseif op.c == 2
                c.c = 0
            elseif op.c == 3
                c.d = 0
            end
        end
        return c
    end
end

function num_possible_instructions(before::CPU, op::Op, after::CPU)::Int64
    count = 0
    for i in ["addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori", "setr", "seti", "gtir", "gtri", "gtrr", "eqir", "eqri", "eqrr"]
        c = run_instruction(before, op, i)
        if c == after
            count += 1
        end
    end
    return count
end

function is_instruction(before::CPU, op::Op, after::CPU, reject::Array{String})::String
    count = 0
    ins = []
    for i in ["addr", "addi", "mulr", "muli", "banr", "bani", "borr", "bori", "setr", "seti", "gtir", "gtri", "gtrr", "eqir", "eqri", "eqrr"]
        if !(i in reject)
            c = run_instruction(before, op, i)
            if c == after
                count += 1
                push!(ins, i)
            end
        end
    end
    if count == 1
        return string("Opcode " * string(op.instruction) * " is " * string(ins[1]))
    end
    return ""
end

function part_1(chunks)::Int64
    count = 0
    for chunk in chunks
        if num_possible_instructions(chunk[1], chunk[2], chunk[3]) >= 3
            count += 1
        end
    end
    return count
end

function part_2(chunks, _opcodes)
    opcodes::Set{String} = Set()
    reject = [o[2] for o in _opcodes]
    for chunk in chunks
        push!(opcodes, is_instruction(chunk[1], chunk[2], chunk[3], reject))
    end
    return opcodes
end

#c = run_instruction(chunks[1][1], chunks[1][2], "addi")
#n = num_possible_instructions(chunks[1][1], chunks[1][2], chunks[1][3])
#p1 = part_1(chunks)
main() = begin
    chunks = chunk_input()
    opcodes::Dict{Int64,String} = Dict()
    opcodes[0] = "addi"
    opcodes[1] = "bani"
    opcodes[2] = "gtir"
    opcodes[3] = "borr"
    opcodes[4] = "eqrr"
    opcodes[5] = "bori"
    opcodes[6] = "gtrr"
    opcodes[7] = "setr"
    opcodes[8] = "muli"
    opcodes[9] = "seti"
    opcodes[10] = "banr"
    opcodes[11] = "gtri"
    opcodes[12] = "eqir"
    opcodes[13] = "eqri"
    opcodes[14] = "addr"
    opcodes[15] = "mulr"
    part_2(chunks, opcodes)
end
main()

function part_2b()
    opcodes::Dict{Int64,String} = Dict()
    opcodes[0] = "addi"
    opcodes[1] = "bani"
    opcodes[2] = "gtir"
    opcodes[3] = "borr"
    opcodes[4] = "eqrr"
    opcodes[5] = "bori"
    opcodes[6] = "gtrr"
    opcodes[7] = "setr"
    opcodes[8] = "muli"
    opcodes[9] = "seti"
    opcodes[10] = "banr"
    opcodes[11] = "gtri"
    opcodes[12] = "eqir"
    opcodes[13] = "eqri"
    opcodes[14] = "addr"
    opcodes[15] = "mulr"
    lines = getlines("inputs/16b.txt")
    ops = []
    for line in lines
        push!(ops, parse_op(line))
    end
    c = CPU(0, 0, 0, 0)
    for op in ops
        println(op)
        c = run_instruction(c, op, opcodes[op.instruction])
        println(c)
    end
end

part_2b()
