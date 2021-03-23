.text
.abicalls

.globl  __start
.type   __start, @function

__start:
    lui $sp, 0xC200
    ori $sp, 0x1000

    j main
    nop
