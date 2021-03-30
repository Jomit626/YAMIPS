export CC	= mips-linux-gnu-gcc
export LD	= mips-linux-gnu-ld
export AS	= mips-linux-gnu-as
export OBJDUMP=mips-linux-gnu-objdump

export CFLAG	= -mips32 -mgp32 -msoft-float -mno-llsc \
				  -mno-dsp -mno-dspr2 -mno-smartmips -mno-split-addresses \
				  -mno-mad  -mno-flush-func -mno-branch-likely -mno-madd4 \
				  -fno-hosted -c
export ASFLAG	= -mips32 -no-break -no-trap -msoft-float
export LDFLAG	=

export ROM_ADDR	= 0xC0000000
export RAM_ADDR	= 0xC8000000
export RAM_ADDR_END	= 0xD0000000

export PC_INIT = $(ROM_ADDR)
export STACK_START = $(RAM_ADDR_END)
export TEXT_ADDR = 0xC9000000
export DATA_ADDR = 0xCA000000


export PROJDIR= $(shell pwd)
game :
	make -C src/game
bootloader:
	make -C src/boot_loader

test:
	make -C tests

clean :
	make -C src/boot_loader clean
	make -C tests clean

.PHONY : bootloader test clean