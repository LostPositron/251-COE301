.data
.align 2
one: .float 1.0
.align 3
four: .double 4.0
.text
.globl count_points
.globl estimate_pi

#sample run
li $a0, 0x200
jal estimate_pi
mtc1.d $v0, $f12
li $v0, 3
syscall
li $v0, 10
syscall

#a0 = number of points to generate
#v0 = number of points inside square
#v1 = number of points inside circle
count_points:
addiu $sp, $sp, -4
sw $ra, 0($sp)
#We exploit the fact that if sqrt(x^2+y^2)<1 -> x^2+y^2<1. There is no need to take the square root.
#Also, all points we generate will be inside the square, so we load the value of $a0 directly into $v0
move $t0, $a0 #num points inside square
li $t1, 0 #num points inside circle
l.s $f2, one
move $t2, $a0 #counter
gen_loop:
	jal generate_random
	mtc1 $v0, $f0
	mtc1 $v1, $f1
	mul.s $f0, $f0, $f0 #x^2
	mul.s $f1, $f1, $f1 #y^2
	add.s $f0, $f0, $f1 #x^2+y^2
	c.le.s $f0, $f2
	bc1f outside_circle
		addiu $t1, $t1, 1
	outside_circle:
	addiu $t2, $t2, -1
	bgtz $t2, gen_loop
move $v0, $t0
move $v1, $t1
lw $ra, 0($sp)
addiu $sp, $sp, 4
jr $ra
	

#v0 = x_coord
#v1 = y_coord
generate_random:
#note: the random number generator returns nums in [0, 1], not [-1, 1]. The sign is COMPLETELY irrelevant.
#if we examine the distance formula d=sqrt(x^2+y^2), we see that the coordinates get squared, so the sign is indeed irrelevant.
# assigning one register as hold the y-coord and one as holding the x-coord isn't necessary at all.
li $v0, 43
syscall #generate random y-coord
mfc1 $v1, $f0
syscall #generate random x-coord
mfc1 $v0, $f0
jr $ra

#a0 = number of points considered in estimation
#v0 = pi estimate (least significant)
#v1 = pi estimate (most significant)
estimate_pi:
addiu $sp, $sp, -4
sw $ra, 0($sp)
jal count_points
mtc1.d $v0, $f2 #num in square
cvt.d.w $f2, $f2
mtc1.d $v1, $f4 #num in circle
cvt.d.w $f4, $f4
l.d $f6, four
mul.d $f6, $f4, $f6 #4*in_circle
div.d $f6, $f6, $f2 #4*in_circle/ic_square
mfc1 $v0, $f6
mfc1 $v1, $f7
lw $ra, 0($sp)
addiu $sp, $sp, 4
jr $ra
