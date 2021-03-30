.text
.abicalls

.globl  int_enter
.type   int_enter, @function
int_enter:
    addiu $sp, $sp, -20
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $ra, 12($sp)
    sw $a0, 16($sp)
    
    mfc0 $a0, $13   # read cause reg 
    srl $a0, $a0, 2
    andi $a0, $a0, 0x000f   # read cause

    nor $k0, $zero, $zero
    jal int_handler


    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $ra, 12($sp)
    lw $a0, 16($sp)
    addiu $sp, $sp, 20

    eret
    mtc0 $k0, $13   # write cause reg to enable interrupt

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
    mtc0 $k0, $13    # write cause reg to enable interrupt
    jr $ra
