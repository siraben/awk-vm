;; Simulating a stack and subroutine calls

   j say_msg1
   j say_msg2
   lda 1
   j push
   lda 2
   j push
   lda 3
   j push
   j pop
   put
   j pop
   put
   j pop
   put
   halt

say_msg1
   lda msg1
   putn
   ret

say_msg2
   lda msg2
   putn
   ret

;; Push a value into the stack from the accumulator
push
   sti sp
   ld sp
   inc
   st sp
   ret

;; Pop a value into the accumulator
pop
   ld sp
   dec
   st sp
   ldi sp
   ret

sp const stack_start
stack_start blk 10
msg1 string "message 1"
msg2 string "message 2"
