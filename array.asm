;;; reads a list of numbers (max 10 numbers), stores it in memory and
;;; prints it out


loop
    ld count
    jz done_read
    dec
    st count
    get
    jz done_read
    sti arrayptr
    ld arrayptr
    inc
    st arrayptr
    j loop
    

done_read
    lda array
    st arrayptr
    
print_loop
    ldi arrayptr
    jz done
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

