	.file	1 "example.c"
	.section .mdebug.abi32
	.previous
	.nan	legacy
	.module	softfloat
	.module	oddspreg
	.abicalls
	.text
	.globl	a
	.data
	.align	2
	.type	a, @object
	.size	a, 4
a:
	.word	114514
	.text
	.align	2
	.globl	aaa
	.set	nomips16
	.set	nomicromips
	.ent	aaa
	.type	aaa, @function
aaa:
	.frame	$fp,40,$31		# vars= 0, regs= 3/0, args= 16, gp= 8
	.mask	0xc0010000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	sw	$16,28($sp)
	move	$fp,$sp
	lui	$28,%hi(__gnu_local_gp)
	addiu	$28,$28,%lo(__gnu_local_gp)
	.cprestore	16
	li	$16,1073741824			# 0x40000000
	lui	$2,%hi(a)
	li	$3,2			# 0x2
	sw	$3,%lo(a)($2)
	move	$31,$0
	.option	pic0
	b	$L2
	nop

	.option	pic2
$L3:
	sw	$31,0($16)
	addiu	$31,$31,1
$L2:
	li	$2,33554432			# 0x2000000
	sltu	$2,$31,$2
	bne	$2,$0,$L3
	nop

	lw	$2,%call16(asm_func)($28)
	move	$25,$2
	.reloc	1f,R_MIPS_JALR,asm_func
1:	jalr	$25
	nop

	lw	$28,16($fp)
	nop
	move	$sp,$fp
	lw	$31,36($sp)
	lw	$fp,32($sp)
	lw	$16,28($sp)
	addiu	$sp,$sp,40
	jr	$31
	nop

	.set	macro
	.set	reorder
	.end	aaa
	.size	aaa, .-aaa
	.ident	"GCC: (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0"
