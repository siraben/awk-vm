;; Decrementing from the accumulator

        lda 0
start
        dec
        jz done
        j start
done
        halt

done
        ld count
        dec
        jz bye
        st count
        lda 0
        j start
bye
        halt
count const 100
