# drawboard.asm
# Handles all UI drawing for Binary Game

.data
# Main Menu
menu_top:      .asciiz "+========================================+\n" 
menu_title:    .asciiz "|              BINARY GAME              |\n"
menu_div:      .asciiz "|---------------------------------------|\n"
menu_opt1:     .asciiz "|  1) Binary  ->  Decimal               |\n"
menu_opt2:     .asciiz "|  2) Decimal ->  Binary                |\n"
menu_opt0:     .asciiz "|  0) Quit                              |\n"
menu_bottom:   .asciiz "|---------------------------------------|\n"
menu_select:   .asciiz "|  Select Mode:                         |\n"
menu_end:      .asciiz "+========================================+\n"

# Board
board_top:       .asciiz "+========================================+\n"
board_title:     .asciiz "|             BINARY  ARENA              |\n"
board_div:       .asciiz "|----------------------------------------|\n"
board_hint:      .asciiz "|  Answer the questions to progress!     |\n"
board_end:       .asciiz "+========================================+\n"

# Dynamic level text
board_level_pre:  .asciiz "|               Level: " #spaces before 'Level:'
board_level_post: .asciiz "                 |\n" # spaces after number


# Question
qbox_top:      .asciiz "+------------------------------+\n" 
qbox_label1:   .asciiz "| Question " # label start before number
qbox_label2:   .asciiz " of Level " # middle label text
qbox_end:      .asciiz "        |\n" # end of line for labels
qbox_bottom:   .asciiz "+------------------------------+\n"

.text
# Draw Menu - prints the main select menu
DrawMenu:
	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_top # load top border
	syscall

	li $v0, SysPrintString
	la $a0, menu_title # load menu title
	syscall

	li $v0, SysPrintString
	la $a0, menu_div # divider line
	syscall

	li $v0, SysPrintString
	la $a0, menu_opt1 # print option 1
	syscall

	li $v0, SysPrintString
	la $a0, menu_opt2 # print option 2
	syscall

	li $v0, SysPrintString
	la $a0, menu_opt0 # print option 0
	syscall

	li $v0, SysPrintString
	la $a0, menu_bottom # another divider
	syscall

	li $v0, SysPrintString
	la $a0, menu_select # prompt for mode
	syscall

	li $v0, SysPrintString
	la $a0, menu_end # print bottom border
	syscall

	jr $ra # return to main


# DrawBoard — prints the arena header for each level
# Input: a0 = current level number
DrawBoard:
	addi $sp, $sp, -16 # create stack frame
	sw $ra, 12($sp) # save return address
	sw $a0, 8($sp) # save level number

	# print arena box
	li $v0, SysPrintString
	la $a0, board_top
	syscall

	li $v0, SysPrintString
	la $a0, board_title # print "BINARY ARENA"
	syscall

	li $v0, SysPrintString
	la $a0, board_div # print divider line
	syscall

	# load level number for printing
	lw $t0, 8($sp) # t0 = current level
	li $t1, 10 # compare threshold (for formatting)

	li $v0, SysPrintString # print level line
	la $a0, board_level_pre
	syscall

	move $a0, $t0 # level number
	li $v0, SysPrintInt
	syscall

	li $v0, SysPrintString
	la $a0, board_level_post
	syscall

done_print_level:
	li $v0, SysPrintString
	la $a0, board_hint # print "Answer the questions..."
	syscall

	li $v0, SysPrintString
	la $a0, board_end # bottom border
	syscall

	lw $ra, 12($sp) # restore return address
	addi $sp, $sp, 16 # free stack frame
	jr $ra # return to caller

# DrawQuestionBox — prints the question header
# Input: a0 = question number, a1 = level number
DrawQuestionBox:
	addi $sp, $sp, -8 # allocate small stack
	sw $a0, 4($sp) # save question number
	sw $a1, 0($sp) # save level number

	li $v0, SysPrintString
	la $a0, qbox_top # print top border
	syscall

	li $v0, SysPrintString
	la $a0, qbox_label1 # print "Question "
	syscall

	lw $a0, 4($sp) # load question number
	li $v0, SysPrintInt # print integer
	syscall

	li $v0, SysPrintString
	la $a0, qbox_label2 # print " of Level "
	syscall

	lw $a0, 0($sp) # load level number
	li $v0, SysPrintInt
	syscall

	li $v0, SysPrintString
	la $a0, qbox_end # print line end
	syscall

	li $v0, SysPrintString
	la $a0, qbox_bottom # print bottom border
	syscall

	addi $sp, $sp, 8 # free stack
	jr $ra # return
