.data
	readBuffer: 	.space 		64
	writeBuffer: 	.space 		64

	enterMsg: 	.asciiz		"Enter a string: "
	lengMsg1:	.asciiz		"This string has "
	lengMsg2:	.asciiz		" characters.\n"
	startMsg:	.asciiz		"Specify start index: "
	endMsg:		.asciiz		"Specify end index: "
	subMsg: 	.asciiz		"Your substring is: "
	
	newLine:	.asciiz		"\n"
	
.text
	addi $v0, $zero, 4		# print enterMsg
	la $a0, enterMsg
	syscall
	
	la $a0, readBuffer		# read in string
	addi $a1, $zero, 64
	jal _readString
	
	la $a0, readBuffer		# s0 = string length
	jal _strLength
	add $s0, $v0, $zero
	
	addi $v0, $zero, 4		# print out lengMsg1
	la $a0, lengMsg1
	syscall
	
	addi $v0, $zero, 1		# pring string length
	add $a0, $s0, $zero
	syscall
	
	addi $v0, $zero, 4		# print out lengMsg2
	la $a0, lengMsg2
	syscall
	
	addi $v0, $zero, 4		# print out startMsg
	la $a0, startMsg
	syscall
	
	addi $v0, $zero, 5
	syscall
	add $s1, $v0, $zero		# s1 = start index
	
	addi $v0, $zero, 4		# print out endMsg
	la $a0, endMsg
	syscall
	
	addi $v0, $zero, 5
	syscall
	add $s2, $v0, $zero		# s2 = end index
	
	addi $v0, $zero, 4		# print ouf subMsg
	la $a0, subMsg			
	syscall
	
	la $a0, readBuffer
	la $a1, writeBuffer
	add $a2, $s1, $zero
	add $a3, $s2, $zero
	jal _substring
	add $s3, $v0, $zero		# s3 = output buffer
	
	addi $v0, $zero, 4
	la $a0, writeBuffer
	syscall
	
	addi $v0, $zero, 10
	syscall
	
 # _substring
 # for getting a substring out of a string
 # non-laf function
 # uses
 #
 # params:
 # a0: address of input string
 # a1: address of output string
 # a2: starting index (inclusive)
 # a3: ending index (exclusive)
 #
 # uses:
 # t0, t1, t2, t3, t4, t5, t6, t7, t8
 #
 # returns: 
 # v0: address of output buffer
_substring:
	addi $sp, $sp, -4			# prefix
	sw $ra, 0($sp)
	
	add $t3, $a0, $zero			# t3 is address of input
	add $t4, $a1, $zero			# t4 is address of output
	add $t5, $a2, $zero			# t5 is starting index
	add $t6, $a3, $zero			# t6 is ending index

	add $a0, $t3, $zero
	jal _strLength
	add $t7, $v0, $zero			# t7 is length of input
	
	slt $t8, $t5, $zero			# if start index negative, return empty
	bne $t8, $zero, substringEmpty
	
	slt $t8, $t6, $zero			# if end index negative, return empty
	bne $t8, $zero, substringEmpty
	
	slt $t8, $t5, $t6			# if ending <= starting, return empty
	beq $t8, $zero, substringEmpty
	
	slt $t8, $t7, $t6			# if length < ending index
	beq $t8, $zero, substringSkip1
	add $t6, $t7, $zero			# set ending index to length

substringSkip1:
	add $t5, $t5, $t3			# starting index -> starting address
	add $t6, $t6, $t3			# ending index -> ending address
	
	add $t0, $zero, $zero			# clear t0, t1, t2
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	
moveLoop:					# loop until starting index = ending index
	beq $t5, $t6, substringEnd
	lb $t0, 0($t5)				# copy from input to output
	sb $t0, 0($t4)
	addi $t5, $t5, 1			# add 1 to input address 
	addi $t4, $t4, 1			# add 1 to output address
	j moveLoop
	
substringEnd:
	sb $zero, 0($t4)			# add null character
	
	add $v0, $t4, $zero			
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
substringEmpty:
	sb $zero, ($t4)				# store empty result
	add $v0, $t4, $zero			# set return value
	
	lw $ra, 0($sp)				# suffix
	addi $sp, $sp, 4
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
	
