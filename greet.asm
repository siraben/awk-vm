;; Ask for a user's name

   lda msg1
   puts

get_name
   getc
   jz say_hi     ;; Reached end
   sti name_ptr
   ld name_ptr
   inc
   st name_ptr
   ld chars
   dec
   st chars
   jz say_hi     ;; Out of characters.
   j get_name

say_hi
   lda 0         ;; null-terminate
   sti name_ptr
   lda msg2
   puts
   lda name
   puts
   lda 46
   putc
   halt

chars const 32
name_ptr const name
name blk 32
msg1 string "What is your name? (Press RET twice to enter) "
msg2 string "Hello, "

