.data
	steps: .space 256

.text

	jal _update
	
	la $a0, steps
	jal _leftHandRule
	
 # I couldn't quite get the reduction of the path to work out
 # the psuedocode works and the code almost works, but not quite
 #	la $a0, steps
 #	add $a1, $v0, $zero
 #	jal _reduce
	
	la $a0, steps
	add $a1, $v0, $zero
	jal _traceBack
	
	addi $a0, $zero, -1
	jal _backtracking
	

	addi $v0, $zero, 10
	syscall

 # _leftHandRule
 # solves the maze using the left hand rule and finds the optimal route
 # parameters:
 # $a0 - address of steps array
 # returns
 # $v0 - number of steps in the array
_leftHandRule:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
 	add $s0, $a0, $zero	# s0 is the address of the steps array
 	add $s1, $zero, $zero	# s1 is the current number of steps
 	
LHloop:
 	jal _getCol			# if at dest
	subi $s2, $v0, 8
	jal _getRow 
	subi $s3, $v0, 7
	or $s2, $s2, $s3
	beq $s2, $zero, LHdone		# jump to LHdone
 

 	add $a0, $s0, $zero		# add current pos
 	add $a1, $s1, $zero
 	jal _getCol
 	add $a2, $v0, $zero
 	jal _getRow
 	add $a3, $v0, $zero
 	jal _writeStep
 	
 	addi $s1, $s1, 1		# incriment numsteps
 
LHleft:
	jal _getLeft
	bne $v0, $zero, LHfront
	jal _turnLeft
	jal _move
	j LHloop
 
LHfront:
	jal _getFront
	bne $v0, $zero, LHright
	jal _move
	j LHloop

LHright:
	jal _getRight
 	bne $v0, $zero, LHback
	jal _turnRight
	jal _move
	j LHloop
 
LHback:
	jal _turnRight
	jal _turnRight
	jal _move
	j LHloop

LHdone:
	add $v0, $s1, $zero

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra


# int count = 0; 
# while (count < numSteps) {
#	for (int check = numSteps; check > count; check--) {
#		if (steps[count] == steps[check]) {
#			for (int movePos = 0; movePos < numSteps - check; movePos++) 
#				steps[count + movePos] = steps[check + movePos];	
#			numSteps -= check - count;
#			break;
#		}
#	}
#	count++;
# }

 # _reduce
 # recudes the path to its simplest form
 # parameters:
 # a0 = steps array address
 # a1 = numSteps
 # returns:
 # v0 = numSteps
_reduce:
	add $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $ra, 28($sp)

	add $s0, $a0, $zero		# s0 = steps array address
	addi $s1, $a1, -1		# s1 = numSteps
	add $s2, $zero, $zero		# s2 = count
	add $s3, $zero, $zero		# s3 = check
	add $s4, $zero, $zero		# s4 = movePos
	add $s5, $zero, $zero		# s5 = currentstep col
	add $s6, $zero, $zero		# s6 = currentstep row
	
reductionLoop:				
	slt $t0, $s2, $s1
	beq $t0, $zero, reductionDone
		
		add $a0, $s0, $zero	# read in step[count]
		add $a1, $s2, $zero
		jal _readStep
		add $s5, $v0, $zero
		add $s6, $v1, $zero
		
		add $s3, $s1, $zero
checkLoop:				# checks for duplicate entires
		slt $t0, $s2, $s3
		beq $t0, $zero, checkDone
		
		add $a0, $s0, $zero	# read in step[check]
		add $a1, $s3, $zero
		jal _readStep
		add $t0, $v0, $zero
		add $t1, $v1, $zero
		
		sub $t0, $t0, $s5
		sub $t1, $t1, $s6
		or $t0, $t0, $t1
		bne $t0, $zero, checkSkip	# if steps aren't equal, loop again
		
		add $s4, $zero, $zero		# reset movePos
moveLoop:
			sub $t0, $s1, $s3
			slt $t0, $s4, $t0
			beq $t0, $zero, moveDone
			
			add $a0, $s0, $zero
			add $a1, $s3, $s4
			jal _readStep
			add $a0, $s0, $zero
			add $a1, $s2, $s4
			add $a2, $v0, $zero
			add $a3, $v1, $zero
			jal _writeStep
			
			addi $s4, $s4, 1
			j moveLoop
moveDone:
			sub $s1, $s1, $s3
			add $s1, $s1, $s2
			j checkDone
checkSkip:
		addi $s3, $s3, -1
		j checkLoop

checkDone:
	addi $s2, $s2, 1
	j reductionLoop
	
