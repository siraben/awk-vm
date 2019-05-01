;; Factorial

   get
fact_loop
   jz done
   st c
   ld c

   mul acc
   st acc
   ld c
   dec
   j fact_loop

done
   ld acc
   put
   halt

acc const 1
c const 0
