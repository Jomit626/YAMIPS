.text
.abicalls

.globl  int_enter
.type   int_enter, @function
int_enter:
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)

    lui $s0, 0x4000
    mfc0 $s1, $13   # cause reg
    srl $s1, $s1, 2
    andi $s1, $s1, 0x000f
    sw $s1, ($s0)
    nor $k0, $zero, $zero

    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addiu $sp, $sp, 16

    eret
    mtc0 $k0, $13   # cause reg

.globl  load_int_enter
.type   load_int_enter, @function
load_int_enter:
    lui $k0, %hi(int_enter)
    ori $k0, $k0, %lo(int_enter)
    nop
    nop
    nop
    nop
    mtc0 $k0, $15   # int enter reg
    nor $k0, $zero, $zero
    nop
    nop
    nop
    nop
    mtc0 $k0, $13   # cause reg
    jr $ra
