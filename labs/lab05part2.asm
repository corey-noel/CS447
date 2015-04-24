.data 
	enterMsg: 	.asciiz		"Enter a nonnegative integer: "
	invalidMsg:	.asciiz		"Invalid integer; try again.\n"
	equalsMsg:	.asciiz		"! = "

.text
start:
	addi $v0, $zero, 4
	la $a0, enterMsg
	syscall

	addi $v0, $zero, 5
	syscall

	slt $t0, $v0, $zero
	beq $t0, $zero, calculate
	
	addi $v0, $zero, 4
	la $a0, invalidMsg
	syscall
	
	j start

calculate:
	add $a0, $v0, $zero
	add $s0, $v0, $zero
	jal _factorial
	
	add $s1, $v0, $zero
	
	addi $v0, $zero, 1
	add $a0, $s0, $zero
	syscall
	
	addi $v0, $zero, 4
	la $a0, equalsMsg
	syscall
	
	addi $v0, $zero, 1
	add $a0, $s1, $zero
	syscall
	
	addi $v0, $zero, 10
	syscall

_factorial:
	slt $t0, $zero, $a0			# if a0 <= zero
	beq $t0, $zero, factorialDone		# jump to factorial done
	addi $sp, $sp, -8			# back up a0 and ra
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	subi $a0, $a0, 1
	jal _factorial				# call factorial
	lw $a0, 0($sp)				# reload a0 and ra
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	mul $v0, $v0, $a0			# v0 = v0 * a0
	jr $ra
factorialDone:
	addi $v0, $zero, 1			# v0 = 1
	jr $ra

