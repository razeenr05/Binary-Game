# drawboard.asm
# Handles all UI drawing for Binary Game

.data
# Main Menu
menu_top:      .asciiz "+========================================+\n" # top border of the main menu
menu_title:    .asciiz "|              BINARY GAME              |\n" # title text for the main menu
menu_div:      .asciiz "|---------------------------------------|\n" # horizontal divider line
menu_opt1:     .asciiz "|  1) Start Game                        |\n" # option to start the game
menu_opt0:     .asciiz "|  0) Quit                              |\n" # option to quit the program
menu_bottom:   .asciiz "|---------------------------------------|\n" # bottom divider before prompt
menu_select:   .asciiz "|  Select Option:                       |\n" # input prompt for user selection
menu_end:      .asciiz "+========================================+\n" # bottom border of the main menu

# Board
board_top:       .asciiz "+========================================+\n" # top border of the level board
board_title:     .asciiz "|             BINARY  ARENA              |\n" # header title for game arena
board_div:       .asciiz "|----------------------------------------|\n" # horizontal divider line
board_hint:      .asciiz "|  Answer the questions to progress!     |\n" # instruction line for players
board_end:       .asciiz "+========================================+\n" # bottom border of the level board

# Dynamic level text
board_level_pre:  .asciiz "|               Level: " # left-aligned text before level number
board_level_post: .asciiz "                 |\n" # right padding and border after level number

# Question
qbox_top:      .asciiz "+------------------------------+\n" # top border of question box
qbox_label1:   .asciiz "| Question " # label before question number
qbox_label2:   .asciiz " of Level " # label between question and level number
qbox_end:      .asciiz "        |\n" # trailing spaces and right border
qbox_bottom:   .asciiz "+------------------------------+\n" # bottom border of question box


.text
# Draw Menu - prints the main select menu
DrawMenu:
	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_top # load top border
	syscall #execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_title # load menu title
	syscall #execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_div # divider line
	syscall #execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_opt1 # print option 1
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_opt0 # print option 0
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_bottom # another divider
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_select # prompt for option
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, menu_end # print bottom border
	syscall #execute

	jr $ra # return to main


# DrawBoard — prints the arena header for each level
# Input: a0 = current level number
DrawBoard:
	addi $sp, $sp, -16 # create stack frame
	sw $ra, 12($sp) # save return address
	sw $a0, 8($sp) # save level number

	# print arena box
	li $v0, SysPrintString # set syscall for print_string
	la $a0, board_top # top of the board
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, board_title # print "BINARY ARENA"
	syscall #execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, board_div # print divider line
	syscall #execute

	# load level number for printing
	lw $t0, 8($sp) # t0 = current level

	li $v0, SysPrintString # print level line start
	la $a0, board_level_pre # spaces in front and level
	syscall #execute

	move $a0, $t0 # level number
	li $v0, SysPrintInt # print level number
	syscall #execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, board_level_post # post spaces + right border
	syscall #execute

done_print_level:
	li $v0, SysPrintString # set syscall for print_string
	la $a0, board_hint # print "Answer the questions..."
	syscall #execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, board_end # bottom border
	syscall # execute

	lw $ra, 12($sp) # restore return address
	addi $sp, $sp, 16 # free stack frame
	jr $ra # return to caller


# DrawQuestionBox — prints the question header
# Input: a0 = question number, a1 = level number
DrawQuestionBox:
	addi $sp, $sp, -8 # allocate small stack
	sw $a0, 4($sp) # save question number
	sw $a1, 0($sp) # save level number

	li $v0, SysPrintString # set syscall for print_string
	la $a0, qbox_top # print top border
	syscall

	li $v0, SysPrintString # set syscall for print_string
	la $a0, qbox_label1 # print "Question "
	syscall # execute

	lw $a0, 4($sp) # load question number
	li $v0, SysPrintInt # print integer
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, qbox_label2 # print " of Level "
	syscall # execute

	lw $a0, 0($sp) # load level number
	li $v0, SysPrintInt # print integer
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, qbox_end # print line end
	syscall # execute

	li $v0, SysPrintString # set syscall for print_string
	la $a0, qbox_bottom # print bottom border
	syscall # execute

	addi $sp, $sp, 8 # free stack
	jr $ra # return
