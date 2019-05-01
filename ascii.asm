# Reads two numbers: i j
# Print the ASCII table from i to j.

        get
        st i
        get
loop
        st j
        jz done
        ld i
        putc
        inc
        st i
        ld j
        dec
        j loop
done
        halt

i const
j const
