.data
	prompt: .asciiz "Please enter your integer: "
	response: .asciiz "Here is the output: "

.text
	addi $v0, $zero, 4		#print prompt
	la $a0, prompt
	syscall
	
	addi $v0, $zero, 5		#read input
	syscall
	add $t0, $zero, $v0
	
	srl $t1, $t0, 15		#shift right so that 15-17 becomes 1-3
	andi $t1, $t1, 0x0000007		#mask bits 0, 1, 2

	
	addi $v0, $zero, 4		#print response
	la $a0, response
	syscall
	
	addi $v0, $zero, 1		#print result
	add $a0, $zero, $t1
	syscall
	
	addi $v0, $zero, 10		#exit
	syscall