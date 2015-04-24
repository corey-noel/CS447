 # operator:
 # 0 = plus
 # 1 = minus
 # 2 = multiplication
 # 3 = division
 
 # state:
 # 0 = startup and clear
 # 1 = typing first operand; typing operand after result
 # 2 = just pressed operator button; haven't typed second operand
 # 3 = typing second operand; typing operand after operator
 # 4 = just hit equals; result displayed
 # 5 = operator pressed while typing second operand. Temporary.
 
 # $t4 = temporary calculations
 # $t5 = temporary calculations

 # $t6 = result 
 # $t7 = button pressed
 # $t8 = display
 # $t9 = keypad input
 
 .text
 state0:				########## INITIAL VALUES ##########
  	addi $t0, $zero, 1		# t0 = state
	addi $t1, $zero, 0		# t1 = operand 1
	addi $t2, $zero, 0		# t2 = operand 2
	addi $t3, $zero, 0		# t3 = operator
  	addi $t4, $zero, 0
  	addi $t5, $zero, 0
  	addi $t6, $zero, 0		# t6 = result
  	addi $t7, $zero, 0		# t7 = input
 	addi $t8, $zero, 0 		# t8 = display
 	addi $t9, $zero, 0		# t9 = keypad
 	
 input: 				####	###### GET INPUT ##########
 	beq $t9, 0, input			#wait for input
 	andi $t7, $t9, 0x0000000f		#set input to kepad's 4 lsb
 	
 	addi $t9, $zero, 0			#reset keypad
 	
 	addi $t4, $zero, 15			#jump to clear if t7 = 15
 	beq $t7, $t4, state0
 	
 	addi $t4, $zero, 14			#jump to equals if t7 = 14
 	beq $t7, $t4, equals
 	
 	slti $t4, $t7, 10			#jump to operator if t7 is greater than or equal to 10
 	beq $t4, $zero, operator	
 						#proceed to number if t7 is less than 10
 		
 number: 				########## NUMBER INPUT ##########
 	addi $t4, $zero, 1
 	beq $t0, $t4, number_1 			#jump to number_1 if state is 1
 	
 	addi $t4, $zero, 2
 	beq $t0, $t4, number_2_3		#jump to number_2_3 if state is 2
 	
 	addi $t4, $zero, 3
 	beq $t0, $t4, number_2_3		#jump to number_2_3 if state is 3
 	
 	addi $t4, $zero, 4
 	beq $t0, $t4, number_4			#jump to number_4 if state is 4
 	
 number_1:
 	add $t4, $zero, $t1			#multiply operand 1 by 10 (shift left 3, add itself twice)
 	sll $t1, $t1, 3
 	add $t1, $t1, $t4
 	add $t1, $t1, $t4
 	
 	add $t1, $t1, $t7			#add button pressed to operand 1
 	add $t8, $zero, $t1			#update display as operand 1
 	j input					#go back to looping for input
 	
 number_2_3:
 	add $t4, $zero, $t2			#multiply operand 2 by 10 (shift left 3, add itself twice)
 	sll $t2, $t2, 3
 	add $t2, $t2, $t4
 	add $t2, $t2, $t4
 	
 	add $t2, $t2, $t7			#add button pressed to operand 2
 	add $t8, $zero, $t2			#update display as operand 2
 	addi $t0, $zero, 3			#make state 3
 	j input					#go back to looping for input
 	
 number_4:
 	add $t1, $zero, $t7			#set operand 1 to input
 	add $t2, $zero, 0			#set operand 2 to 0
 	add $t3, $zero, 0			#set operator to 0
 	add $t8, $zero, $t1			#set display to operand 1
 	add $t0, $zero, 1			#set state to 1
 	j input					#go back to looping for input
 	
 operator: 				########## OPERATOR INPUT ##########
 	addi $t4, $zero, 1
 	beq $t0, $t4, operator_1_2		#jump to operator_1_2 if state is 1
 	
 	addi $t4, $zero, 2
 	beq $t0, $t4, operator_1_2		#jump to operator_1_2 if state is 2
 	
 	addi $t4, $zero, 3
 	beq $t0, $t4, operator_3		#jump to operator_3 if state is 3
 	
 	addi $t4, $zero, 4
 	beq $t0, $t4, operator_4		#jump to operator_4 if state is 4
 	
 operator_1_2:
 	addi $t3, $t7, -10 			#save the input as an operator
 	addi $t8, $t1, 0			#display operator 1
 	addi $t0, $zero, 2			#set state to 2
 	j input
 	
 operator_3:
 	addi $t0, $zero, 5			#set state to 5
 	j compute				#compute operation
 	
 operator_3_post:
 	addi $t1, $t6, 0			#operator 1 = result
 	addi $t0, $zero, 2			#state = 2
 	addi $t3, $t7, -10 			#save the input as an operator
 	j input
 	
 operator_4:
 	addi $t1, $t6, 0			#operand 1 = result
 	addi $t3, $t7, -10			#parse operator from input
 	addi $t0, $zero, 2			#set state to 2
 	j input					#go back to looping for input
 	
 equals: 				########## EQUALS INPUT ##########
 	add $t4, $zero, 1		
 	beq $t0, $t4, equals_1_2		#jump to equals_1_2 if state is 1
 	
 	add $t4, $zero, 2
 	beq $t0, $t4, equals_1_2		#jump to equals_1_2 if state is 2
 	
 	add $t4, $zero, 3
 	beq $t0, $t4, equals_3			#jump to equals_3 if state is 3
 	
 	add $t4, $zero, 4
 	beq $t0, $t4, equals_4			#jump to equals_4 if state is 4
 	
 equals_1_2:
  	addi $t0, $zero, 4			#set state to post-operation
 	add $t6, $zero, $t1			#result = operator 1
 	add $t8, $zero, $t6			#display result
 	j input
 	
 equals_3:
 	addi $t0, $zero, 4			#set state to post-operation
 	j compute				#jump to compute
 					
 	
 equals_4:
 	addi $t8, $t6, 0
 	addi $t0, $zero, 4
 	j input
 	
 compute:				########## COMPUTATION ##########
 	add $t4, $zero, 0
 	beq $t3, $t4, addition			#jump to addition if the button pressed was +
 	
 	add $t4, $zero, 1
 	beq $t3, $t4, subtraction		#jump to subtraction if the button pressed was -
 	
 	add $t4, $zero, 2
 	beq $t3, $t4, multiplication		#jump to multiplication *
 	
 	add $t4, $zero, 3
 	beq $t3, $t4, division			#jump to division /
 	
 addition: 				########## ADDITION ##########
 	add $t6, $t1, $t2			#perform addition
 	j post_op
 	
 subtraction: 				########## SUBTRACTION ##########
 	sub $t6, $t1, $t2			#perform subtraction
 	j post_op
 	
 multiplication: 			########## MULTIPLICATION ##########
 	add $t6, $zero, $zero			#set destination register to 0
 	add $t4, $zero, $zero			#set counter to 0
 mult_loop: 
 	slt $t5, $t4, $t2		
 	beq $t5, $zero, post_op			#if counter >= operand 2, we're done
 	add $t6, $t6, $t1			#add operand 1 to destination
 	addi $t4, $t4, 1			#incriment counter
 	j mult_loop				#loop again
 	
 division: 				########## DIVISION ##########
 	add $t6, $zero, $zero			#set destination register to 0
 	add $t4, $zero, $zero			#set counter to 0
	slt $s1, $t1, $zero			#if op 1 is neg use neg loop 
	bne $s1, $zero, div_negative	
	j div_loop

div_negative:
	sub $t1, $zero, $t1
	j div_loop
	
div_loop:
 	slt $t5, $t1, $t2
 	bne $t5, $zero, post_div		#if op 1 < op 2, we're done
 	
 	addi $t6, $t6, 1			#otherwise incriment counter
 	sub $t1, $t1, $t2			#and sub op2 from op1
 	
	j div_loop
	
post_div:
	beq $s1, $zero, post_op
	sub $t6, $zero, $t6
	j post_op
 	
 post_op: 				########## POST-OPERATION ##########
 	add $t8, $zero, $t6			#update display
 	
 	add $t1, $zero, $zero			#clear operand 1 after operation
 	add $t2, $zero, $zero			#clear operand 2 after operation
 	add $t3, $zero, $zero			#clear operator
 	add $t4, $zero, $zero			#clear temp
 	add $t5, $zero, $zero			#clear temp
 	
 	addi $t4, $zero, 4
 	beq $t0, $t4, input			#return to looping if state is 4 	
 	j operator_3_post			#j to operator if came from operator (state is 5)
