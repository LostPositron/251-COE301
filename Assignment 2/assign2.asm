.data
try1: .byte 0x01
try2: .asciiz "COE301"
try3: .byte 0x01, 0x02, 0x03
try4:  .byte 0x02
try5: .byte 0x01, 0x02, 0x03, 0x04

.text
.globl crc_byte
.globl crc_array
.globl check_byte
.globl check_array

testing:
lbu $a0, try1
jal crc_byte
move $a0, $v0
li $v0, 34
syscall
lbu $a0, try1
li $a1, 0xa7
jal check_byte
move $a0, $v0
li $v0, 34
syscall
li $a0, '\n'
li $v0, 11
syscall


la $a0, try2
li $a1, 6
jal crc_array
move $a0, $v0
li $v0, 34
syscall
la $a0, try2
li $a1, 6
li $a2, 0xDE
jal check_array
move $a0, $v0
li $v0, 34
syscall
li $a0, '\n'
li $v0, 11
syscall


la $a0, try3
li $a1, 3
jal crc_array
move $a0, $v0
li $v0, 34
syscall
la $a0, try3
li $a1, 3
li $a2, 0xFC
jal check_array
move $a0, $v0
li $v0, 34
syscall
li $a0, '\n'
li $v0, 11
syscall


lbu $a0, try4
jal crc_byte
move $a0, $v0
li $v0, 34
syscall
lbu $a0, try4
li $a1, 0xE9
jal check_byte
move $a0, $v0
li $v0, 34
syscall
li $a0, '\n'
li $v0, 11
syscall

la $a0, try5
li $a1, 4
jal crc_array
move $a0, $v0
li $v0, 34
syscall
la $a0, try5
li $a1, 4
li $a2, 0xC2
jal check_array
move $a0, $v0
li $v0, 34
syscall
li $a0, '\n'
li $v0, 11
syscall


li $v0, 10
syscall

# a0= byte
# v0 = crc
crc_byte:
li $t0, 0x1A7 #generator
li $t1, 1
sll $t1, $t1, 8 #bit mask captures bit index len(generator)-1. 
li $t2, 8 #t2 is counter for xor_loop
xor_loop: 
addiu $t2, $t2, -1
rol $a0, $a0, 1
and $t3, $a0, $t1 #apply mask on message
beqz $t3, skipped # if bit position len(generator)-1 is 0, then skip
xor $a0, $a0, $t0
skipped:
bgtz $t2, xor_loop
move $v0, $a0
jr $ra

# a0 = array address
# a1 = num elements
# v0 = CRC
crc_array:
addiu $sp, $sp, -8
sw $ra, 0($sp)
sw $a0, 4($sp)
li $a0, 0
loop:
lw $t5, 4($sp)
lbu $t5, 0($t5)
xor $a0, $t5, $a0
jal crc_byte
move $a0, $v0
lw $t5, 4($sp)
addiu $t5, $t5, 1
sw $t5, 4($sp)
addiu $a1, $a1, -1
bnez $a1, loop
move $v0, $a0
lw $ra, 0($sp)
addiu $sp, $sp, 8
jr $ra

# a0= byte
# a1 = crc code
# v0 = is_error_free
check_byte:
addiu $sp, $sp, -4
sw $ra, 0($sp)
ror $t0, $a1, 8
or $a0, $t0, $a0 #instead of appending zeros, we append the code
jal crc_byte
lw $ra, 0($sp)
addiu $sp, $sp, 4
seq $v0, $v0, 0
jr $ra

# a0 = array address
# a1 = num elements
# a2 = crc code
# v0 = is_error_free
check_array:
addiu $sp, $sp, -4
sw $ra, 0($sp)
jal crc_array
seq $v0, $v0, $a2 # didn't understand the description of how to calculate the crc by initializing crc. Intuitively though, we should be able to just re-calculate the crc and compare it with the received crc.
lw $ra, 0($sp)
addiu $sp, $sp, 4
jr $ra
