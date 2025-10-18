# io_utils.asm
# Binary input validation utility
# Checks if input string is exactly 8 chars of 0 or 1

.text

# v0=1 valid, 0 invalid
validate_bin8:
	move $t0, $a0 # t0 = pointer to input string
	li $t1, 0 # t1 = length counter

vb_loop:
	lb $t2, 0($t0) # load current char
	beq $t2, $zero, vb_end # stop at null terminator
	beq $t2, 10, vb_end # stop at newline
	li $t3, 48 # ASCII '0'
	li $t4, 49 # ASCII '1'
	slt $t5, $t2, $t3 # t5=1 if char < '0'
	bne $t5, $zero, vb_bad # if true then it is invalid
	slt $t6, $t4, $t2 # t6=1 if char > '1'
	bne $t6, $zero, vb_bad # if true then its invalid
	addi $t1, $t1, 1 # count character
	addi $t0, $t0, 1 # advance pointer
	j vb_loop # repeat

vb_end:
	li $t7, 8 # expected length
	bne $t1, $t7, vb_bad_len # if not 8 invalid
	li $v0, 1 # valid = 1
	jr $ra # return success

vb_bad_len:
	li $v0, 0 # invalid = 0
	jr $ra # return fail

vb_bad:
	li $v0, 0 # invalid character
	jr $ra # return fail
