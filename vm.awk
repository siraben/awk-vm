BEGIN {
    # Initialize ASCII table.
    for(n = 0; n < 256; n++) {
        ord[sprintf("%c",n)] = n
    }

    # Check if the file exists
    srcfile = ARGV[1]
    if (system("test -f " srcfile)) {
        printf("File %s doesn't exist!\n", srcfile)
        exit(1)
    }

    tempfile = "asm.temp"
    ARGV[1] = ""

    # Backwards compatible ISA with the VM in the `AWK programming language'
    n = split("const get put ld st add sub jpos jz j halt\
               mul div lda inc dec sti ldi putc getc puts putn lj ret", x)

    for (i = 1; i <= n; i++) {
        op[x[i]] = i - 1
    }

    printf("Pass 1...")
    FS = "[ \t]+"

    while ((stat = getline < srcfile) > 0) {
        sub(/#.*/, "")
        # alternate comment syntax
        sub(/;.*/, "")
        # blk directive
        symtab[$1] = nextmem
        if ($2 == "blk") {
            for(i = 0; i < $3; i++) {
                print sprintf("r%d 0", extraRegs++) > tempfile
            }
            nextmem += i
            blkcount++
        # string directive
        } else if ($2 == "string") {
            while (match($0,/"[^"]*"/)){
                s = substr($0, RSTART + 1, RLENGTH - 2)
                sub(/"[^"]*"/,"")
                found = 1
                split(s, x, "")
                # Can't write for (i in s) because of implementation
                # differences in associative array traversal order.
                for (i = 1; i <= length(s); i++) {
                    print sprintf("const_%.2d_%.2d %.3d", blkcount, j++, ord[x[i]]) > tempfile
                }
                # NUL at end of string
                print sprintf("const_%.2d_%.2d %.3d", blkcount++, j++, 0) > tempfile
                nextmem += j
            }

            if (!found) {
                printf("ERROR: Could not read string at address %d\n", nextmem)
                exit(1)
            }
        } else if ($2 != "") {
            print $2 " " $3 > tempfile
            nextmem++
        }
    }
    close(tempfile)

    printf("done\nPass 2...")
    nextmem = 0
    if (DEBUG) print ""
    while (getline < tempfile > 0) {
        if ($2 !~ /^[0-9]*$/) {
            $2 = symtab[$2]
        }
        mem[nextmem] = 1000 * op[$1] + $2
        if (DEBUG && (b = mem[nextmem])) {
            printf("%3d: %.5d %s %s\n", nextmem, b, $0, is_ascii(b) ? sprintf(" %c", b): "")
        }
        nextmem++
    }
    printf("done. %d bytes total\nRunning program...\n", nextmem)

    # bytecode interpreter
    acc = 0
    # address after last jump instruciton
    jaddr = 0
    stdin = ""
    firstread = 1
    for (pc = 0; pc >= 0;) {
        cycles++
        addr = mem[pc] % 1000
        code = int(mem[pc++] / 1000)
        if      (code == op["get"])  { getline acc; if (!(acc ~ /[+-]?[0-9]+/)) { printf("Failed to read number.\n"); acc = 0}}
        else if (code == op["put"])  { print (acc + 0) }
        else if (code == op["st"])   { mem[addr] = acc }
        else if (code == op["ld"])   { acc = mem[addr]                  % 100000 }
        else if (code == op["add"])  { acc = (acc + mem[addr])          % 100000 }
        else if (code == op["sub"])  { acc = (100000 + acc - mem[addr]) % 100000 }
        else if (code == op["jpos"]) { if (acc >  0) { jaddr = pc; pc = addr } }
        else if (code == op["jz"])   { if (acc == 0) { jaddr = pc; pc = addr } }
        else if (code == op["j"])    { jaddr = pc; pc = addr }
        else if (code == op["halt"]) { halt(pc, mem) }
        # Additional instructions
        else if (code == op["mul"])  { acc = (acc * mem[addr])          % 100000 }
        else if (code == op["div"])  { acc = int(acc / mem[addr])       % 100000 }
        else if (code == op["lda"])  { acc = addr }
        else if (code == op["inc"])  { acc = (acc + 1)                  % 100000 }
        else if (code == op["dec"])  { acc = (acc + 99999)              % 100000 }
        else if (code == op["sti"])  { mem[mem[addr]] = acc }
        else if (code == op["ldi"])  { acc = mem[mem[addr]] }
        else if (code == op["putc"]) { printf("%c", acc) }
        else if (code == op["getc"]) { getc() }
        else if (code == op["puts"]) { while(mem[acc]) { printf("%c", mem[acc++]) } }
        else if (code == op["putn"]) { while(mem[acc]) { printf("%c", mem[acc++]) } print "" }
        else if (code == op["lj"])   { acc = jaddr }
        else if (code == op["ret"])  { pc = jaddr }
        else { printf("INVALID OPCODE: %d\n", code); exit(1) }
    }
}

function getc() {
    if (!stdin) {
        if (firstread) {
            getline stdin
        } else {
            acc = 0
        }
        firstread = !firstread
    } else {
        acc = ord[substr(stdin, 1, 1)]
        stdin = substr(stdin, 2)
    }
}

function halt(pc, mem) {
    printf("\nStopping after %d instructions.  Program counter at %d.\n", cycles, pc)
    if (!DEBUG) exit(0)
    print "Memory:\n-------------"
    for (i = 1; i <= nextmem; i++) {
        # = is not a typo, assignment to a variable returns the value
        if (b = mem[i]) { printf("%3d: %.5d%s\n", i, b, is_ascii(b) ? sprintf(" %c", b): "") }
    }
    printf("-------------\nMemory ends at address: %d\n", i)
    exit(0)
}

function is_ascii(x) { return (x >= 32 && x <= 177)}
