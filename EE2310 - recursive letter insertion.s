# EE2310  - recursive letter insertion program
#
# After a lower case letter is input the "find" loop goes bit-by-bit through "str"
# until it finds the first instance in "str" of the letter to be inserted. "toback"
# then drives down "str" until the null-terminator is reached. For each byte
# "toback" touches the first line of "shift" is put on the stack. "shift" moves the
# $t1 pointer upstream 1 byte then moves the byte at address $t1 to 
# downstream address $t1+1. By using the $ra values stored on the stack 
# "shift" works upstream towards the insertion point intil the "j insert" call is
# loaded. "insert" is responsible for storing the input character at the correct
# address (address stored in $t0).
#
#	$a0 - input/inserting character
#	$t0 - pointer to current "find" byte / insertion address
#	$t1 - pointer to current character's pre-shift address
#	$t2 - downstream compare character / character being shifted
#
#	additional features (not included in lab instructions):
#		- inputting "C" will terminate the program
#		- invalid character inputs will be ignored			 

		.text
main:	la $t0,str
		la $a0,0x0a			#CR/LF
		li $v0,11
		syscall
		li $v0,12			#character input from keyboard
		syscall
		move $a0,$v0		
		beq $a0,0x50,print		#print current string when "P" is input
		beq $a0,0x43,exit		#end program when "C" is input
		blt $a0,0x61,main		#ignore input if not lower case letter
		bgt $a0,0x7a,main		#ignore input if not lower case letter

find:	lb $t2,0($t0)			#Looks for first instance of a character
		bne $a0,$t2,next		#  that's the same as the new character.
		move $t1,$t0
		jal toback			#j insert will be at "bottom" of stack		
		j insert
next:	addi $t0,$t0,1		#go to next byte of str
		j find
	
toback:	sub $sp,$sp,4			#$sp points to last filled spot on stack
		sw $ra,0($sp)			#store contents of $ra on top of stack
		lb $t2,0($t1)
		beqz $t2,shift
		addi $t1,$t1,1
		jal toback		#setup for shift's recursive calls
shift:	sub $t1,$t1,1
		lb $t2,0($t1)
		sb $t2,1($t1)		#store letter 1 byte downstream
		lw $ra,0($sp)		
		addi $sp,$sp,4
		jr $ra			#recursive call

insert:	sb $a0,0($t0)			#stores input letter
		j main

print:	la $a0,0x0a			#CR/LF
		li $v0,11
		syscall
		la $a0,str
		li $v0,4
		syscall
		j main

exit:	li $v0,10
		syscall

		.data
str:		.asciiz "abcdefghijklmnopqrstuvwxyz"
nulls:	.space 30