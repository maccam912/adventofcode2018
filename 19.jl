include("cpu.jl")

c = CPU([1,0,0,0,0,0])

p = read_program("inputs/19.txt")

ips = []
function part_2()::CPU
    c = CPU([1,0,0,0,0,0])
    while true
        #push!(ips, c.registers[p.ip+1])
        try
            ins = p.lines[c.registers[p.ip+1]]
            @fastmath run_instruction(c, ins)
            @fastmath c.registers[p.ip+1] += 1
            #@show c
        catch
            return c
        end
    end
    return c
end

p2 = part_2()

# 3 mulr F E C # C = F * E
# 4 eqrr C B C # C = C == B ? 1 : 0
# 5 addr C D D # ip += C
# 6 addi D 1 D # ip += 1
# 7 addr F A A # A += F
# 8 addi E 1 E # E += 1
# 9 gtrr E B C # C = E > B ? 1 : 0
# 10 addr D C D # ip += C -> if E > B exit, else keep looping
#  while E <= B...

# 11 seti 2 X D # ip = 2 -> loop to 3
D = 16
F = 1
E = 1

while E <= B
    C = F*E
    if C == B
        A += F
    end
    E += 1
end

r3 = 10551343

for r1 in 1:r3
    for r5 in 1:r3
        if r1*r5 == r3
            ro += r1

function get_answer()
    s = 0
    for x in 1:10551343
        if 10551343 % x == 0
            s += x
        end
    end
    return s
end

a = get_answer()
