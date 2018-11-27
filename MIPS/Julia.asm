.eqv BUFF 3000 #must be dividable by 3 !!!!

.data 
.align 3
image: .space BUFF
output: .asciiz "julia-V9.bmp"
real_q: .asciiz "\nNumber format 0.0000\nEnter the real part of constatnt\n0."
imaginary_q: .asciiz "\nEnter the imaginary part of constatnt\n0."
size_q: .asciiz "Enter the size of image in pixels\n"
msg_1: .asciiz "Generated BMP header and opening file...\n"
msg_2: .asciiz "Done\n"
.align 2
header_bmp: .space 54

	.text
## Start of code section
main:
	li $v0, 4           
	la $a0, size_q
	# ask for size
	syscall
	
	li $v0, 5
	syscall
	move $ra, $v0
	# $ra - size of the image
	# $fp - number of tot bytes
	
	li $t2, 4
	divu $ra, $t2
	mfhi $t9
	#subu $t9, $t2, $t9
bmp_header_gen:	#unused - for cleaner code
## GEN BMP header	
	la $t1, header_bmp
	li $t2, 'B'
	sb $t2, ($t1)
	addiu $t1, $t1, 1
	li $t2, 'M'
	sb $t2, ($t1)
	addiu $t1, $t1, 1
	
	#FILE_SIZE
	mul $t2, $ra, 3
	mul $fp, $t2, $ra #X*Y*3
	
	mul $t2, $ra, $t9
	addu $fp, $fp, $t2 # blank spaces
	
	addiu $t3, $fp, 54
	sh $t3, ($t1)
	addiu $t1, $t1, 2
	srl $t2, $t3, 16
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	#UNUSED	
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#PIX_OFFSET
	li $t2, 54
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#DIB_SIZE
	li $t2, 40
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#WIDTH
	sh $ra, ($t1)
	addiu $t1, $t1, 2
	srl $t2, $ra, 16
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	#HEIGHT
	sh $ra, ($t1)
	addiu $t1, $t1, 2
	srl $t2, $ra, 16
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	#PLANES
	li $t2, 1
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	#BPP
	li $t2, 24
	sh $t2, ($t1)
	addiu $t1, $t1, 2
	#compression
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#image_size
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#res X in ppi
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#res Y in ppi
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#number of colors in palette
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	#number of important colors
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	sh $zero, ($t1)
	addiu $t1, $t1, 2
	
	move $fp, $t9 #inf for padding - zero filling
	
get_data: #unused - for cleaner code
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
	li $t1, 10240
	divu $s0, $t1, $ra #calc step
	mul $t1, $ra, -1  #load X pos
	move $t2, $t1 #load Y pos
	subi $t1, $t1, 1 #correction for first step
	#easier than making redundant code for initialisation proceed-julia 
	la $t3, image #image buffer
	li $s1, 3 #color const-B
	li $s2, 7 #color const-G
	li $s3, 5 #color const-R
	
create: #unused - for cleaner code
	li $v0, 4           
	la $a0, msg_1
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
	
	li $t9, 0	
	li $s4, BUFF
	subiu $s4, $s4, 3 # make place for possible zeros
	j proceed
step_y: #less frequent step so jump inside
	move $s5, $fp
fill_space_zero:
	beqz $s5, filled
	sb $zero, ($t3)
	addiu $t3, $t3, 1
	addiu $t9, $t9, 1
	subiu $s5, $s5, 1
	j fill_space_zero
	bge $t9, $s4, save
filled:
	mul $t1, $ra, -1
	addi $t2, $t2, 2
	bge $t2, $ra, save
	j prepare
proceed:
	li $t0, 0
	bge $t9, $s4, save
	addiu $t9, $t9, 3
step_x: #more frequent step so jump onlu at the end of the line
	addi $t1, $t1, 2
	bge $t1, $ra, step_y

prepare: #unused - for cleaner code
	mul $t5, $s0, $t1
	mul $t6, $s0, $t2
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
	add $t8, $t8, $t8
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
save_j:	#nesscesary see lines 254-259

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
save:	
	la $a1, image
	move $a2, $t9
	li $v0, 15
	syscall
	li $t9, 0
	la $t3, image
	bne $t2, $ra, proceed
close: #unused - for cleaner code	
	# CLOSING FILE
	li $v0, 16
	syscall
	li $v0, 4           
	la $a0, msg_2
	syscall
end: #unused - for cleaner code
	li $v0, 10
	# terminate program
	syscall	
