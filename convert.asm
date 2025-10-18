# convert.asm
# Integer to Binary Conversion Utilities
# Binary to Integer Conversion Utilities

.text

# Integer to Binary Conversion
int_to_bin8:
	move $t0, $a0 # t0 = integer value
	move $t1, $a1 # t1 = pointer to buffer
	li $t2, 128 # t2 = 2^7 the starting mask
	li $t3, 0 # t3 = counter

bit_loop:
	beq $t3, 8, done_bits # stop after 8 bits
	sub $t4, $t0, $t2 # test subtraction
	slt $t5, $t4, $zero # t5=1 if t0<t2
	bne $t5, $zero, write0 # if less then write '0'
	li $t6, 49 # ASCII '1'
	sb $t6, 0($t1) # store '1'
	sub $t0, $t0, $t2 # subtract current power
	j next_bit # jump

write0:
	li $t6, 48 # ASCII '0'
	sb $t6, 0($t1) # store '0'

next_bit:
	addi $t1, $t1, 1 # advance pointer
	srl $t2, $t2, 1 # divide mask by 2
	addi $t3, $t3, 1 # increment bit counter
	j bit_loop # repeat

done_bits:
	sb $zero, 0($t1) # null terminate string
	jr $ra # return to caller



# Binary to Integer Conversion
bin8_to_int:
	move $t0, $a0 # t0 = pointer to string
	li $t1, 0 # t1 = accumulator
	li $t2, 0 # t2 = counter

b2i_loop:
	lb $t3, 0($t0) # load current char
	beq $t3, $zero, b2i_done # stop at null
	beq $t3, 10, b2i_done # stop at newline
	sll $t1, $t1, 1 # shift accumulator left
	addi $t3, $t3, -48 # convert ASCII to 0/1
	add $t1, $t1, $t3 # add current bit
	addi $t0, $t0, 1 # advance pointer
	addi $t2, $t2, 1 # increment counter
	j b2i_loop # continue

b2i_done:
	move $v0, $t1 # return accumulated value
	jr $ra # return
