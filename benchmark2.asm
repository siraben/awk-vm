;; Decrementing from memory
        
start
        ld foo
        dec
        st foo
        jz done
        j start
done
        ld count
        dec
        jz bye
        st count
        lda 0
        st foo
        j start
bye
        halt
foo const 0
count const 100
