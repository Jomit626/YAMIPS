.text
.abicalls

.globl  __start
.type   __start, @function

__start:
    lui $sp, 0xC200
    ori $sp, 0x2000

    j main
    nop
