.data
	enterMsg: .asciiz "Enter a number between 0 and 9: "
	lowMsg: .asciiz "Your guess is too low.\n"
	highMsg: .asciiz "Your guess is too high.\n"
	loseMsg: .asciiz "You lose. The number was "
	winMsg: .asciiz "Congratulations! You win!"
	period: .asciiz ".\n"


	# t0 = random number (0-9)
	# t1 = user input
	# t2 = number of attempts
	
	# t8 = temp (slt)
	# t9 = temp (beq)
	
	
.text
	#setup random
	addi $v0, $zero, 30 		#get systime
	syscall
	
	addi $v0, $zero, 40		#setup RNG seeding
	addi $a1, $a0, 0		
	addi $a0, $zero, 0
	syscall
	
	addi $v0, $zero, 42		#generate random num
	addi $a0, $zero, 0
	addi $a1, $zero, 10
	syscall
	addi $t0, $a0, 0
	
	addi $t2, $zero, 0		#number of attempts is 0
	
	loop:
	addi $t9, $zero, 3		#jump to lose if num attempts is 0
	beq $t2, $t9, lose
	
	addi $v0, $zero, 4		#print out enterMsg
	la $a0, enterMsg
	syscall
	
	addi $v0, $zero, 5		#read in input, store in t1
	syscall
	addi $t1, $v0, 0
	addi $t2, $t2, 1		#increase number of attempts
	
	beq $t0, $t1, win		#jump to win if number is right
	
	slt $t8, $t1, $t0		#jump to low if guesss is less
	bne $t8, $zero, low
	
	j high				#else jump to high
	
	high:
	addi $v0, $zero, 4		#print highmsg
	la $a0, highMsg
	syscall
	
	j loop				#go back to loop
	
	low:
	addi $v0, $zero, 4		#print lowMsg
	la $a0, lowMsg			
	syscall
	
	j loop				#back to loop
	
	win:
	addi $v0, $zero, 4
	la $a0, winMsg
	syscall
	
	addi $v0, $zero, 10		#exit
	syscall
	
	lose:
	addi $v0, $zero, 4		#print loseMsg
	la $a0, loseMsg
	syscall
	
	addi $v0, $zero, 1		#print number
	addi $a0, $t0, 0
	syscall
	
	addi $v0, $zero, 4		#print period
	la $a0, period
	syscall
	
	addi $v0, $zero, 10		#exit
	syscall
	