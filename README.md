# awk-vm: A virtual machine and assembler written in AWK

## What?
_The AWK Programming Language_ (TAPL) seems at first glance to be a
book on using AWK to fulfill your text processing needs.  The first
100 or so pages do a great job of that, but then you reach Chapter 6,
the first 5 pages of which describe a virtual machine and assembler
whose AWK source fits just under a page, then you realize---that AWK
is so much more.

This repository takes the assembler/interpreter on page 134 of TAPL
and adds additional instructions and directives, without breaking
backwards compatibility.  It's still relatively small, though, under
200 lines.

## Usage
The lines between `Running...` and `Stopping.` is the program output,
in this case, it's `15`.
```text
$ awk -f vm int_sum.asm in.txt
Pass 1...done
Pass 2...done. 12 bytes total
Running...
15

Stopping. Program counter at 10.

$ awk -f vm greet.asm
Pass 1...done
Pass 2...done. 111 bytes total
Running...
What is your name? (Press RET twice to enter) Brian Kernighan

Hello, Brian Kernighan.
Stopping. Program counter at 22.
```

## VM Instructions (backwards compatible with TAPL)
**N.B. Instructions with opcode > 10 were written by me.**

**Boldface on opcodes <= 10 indicate changed behavior from the book**

| Opcode | Instruction | Meaning                                                              |
| :-:    | :-:         | :-:                                                                  |
| 01     | get         | read a number from the input into the accumulator                    |
| 02     | put         | write the contents of the accumulator to the output                  |
| 03     | ld M        | load accumulator with contents of memory location M                  |
| 04     | st M        | store contents of accumulator in location M                          |
| 05     | add M       | add contents of location M to accumulator                            |
| 06     | sub M       | subtract contents of location M from accumulator                     |
| 07     | jpos M      | jump to location M if accumulator is positive, **set J = PC + 1**    |
| 08     | jz M        | jump to location M if accumulator is zero, **set J = PC + 1**        |
| 09     | j M         | jump to location M, **set J = PC + 1**                               |
| 10     | halt        | stop execution                                                       |
| 11     | mul M       | multiply contents of location M with accumulator                     |
| 12     | div M       | divide accumulator with contents of location M                       |
| 13     | lda M       | load accumulator with M                                              |
| 14     | inc         | increment accumulator                                                |
| 15     | dec         | decrement accumulator                                                |
| 16     | sti M       | store accumulator in location pointed to by M                        |
| 17     | ldi M       | load accumulator with contents of location pointed to by M           |
| 18     | putc        | write the contents of the accumulator as an ASCII character          |
| 19     | getc        | read a character from the input as an ASCII character                |
| 20     | puts        | print the contents starting from the accumulator until a NUL is read |
| 21     | putn        | like `puts` but with a trailing newline                              |
| 22     | lj          | set the accumulator to the value of the j register (A = J)           |
| 23     | ret         | set the program counter to the value of the j register (PC = J)      |

## Assembler directives ("pseudo-operations")
| Instruction | Meaning                                                    |
| :-:         | :-:                                                        |
| const C     | define a variable with default value C (0 if C is omitted) |
| blk C       | fill C cells with 0                                        |
| string S    | a null-terminated ASCII-encoded string                     |

Not really operations, but make inline constants easy.
```text
# Declare array "foo" of size 10
foo blk 10
# Declare variable "bar" with default value 5
bar const 5
# Declare string "msg" with contents "hello, world!"
msg string "hello, world!"
```
## Simple benchmarks
Mostly qualitative, not rigorous benchmarks.  `benchmark.asm` and
`fbenchmark2.asm` perform the same computation (decrement a number
from 99999 to 0, 100 times), but `benchmark.asm` uses the accumulator
to hold the value, whereas `benchmark2.asm` uses a memory cell.
`benchmark.asm` runs in 60% of the instructions and takes 70% of the time
compared to `benchmark2.asm`.

```text
$ time awk -f vm benchmark.asm 
...
Stopping after 30000499 instructions.  Program counter at 12.
awk -f vm benchmark.asm  26.91s user 0.05s system 99% cpu 26.972 total

$ time awk -f vm benchmark2.asm
...
Stopping after 50000597 instructions.  Program counter at 13.
awk -f vm benchmark2.asm  36.26s user 0.00s system 99% cpu 36.258 total
```
- `benchmark.asm` (26.91/30000499) ≈ (0.897 µs/cycle)
- `benchmark2.asm` (36.26/50000597) ≈ (0.725 µs/cycle)

Using 0.725 µs/cycle, we find that the VM runs at a speed of 1.38
MHz.  Not bad for 150 lines of Awk!

## Future plans
### Enhancing current ISA
- Multiplication, division
- Memory indirection operations
- Multiple registers
- Reading/writing ASCII characters
- Stacks (push, pop)
  - Subroutine calls


### Potential targets
- MIX computer (from _The Art of Computer Programming_ by Donald Knuth)
- Z80 (without interrupts)
- [R216](https://lbphacker.pw/powdertoy/R216/manual.md)
