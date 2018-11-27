.data

image: .space 786432 # 512x512 8-bit image
real_q: .asciiz "\nNumber format 0.0000\nEnter the real part of constatnt\n0."
imaginary_q: .asciiz "\nEnter the imaginary part of constatnt\n0."
input: .asciiz "input.bmp"
output: .asciiz "julia.bmp"
header_bmp: .space 54

	.text
## Start of code section
main:
	li $v0, 4           
	la $a0, real_q
	# ask for real part
	syscall
	
	li $v0, 5
	syscall
	move $s6, $v0
	#save real
	li $v0, 4           
	la $a0, imaginary_q
	# ask for imaginary part  
	syscall
	
	li $v0, 5
	syscall
	move $s7, $v0 
	#save imaginary
	li $t1, -10240 #load X pos
	li $t2, -10240 #load Y pos
	la $t3, image #image buffer
	li $s1, 12 #color const-s
	li $s2, 55
	li $s3, 15
proceed:
	li $t0, 0
step_x:
	addi $t1, $t1, 40
	beq $t1, 10240, step_y
	j prepare	
step_y:
	li $t1, -10240
	addi $t2, $t2, 40
	beq $t2, 10240, save_img
prepare:
	move $t5, $t1
	move $t6, $t2
julia:
	mult $t5,$t5
	mflo $t7
	div $t7, $t7, 10000
	#x^2
	mult $t6,$t6
	mflo $t8
	div $t8, $t8, 10000
	#y^2
	sub $t7, $t7, $t8
	#x^2-y^2
	mult $t5, $t6
	mflo $t8
	div $t8, $t8, 10000
	#xy
	add $t8, $t8, $t8 ###SHIFT
	#2xy
	add $t5, $t7, $s6
	#new Re
	add $t6, $t8, $s7
	#new Im
	
	#prep to check bound
	mult $t5,$t5
	mflo $t7
	div $t7, $t7, 10
	mult $t6,$t6
	mflo $t8
	div $t8, $t8, 10
	add $t7, $t7, $t8
	# |z|^2
	bgt $t7, 40000000, save_j
	#check bound
	
	addiu $t0, $t0, 1
	#add iteration
	blt $t0, 255, julia
save_j:	
	#red
	mult $t0, $s1
	mflo $t4
	sb $t4, ($t3)
	addiu $t3, $t3, 1
	#green
	mult $t0, $s2
	mflo $t4
	sb $t4, ($t3)
	addiu $t3, $t3, 1
	#blue
	mult $t0, $s3
	mflo $t4
	sb $t4, ($t3)
	addiu $t3, $t3, 1	
	j proceed
save_img:

	# open file 'input.bmp'
	la $a0, input
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	
	move $a0, $v0
	li $v0, 14 		# read bmp header from file
	la $a1, header_bmp
	li $a2, 54
	syscall
	
	# close file 
	li $v0, 16
	syscall
	
	la $a0, output
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	
	move $a0, $v0
	la $a1, header_bmp
	li $a2, 54
	li $v0, 15
	syscall
	
	la $a1, image
	li $a2, 786432
	li $v0, 15
	syscall
	
	# CLOSING FILE
	li $v0, 16
	syscall

end:
	li $v0, 10
	# terminate program
	syscall	
