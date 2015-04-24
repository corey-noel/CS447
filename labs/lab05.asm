.data 
	names: 		.asciiz "steve", "john", "chelsea", "julia", "ryan"
	ages:		.byte	20, 25, 22, 21, 23
	
	ageMsg:		.asciiz	"Age is: "
	notFoundMsg:	.asciiz	"Not found!\n"
	newLine:	.asciiz "\n"
	
	input:		.space 64
	
.text
	la $a0, input
	addi $a1, $zero, 64
	jal _readString
	la $s0, input			# s0 = input
	add $s1, $zero, $zero		# s1 = index
	la $s2, names			# s2 = names
	
mainLoop:
	addi $t0, $zero, 5
	slt $t1, $s1, $t0
	beq $t1, $zero, notFound	# while index < 5
	add $a0, $s0, $zero
	add $a1, $s2, $zero
	jal _strEqual
	bne $v0, $zero, found		# if match, jump to found
	addi $s1, $s1, 1
nextStringLoop:
	addi $s2, $s2, 1
	lb $t2, ($s2)
	beq $t2, $zero, nextStringDone
	j nextStringLoop
nextStringDone:
	addi $s2, $s2, 1
	j mainLoop
	
notFound:
	addi $v0, $zero, 4
	la $a0, notFoundMsg
	syscall

	addi $v0, $zero, 10
	syscall
	
found:
	addi $v0, $zero, 4
	la $a0, ageMsg
	syscall
	
	la $a0, ages
	add $a1, $s1, $zero
	jal _lookUpAge
	
	add $a0, $v0, $zero
	addi $v0, $zero, 1
	syscall
	
	addi $v0, $zero, 4
	la $a0, newLine
	syscall
	
	addi $v0, $zero, 10
	syscall
	
	
	
	
 # _StrEqual
 # Checks the equality of two null terminated strings
 #
 # Params:
 # $a0, $a1 - addresses of strings
 #
 # Returns: 
 # $v0 - 1 if equal, 0 if unequal
_strEqual:
	lb $t0, 0($a0)
	lb $t1, 0($a1)
	sub $t2, $t0, $t1
	bne $t2, $zero, strEqual_False
	beq $t1, $zero, strEqual_True
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j _strEqual
	
strEqual_False:
	addi $v0, $zero, 0
	jr $ra
	
strEqual_True:
	addi $v0, $zero, 1
	jr $ra
	
	
 # _LookUpAge
 # Gets a given index from the age array
 #
 # Params: 
 # $a0 - address of array
 # $a1 - index
 #
 # Returns
 # $v0 - value at that index of the array
_lookUpAge: 
	add $a0, $a0, $a1
	lb $v0, ($a0)
	jr $ra
	
 
 # _readString: 
 # for reading a string from the user 
 # trims newline characters before null terminator
 # non-leaf function
 # uses t0, t1, t2, t3, v0
 #
 # param: 
 # a0: the address of a buffer to hold the string
 # a1: the length of the buffer a0
_readString:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $t0, $a0, $zero			# t0 is buffer address
	add $t1, $a1, $zero			# t1 is buffer length
	
	add $a0, $t0, $zero			# read in string
	add $a1, $t1, $zero
	addi $v0, $zero, 8
	syscall
	
	add $a0, $t0, $zero			# set buffer address as arg		
	sw $t0, 4($sp)				# store buffer address
	sw $t1, 8($sp)				# store buffer length
	jal _strLength				# get length of input string
	lw $t1, 8($sp)				# load buffer length
	lw $t0, 4($sp)				# load buffer address
	add $t2, $v0, $zero			# save length of string
	
	add $t3, $t2, $t0			# get address before null character
	
	sb $zero, -1($t3)			# set it to a null char
	
	lw $ra, 0($sp)				# return
	addi $sp, $sp, 4
	jr $ra
	
	
	
 # _strLength: 
 # for finding the length of null terminated strings
 # leaf function
 # uses t0, t1, t2
 #
 # param:
 # a0: address to a string
 #
 # returns:
 # v0: the length of the string in a0
_strLength:
	add $t0, $a0, $zero			# t0 holds string address
	add $t1, $zero, $zero			# t1 is length counter 
	add $t2, $zero, $zero			# t2 holds the byte at the address
	
strLen_loop:
	lbu $t2, ($t0)				# load char from memory
	beq $t2, $zero, strLen_end		# check if it's a null terminator
	addi $t0, $t0, 1			# add 1 to address
	addi $t1, $t1, 1			# add 1 to counter
	j strLen_loop				# loop again
	
strLen_end:
	add $v0, $t1, $zero			# return counter
	jr $ra
	
