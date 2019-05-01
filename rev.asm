;; Reverse a user's string.
get_s
   getc
   jz print_rev     ;; Reached end
   sti s_ptr
   ld s_ptr
   inc
   st s_ptr
   ld c
   dec              ;; Decrement c
   jz print_rev     ;; Out of characters.
   st c
   j get_s

print_rev
   lda s
   sub s_ptr
   ;; c contains number of characters to print.
print_loop
   st c
   ld s_ptr
   dec
   st s_ptr
   ldi s_ptr
   putc
   ld c
   inc
   jz done
   j print_loop
done
   halt

s_ptr const s
s blk 32
msg1 string "Enter a string to reverse: ""
c const 0
