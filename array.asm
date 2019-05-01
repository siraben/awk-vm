;;; reads a list of numbers (max 10 numbers), stores it in memory and
;;; prints it out


loop
    ld count
    jz done_read
    dec
    st count
    get
    sti arrayptr
    ld arrayptr
    inc
    st arrayptr
    j loop
    

done_read
    lda 10
    st count
    lda array
    st arrayptr
    
print_loop
    ld count
    jz done
    dec
    st count
    ldi arrayptr
    put
    ld arrayptr
    inc
    st arrayptr
    j print_loop
    
done
    halt
    
count const 10
arrayptr const array
array blk 10

