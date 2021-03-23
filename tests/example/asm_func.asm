.text
.abicalls

.globl  asm_func
.type   asm_func, @function
asm_func:
    addiu $sp, $sp, -16
    lui $s0, 0x4000
    sw $sp, ($s0)
    addiu $sp, $sp, 16
    jr $ra
