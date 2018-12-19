mutable struct CPU
    registers::Array{Int64}
end

struct Instruction
    op::String
    a::Int64
    b::Int64
    c::Int64
end

mutable struct Program
    ip::Int64
    lines::Dict{Int64,Instruction}
end

include("util.jl")

function read_program(path::String)::Program
    lines = getlines(path)
    ip_reg = parse(Int64, split(lines[1], " ")[2])
    proglines = Dict()
    linenum = 0
    for line in lines[2:end]
        parts = split(line, " ")
        op = parts[1]
        a = parse(Int64, parts[2])
        b = parse(Int64, parts[3])
        c = parse(Int64, parts[4])
        proglines[linenum] = Instruction(op, a, b, c)
        linenum += 1
    end
    program = Program(ip_reg, proglines)
    return program
end

function run_instruction(before::CPU, i::Instruction)
    if i.op == "addr"
        before.registers[i.c+1] = before.registers[i.a+1] + before.registers[i.b+1]
    elseif i.op == "addi"
        before.registers[i.c+1] = before.registers[i.a+1] + i.b
    elseif i.op == "mulr"
        before.registers[i.c+1] = before.registers[i.a+1] * before.registers[i.b+1]
    elseif i.op == "muli"
        before.registers[i.c+1] = before.registers[i.a+1] * i.b
    elseif i.op == "banr"
        before.registers[i.c+1] = before.registers[i.a+1] & before.registers[i.b+1]
    elseif i.op == "bani"
        before.registers[i.c+1] = before.registers[i.a+1] & i.b
    elseif i.op == "borr"
        before.registers[i.c+1] = before.registers[i.a+1] | before.registers[i.b+1]
    elseif i.op == "bori"
        before.registers[i.c+1] = before.registers[i.a+1] | i.b
    elseif i.op == "setr"
        before.registers[i.c+1] = before.registers[i.a+1]
    elseif i.op == "seti"
        before.registers[i.c+1] = i.a
    elseif i.op == "gtir"
        if i.a > before.registers[i.b+1]
            before.registers[i.c+1] = 1
        else
            before.registers[i.c+1] = 0
        end
    elseif i.op == "gtri"
        if before.registers[i.a+1] > i.b
            before.registers[i.c+1] = 1
        else
            before.registers[i.c+1] = 0
        end
    elseif i.op == "gtrr"
        if before.registers[i.a+1] > before.registers[i.b+1]
            before.registers[i.c+1] = 1
        else
            before.registers[i.c+1] = 0
        end
    elseif i.op == "eqir"
        if i.a == before.registers[i.b+1]
            before.registers[i.c+1] = 1
        else
            before.registers[i.c+1] = 0
        end
    elseif i.op == "eqri"
        if before.registers[i.a+1] == i.b
            before.registers[i.c+1] = 1
        else
            before.registers[i.c+1] = 0
        end
    elseif i.op == "eqrr"
        if before.registers[i.a+1] == before.registers[i.b+1]
            before.registers[i.c+1] = 1
        else
            before.registers[i.c+1] = 0
        end
    end
end
