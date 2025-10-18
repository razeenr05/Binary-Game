# Name: Razeen Rahman
# Course: CS2340.004
# Description: A MIPS assembly program that runs an interactive Binary Game 
#              where players convert numbers between binary and decimal 
#              through multiple levels with randomized questions.

# main.asm 
# Controls the overall Binary Game logic which include the main menu
# level progression, random question generation, and user input handling

.include "SysCalls.asm"

.data
nl: .asciiz "\n" # newline for output spacing
badOpt: .asciiz "Invalid option. Try again.\n" # bad menu choice message
b2dPrompt: .asciiz "Binary: " # binary label for display
askDec: .asciiz "Enter the decimal value (0..255): " # decimal input prompt
d2bPrompt: .asciiz "Decimal: " # decimal label for display
askBin: .asciiz "Enter an 8-bit binary (e.g., 01011010): " # binary input prompt
okMsg: .asciiz "Correct!\n" # message shown when answer is right
noMsg: .asciiz "Not quite. Correct answer: " # shown when user is wrong
retryMsg: .asciiz "Invalid input. Please try again.\n" # for invalid format
buf: .space 16 # temporary input buffer
bufLen: .word 16 # buffer length for reading
binStr: .space 9 # space for converted binary string
ansStr: .space 9 # space for correct binary string
twofivefive: .word 255 # constant for upper limit check
maxLvl: .word 10 # total number of levels in the game

.text

main:
	# save registers on stack so they can be restored later
	addi $sp, $sp, -24 # make space for 6 saved registers
	sw $ra, 20($sp) # store return address
	sw $s0, 16($sp) # store mode
	sw $s1, 12($sp) # store level
	sw $s2, 8($sp) # store random number
	sw $s3, 4($sp) # store question counter

menu_loop:
	jal DrawMenu # call function to draw menu screen
	li $v0, SysReadInt # prepare to read integer input
	syscall # read user choice (1, 2, or 0)
	move $s0, $v0 # store mode in $s0

	beq $s0, $zero, exit_program # if user entered 0, quit
	li $t0, 1
	beq $s0, $t0, start_game # if user chose 1 then start Binary to Decimal
	li $t0, 2
	beq $s0, $t0, start_game # if user chose 2 then start Decimal to Binary

	# invalid input case
	li $v0, SysPrintString # print error message
	la $a0, badOpt
	syscall
	j menu_loop # reshow menu

start_game:
	li $s1, 1 # initialize level counter to 1

level_loop:
	move $a0, $s1 # pass current level number
	jal DrawBoard # draw the level header/arena UI

	move $s3, $s1 # set number of questions = level number
	li $t8, 1 # current question number starts at 1

question_loop:
	# draw question header for current level
	move $a0, $t8 # question number
	move $a1, $s1 # level number
	jal DrawQuestionBox # draw question box header

	# generate random number 0–255
	li $v0, SysRandIntRange # system call for random number
	li $a0, 0 # min bound
	li $a1, 256 # max bound
	syscall # perform random generation
	move $s2, $a0 # save random number into $s2

	# decide which game mode to use
	li $t0, 1
	beq $s0, $t0, binary_to_decimal # mode 1: binary to decimal
	li $t0, 2
	beq $s0, $t0, decimal_to_binary # mode 2: decimal to binary
	j exit_program # safety fallback

binary_to_decimal:
	move $a0, $s2 # move random number to $a0
	la $a1, binStr # point $a1 to binary string buffer
	jal int_to_bin8 # convert int to 8-bit binary string

	# print the binary prompt and value
	li $v0, SysPrintString
	la $a0, b2dPrompt
	syscall
	li $v0, SysPrintString
	la $a0, binStr
	syscall
	li $v0, SysPrintString
	la $a0, nl
	syscall

ask_dec:
	# prompt user to enter decimal
	li $v0, SysPrintString
	la $a0, askDec
	syscall
	li $v0, SysReadInt
	syscall
	move $t0, $v0 # store user’s input

	# validate that input is between 0–255
	slt $t2, $t0, $zero # is negative?
	bne $t2, $zero, bad_dec # invalid jump
	lw $t1, twofivefive # load 255 constant
	slt $t2, $t1, $t0 # is greater than 255?
	bne $t2, $zero, bad_dec # invalid jump
	j check_b2d # valid then go check answer

bad_dec:
	# print invalid input message
	li $v0, SysPrintString
	la $a0, retryMsg
	syscall
	j ask_dec # ask again

check_b2d:
	bne $t0, $s2, wrong_dec # if wrong show correct
	j correct_answer # if right move on

wrong_dec:
	# show correct decimal answer
	li $v0, SysPrintString
	la $a0, noMsg
	syscall
	li $v0, SysPrintInt
	move $a0, $s2 # move correct number to print
	syscall
	li $v0, SysPrintString
	la $a0, nl
	syscall
	jal PlayWrongTone # play wrong noise
	j next_question # go next

decimal_to_binary:
	# show decimal prompt with number
	li $v0, SysPrintString
	la $a0, d2bPrompt
	syscall
	li $v0, SysPrintInt
	move $a0, $s2
	syscall
	li $v0, SysPrintString
	la $a0, nl
	syscall

ask_bin:
	# ask user for 8-bit binary
	li $v0, SysPrintString
	la $a0, askBin
	syscall
	li $v0, SysReadString # read binary string
	la $a0, buf
	lw $a1, bufLen
	syscall

	# validate input format
	la $a0, buf # pass input buffer
	jal validate_bin8 # ensure 8 bits (0s/1s)
	beqz $v0, bad_bin # invalid so retry
	la $a0, buf # pass binary string
	jal bin8_to_int # convert to integer
	move $t0, $v0 # store result
	bne $t0, $s2, wrong_bin # mismatch means wrong
	j correct_answer # otherwise correct

bad_bin:
	# user input not valid binary
	li $v0, SysPrintString
	la $a0, retryMsg
	syscall
	j ask_bin # retry input

wrong_bin:
	# show correct binary equivalent
	move $a0, $s2 # move int to convert
	la $a1, ansStr # buffer for binary
	jal int_to_bin8 # int to binary
	li $v0, SysPrintString
	la $a0, noMsg
	syscall
	li $v0, SysPrintString
	la $a0, ansStr
	syscall
	li $v0, SysPrintString
	la $a0, nl
	syscall
	jal PlayWrongTone # play wrong noise
	j next_question # next question

correct_answer:
	# print “Correct!” message
	li $v0, SysPrintString
	la $a0, okMsg
	syscall
	jal PlayCorrectTone # play correct sound

next_question:
	addi $t8, $t8, 1 # increment question number
	addi $s3, $s3, -1 # reduce remaining question count
	bgt $s3, $zero, question_loop # if > 0 then more questions

	addi $s1, $s1, 1 # next level
	lw $t2, maxLvl # load maximum level
	ble $s1, $t2, level_loop # continue if not done
	j menu_loop # otherwise return to main menu

exit_program:
	# restore saved registers
	lw $ra, 20($sp) # restore return address
	lw $s0, 16($sp) # restore s0 
	lw $s1, 12($sp) # restore s1
	lw $s2, 8($sp) # restore s2
	lw $s3, 4($sp) # restore s3
	addi $sp, $sp, 24 # release stack frame
	li $v0, SysExit
	syscall # terminate program

.include "drawboard.asm"
.include "convert.asm"
.include "linevalidation.asm"
.include "sound.asm"