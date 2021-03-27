.text
.abicalls

.globl  __start
.type   __start, @function

__start:
    lui $sp, 0xD000
    ori $sp, 0x0000

    j main
    nop