reductionDone:
	add $v0, $s1, $zero

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	jr $ra


 # _traceBack
 # returns via the route indicated by the steps in the array
 # parameters:
 # a0 - address of an array of steps
 # a1 - number of steps to follow
_traceBack:
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	add $s0, $a0, $zero		# s0 = address of array
	add $s1, $a1, $zero		# s1 = number of steps to take
	subi $s1, $s1, 1
tracebackLoop:
	slt $t0, $s1, $zero
	bne $t0, $zero, tracebackDone
	
	jal _getCol
	add $s2, $v0, $zero		# s2 = col
	jal _getRow
	add $s3, $v0, $zero		# s3 = row
	
	add $a0, $s0, $zero
	add $a1, $s1, $zero
	jal _readStep
	
	add $a2, $v0, $zero
	add $a3, $v1, $zero
	add $a0, $s2, $zero
	add $a1, $s3, $zero
	jal _getDirectionTo
	
	add $a0, $v0, $zero
	jal _turnToFace
	jal _move
	
	addi $s1, $s1, -1
	j tracebackLoop
	
tracebackDone:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	add $sp, $sp, 24
	jr $ra

 # _backtracking
 # solves the maze using backtracking
 # parameters: 
 # $a0 - direction traveling from
 # returns:
 # $v0 - success
_backtracking:
 	addi $sp, $sp, -8
 	sw $ra, 0($sp)
 	sw $s0, 4($sp)

 	add $s0, $a0, $zero
 
  	jal _getCol				# if at dest
	subi $t0, $v0, 8
	jal _getRow 
	subi $t1, $v0, 7
	or $t0, $t0, $t1
	beq $t0, $zero, backtrackReturnTrue	# return true
	
backtrackCheckNorth:
	addi $a0, $zero, 0
	jal _turnToFace
	jal _getFront
	bne $v0, $zero, backtrackCheckEast
	addi $t0, $zero, 2
	beq $t0, $s0, backtrackCheckEast
	jal _move
	jal _backtracking
	bne $v0, $zero, backtrackReturnTrue
	addi $a0, $zero, 2
	jal _turnToFace
	jal _move
	j backtrackCheckEast
	
backtrackCheckEast:
	addi $a0, $zero, 1
	jal _turnToFace
	jal _getFront
	bne $v0, $zero, backtrackCheckSouth
	addi $t0, $zero, 3
	beq $t0, $s0, backtrackCheckSouth
	jal _move
	jal _backtracking
	bne $v0, $zero, backtrackReturnTrue
	addi $a0, $zero, 3
	jal _turnToFace
	jal _move
	j backtrackCheckSouth
	
backtrackCheckSouth:
	addi $a0, $zero, 2
	jal _turnToFace
	jal _getFront
	bne $v0, $zero, backtrackCheckWest
	addi $t0, $zero, 0
	beq $t0, $s0, backtrackCheckWest
	jal _move
	jal _backtracking
	bne $v0, $zero, backtrackReturnTrue
	addi $a0, $zero, 0
	jal _turnToFace
	jal _move
	j backtrackCheckWest
	
backtrackCheckWest:
	addi $a0, $zero, 3
	jal _turnToFace
	jal _getFront
	bne $v0, $zero, backtrackReturnFalse
	addi $t0, $zero, 1
	beq $t0, $s0, backtrackReturnFalse
	jal _move
	jal _backtracking
	bne $v0, $zero, backtrackReturnTrue
	addi $a0, $zero, 1
	jal _turnToFace
	jal _move
	j backtrackReturnFalse
	
backtrackReturnFalse:
	add $v0, $zero, 0
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
backtrackReturnTrue:
	add $v0, $zero, 1
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
 
 
 # _turnToFace
 # turns to face the given direction
 # parameters:
 # $a0 - the direction to face 0 = north, 1 = east, 2 = south, 3 = west
_turnToFace:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	jal _getDirection
	add $s0, $v0, $zero
	beq $s0, $a0, turnToFaceDone	# if facing the right way, return
	
	addi $t0, $s0, -1
	seq $t1, $t0, $a0
	addi $t0, $s0, 3
	seq $t2, $t0, $a0
	or $t1, $t1, $t2
	bne $t1, $zero, turnToFaceLeft
	
	add $t0, $s0, 1
	seq $t1, $t0, $a0
	addi $t0, $s0, -3
	seq $t2, $t0, $a0
	or $t1, $t1, $t2
	bne $t1, $zero, turnToFaceRight
	
	j turnToFaceBack
	
turnToFaceLeft:
	jal _turnLeft
	j turnToFaceDone
	
turnToFaceRight:
	jal _turnRight
	j turnToFaceDone

