.data

rbits: .space 8
buffer: .space 11
input: .space 11
message: .asciiz "Enter a 32-bit value in hexadecimal format: "
Table: .ascii "0123456789ABCDEF"
output1: .asciiz "The reverse order of bits is: "
output2: .asciiz "\nThe reverse order of bytes is: "
.text
.globl main
main:

# print message
la $a0, message
li $v0, 4
syscall

# read input
la $a0, input
li $a1, 11
li $v0, 8
syscall

# get rid of spaces in input/move least significant bits to lower address (makes processing easier as I'm very simple minded)
li $t0, 10
li $t1, 0
li $t2, ' '
li $t4, 10
li $t5, 8
nop
fill:
	lb $t3, input($t0)
	beq $t3, $t2, skipped
	beq $t3, $zero, skipped
	beq $t3, $t4, skipped
	sb $t3, buffer($t1)
	addiu $t1, $t1, 1
	beq $t1, $t5, out
	skipped:
	addiu $t0, $t0, -1
	bgez $t0 fill
out:
	



# loop to convert string representation of number into value of number

li $t0, 0 # store actual value
li $t1, 0 # counter variable, used to terminate loop calculate shift (weight)
la $t2, buffer # store address of char to read
# t3: read char, raw or processed
# t4: 4*counter=4*$t0, used for shifting (multiplication)
loop:
	lb $t3, 0($t2)
	
	beqz $t3, processed #The remaining characters are all value 0, we don't have to process them
	
	# check A<char<F
	li $s0, 'A'
	li $s1, 'F'
	bgt $t3, $s1, next1
	blt $t3, $s0, next1
	addiu, $t3, $t3, -55
	j adding

	# check a<char<f
	next1:
	li $s0, 'a'
	li $s1, 'f'
	bgt $t3, $s1, next2
	blt $t3, $s0, next2
	addiu, $t3, $t3, -87
	j adding
	
	# surely 0<char<9
	next2:
	addiu $t3, $t3, -48

	adding:
	sll $t4, $t1, 2
	sllv $t3, $t3, $t4
	addu $t0, $t0, $t3
	addiu $t1, $t1, 1
	addiu $t2, $t2, 1
	
	j loop
	
processed:

#reversing bits
move $t4, $t0
li $t2, 0
li $t3, 32
li $t1, 0 #stores bit-shifted number
shifty_bits:
	sll $t1, $t1, 1
	and $t5, $t4, 1
	or $t1, $t1, $t5
	srl $t4, $t4, 1
	addiu $t2, $t2, 1
	blt $t2, $t3, shifty_bits

#reversing bytes
move $t4, $t0
li $t6, 0
li $t3, 4
li $t2, 0 #stores byte-shifted number
shifty_bytes:
	sll $t2, $t2, 8
	and $t5, $t4, 0xFF
	or $t2, $t2, $t5
	srl $t4, $t4, 8
	addiu $t6, $t6, 1
	blt $t6, $t3, shifty_bytes

# Store values in s registers because why not
move $s0, $t0
move $s1, $t1
move $s2, $t2
	
# Print message for bit-flipped
la $a0, output1
li $v0, 4
syscall	

# print hex of bit-flipped
move $t0, $s1
li $t3, 8 
loop1: 
rol  $t0, $t0, 4 
andi $a0,$t0, 15 
la $t1, Table 
addu $t1, $t1, $a0 
lb $a0, 0($t1) 
li $v0, 11 # display character  
syscall    
sub $t3, $t3, 1 
bne $t3, $zero, loop1

# Print message for byte-flipped
la $a0, output2
li $v0, 4
syscall

# Print hexa of byte-flipped
move $t0, $s2
li $t3, 8 
loop2: 
rol  $t0, $t0, 4 
andi $a0,$t0, 15 
la $t1, Table 
addu $t1, $t1, $a0 
lb $a0, 0($t1) 
li $v0, 11 # display character  
syscall    
sub $t3, $t3, 1 
bne $t3, $zero, loop2

li $v0, 10
syscall