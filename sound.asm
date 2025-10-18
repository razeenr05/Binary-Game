# sound.asm
# Handles sounds and noises for the binary game

.text

PlayCorrectTone:
    li $v0, 31 # syscall to play tone
    li $a0, 72 # high frequency 
    li $a1, 300 # duration = 150 ms
    li $a2, 100 # volume
    li $a3, 63 # instrument
    syscall
    jr $ra # return to caller

PlayWrongTone:
    li $v0, 31 # syscall to play tone
    li $a0, 48 # low frequency
    li $a1, 300 # duration = 300 ms
    li $a2, 100 # volume
    li $a3, 63 # instrument	
    syscall
    jr $ra # return to caller