turnToFaceBack:
	jal _turnLeft
	jal _turnLeft
	j turnToFaceDone
	
turnToFaceDone:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
 
 # _getDirectionTo
 # gets the direction from point A to point B (assuming they share an axis)
 # parameters:
 # $a0 - column of A
 # $a1 - row of A
 # $a2 - column of B
 # $a3 - row of B
 # returns:
 # $v0 - 0 = north, 1 = east, 2 = south, 3 = west, -1 = same point
_getDirectionTo:
	slt $t0, $a2, $a0
	bne $t0, $zero, getDirectionWest
	slt $t0, $a0, $a2
	bne $t0, $zero, getDirectionEast
	slt $t0, $a3, $a1
	bne $t0, $zero, getDirectionNorth
	slt $t0, $a1, $a3
	bne $t0, $zero, getDirectionSouth
	
	addi $v0, $zero, -1
	jr $ra
	
getDirectionNorth:
	addi $v0, $zero, 0
	jr $ra
	
getDirectionEast:
	addi $v0, $zero, 1
	jr $ra
	
getDirectionSouth:
	addi $v0, $zero, 2
	jr $ra
	
getDirectionWest:
	addi $v0, $zero, 3
	jr $ra


 # _readStep
 # reads a step from the list of steps
 # parameters: 
 # $a0 - the address of the step array
 # $a1 - the index of the step to read
 # returns:
 # $v0 - the col value of the step read
 # $v1 - the row value of the step read
_readStep:
	sll $a1, $a1, 1
	add $a0, $a0, $a1
	lb $v0, ($a0)
	lb $v1, 1($a0)
	jr $ra

 # _writeStep
 # adds a step to the list of steps
 # parameters:
 # $a0 - the address of the step aray
 # $a1 - the index of the step to add
 # $a2 - the col value of the step to be added
 # $a3 - the row value of the step to be added
_writeStep:
	sll $a1, $a1, 1
	add $a0, $a0, $a1
	sb $a2, ($a0)
	sb $a3, 1($a0)
	jr $ra

 # _move
 # moves the robot forward one space
_move:
	addi $t8, $zero, 1
moveWait:
	bne $t8, $zero, moveWait
	jr $ra
	
 # _turnLeft
 # turns the robot left
_turnLeft:
	addi $t8, $zero, 2
turnLeftWait:
	bne $t8, $zero, turnLeftWait
	jr $ra
	
 # _turnRight
 # turns the robot right
_turnRight:
	addi $t8, $zero, 3
turnRightWait:
	bne $t8, $zero, turnRightWait
	jr $ra
	
 # _update
 # updates the status of the car
_update:
	addi $t8, $zero, 4
updateWait:
	bne $t8, $zero, updateWait
	jr $ra

 # _getRow
 # gets the current row of the robot
 # returns:
 # v0 - signed row of robot
_getRow:
	sra $v0, $t9, 24
	jr $ra

 # _getCol
 # gets the current colun of the robot
 # returns:
 # v0 - signed column of robot
_getCol:
	sll $v0, $t9, 8
	sra $v0, $v0, 24
	jr $ra

 # _getDirection
 # checks which direction the car is facing
 # returns:
 # v0 - 0 = north, 1 = east, 2 = south, 3 = west 
_getDirection:
	andi $v0, $t9, 0x800
	beq $v0, $zero, getDirEast
	addi $v0, $zero, 0
	jr $ra
getDirEast:
	andi $v0, $t9, 0x400
	beq $v0, $zero, getDirSouth
	addi $v0, $zero, 1
	jr $ra
getDirSouth:
	andi $v0, $t9, 0x200
	beq $v0, $zero, getDirWest
	addi $v0, $zero, 2
	jr $ra
getDirWest:
	addi $v0, $zero, 3
	jr $ra

 # _getFront
 # checks for a wall in front of the robot
 # returns:
 # v0 - 1 if there is a wall, 0 if there is not
_getFront:
	srl $v0, $t9, 3
	andi $v0, $v0, 1
	jr $ra

 # _getLeft
 # checks for a wall to the left of the robot
 # returns:
 # v0 - 1 if there is a wall, 0 if there is not
_getLeft:
	srl $v0, $t9, 2
	andi $v0, $v0, 1
	jr $ra

 # _getRight
 # checks for a wall to the right of the robot
 # returns:
 # v0 - 1 if there is a wall, 0 if there is not
_getRight:
	srl $v0, $t9, 1
	andi $v0, $v0, 1
	jr $ra

 # _getBack
 # checks for a wall to the back of the robot
 # returns:
 # v0 - 1 if there is a wall, 0 if there is not
_getBack:
	andi $v0, $t9, 1
	jr $ra
