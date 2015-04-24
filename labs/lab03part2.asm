.data
	title: .asciiz "x^y calculator\n"
	promptx: .asciiz "please enter x: "
	prompty: .asciiz "please enter y: "
	carrot: .asciiz "^"
	equals: .asciiz " = " 
	negative: .asciiz "Please only enter positive numbers."

	# $t0 = x
	# $t1 = y
	# $t2 = result
	# $t3 = pow counter
	# $t4 = mul counter
	# $t5 = temp
	# $t6 = temp
	# $t7 = temp

.text
	addi $v0, $zero, 4		#print title
	la $a0, title
	syscall
	
	addi $v0, $zero, 4		#prompt for x
	la $a0, promptx
	syscall
	
	addi $v0, $zero, 5		#read in x
	syscall
	add $t0, $zero, $v0
	
	addi $v0, $zero, 4		#prompt for y
	la $a0, prompty
	syscall
	
	addi $v0, $zero, 5		#read in y
	syscall
	add $t1, $zero, $v0
	
	
	slt $t5, $t0, $zero 		#is x less than 0
	slt $t6, $t1, $zero		#is y less than 0
	or $t7, $t5, $t6		#or x < 0 and y < 0
	bne $t7, $zero, negerr		#jump to negerr if either is negative
	
	addi $t2, $zero, 1		#branch to end with result as 1 if y is 0
	beq $t1, $zero, end
	
	add $t2, $zero, $zero		#branch to end with result as 0 if x is 0
	beq $t0, $zero, end		
	
	
	add $t2, $zero, $zero		# $t2 = result
	add $t3, $zero, $zero		# $t3 = pow counter
	add $t4, $zero, $zero		# $t4 = mul counter
	add $t5, $zero, $zero		# $t5 = temp
	add $t6, $zero, $zero		# $t6 = temp
	subi $t0, $t0, 1
	addi $t2, $t2, 1
	
powloop:	
	slt $t5, $t3, $t1 		#if powcounter >= y
	beq $t5, $zero, end_powloop	#jump to end

	
	add $t4, $zero, $zero		#mulcounter = 0
	
	add $t6, $t2, $zero		#store result for multiplying
mulloop:
	slt $t5, $t4, $t0		#if mulcounter >= x
	beq $t5, $zero, end_mulloop	#j powloop
	add $t2, $t2, $t6		#result += stored result
	addi $t4, $t4, 1		#addcounter++
	j mulloop
	
end_mulloop:
	addi $t3, $t3, 1		#powcounter++
	j powloop

end_powloop:
	addi $t0, $t0, 1
	j end
	
end:
	addi $v0, $zero, 1		#print x
	addi $a0, $t0, 0
	syscall
	
	addi $v0, $zero, 4		#print carrot
	la $a0, carrot
	syscall
	
	addi $v0, $zero, 1		#print y
	add $a0, $zero, $t1
	syscall
	
	addi $v0, $zero, 4		#print =
	la $a0, equals
	syscall
	
	addi $v0, $zero, 1		#print result
	add $a0, $zero, $t2
	syscall
	
	addi $v0, $zero, 10		#exit
	syscall
	
negerr:
	addi $v0, $zero, 4		#print negative number error
	la $a0, negative
	syscall
	
	addi $v0, $zero, 10		#exit
	syscall
	
