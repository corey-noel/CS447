.data	
	tones: 		.space		128
	
.text
	addi $v0, $zero, 30		# set up rng
	syscall
	addi $v0, $zero, 40
	add $a1, $a0, $zero
	add $a0, $zero, $zero
	syscall
	

preGame: 
	beq $t9, $zero, preGame
	add $t0, $zero, 16		# wait until input is 16
	beq $t9, $t0, startGame
	add $t9, $zero, $zero
	j preGame
	
startGame:
	add $t9, $zero, $zero		
	addi $t8, $zero, 16		# play startup sound
waitStart:
	bne $t8, $zero, waitStart	# wait until startup sound is over
	
	add $s0, $zero, $zero		# s0 is numTones
	add $s1, $zero, $zero		# s1 is player position
	
gameLoop:
	add $s1, $zero, $zero		# player position is 0
		
	la $a0, tones
	add $a1, $zero, $s0
	jal _generateTone		# add one tone
	
	addi $s0, $s0, 1		# incriment numtones
	
	la $a0, tones			# play all tones
	add $a1, $zero, $s0
	jal _playTones
	
inputLoop:
	beq $s0, $s1, gameLoop		# if player position is numTones, exit input loop
	la $t0, tones
	add $t0, $t0, $s1		# find current tone
	lb $t1, ($t0) 
	
waitInput:
	beq $t9, $zero, waitInput	# get player input
	
	add $t8, $t9, $zero		# play output
waitOutput:
	bne $t8, $zero, waitOutput
	
	bne $t9, $t1, gameOver		# if input != tone, game over
	add $t9, $zero, $zero		# reset input
	addi $s1, $s1, 1		# incriment position
j inputLoop

gameOver:
	add $t9, $zero, $zero		# reset input
	addi $t8, $zero, 15		# game over sound
waitGameOver:
	bne $t8, $zero, waitGameOver
	j preGame

 # _generateTone
 # adds a tone to the end of the sequence
 #
 # params
 # a0 - address of tones 
 # a1 - number of tones
_generateTone:
	add $t0, $a0, $a1		# get address we'll be writing to
	
	addi $v0, $zero, 42		# get random num
	add $a0, $zero, $zero
	addi $a1, $zero, 4
	syscall
	
	addi $t1, $zero, 1		# shift 1 by random num
	sllv $a0, $t1, $a0
	sb $a0, ($t0)			# store shifted num
	
	jr $ra
	
 # _playTones
 # plays the tones in the sequence
 # 
 # params 
 # a0 - address of tones
 # a1 - number of tones
_playTones:
	addi $t9, $zero, 3		# disable buttons
playTonesLoop:
	beq $a1, $zero, playTonesDone	# if we've played all tones we're done
	lb $t8, ($a0)			# load a byte to play
playTonesWait:
	bne $t8, $zero, playTonesWait	# wait
	addi $a1, $a1, -1		
	addi $a0, $a0, 1		# move to next tone
	j playTonesLoop
	
playTonesDone:
	add $t9, $zero, $zero		# enable buttons
	jr $ra
	
	
