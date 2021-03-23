TEXTADDR= 0xC2000000

CC=mips-linux-gnu-gcc
LD=mips-linux-gnu-ld
AS=mips-linux-gnu-as

AS_FLAGS= -mips32 -no-break -no-trap -msoft-float
CC_FLAGS= -mips32 -mgp32 -msoft-float -mno-llsc \
		  -mno-dsp -mno-dspr2 -mno-smartmips -mno-split-addresses \
		  -mno-mad  -mno-flush-func -mno-branch-likely -mno-madd4 \
		  -fno-hosted -fpic -c
LD_FLAGS=  -e main -call_shared -Ttext $(TEXTADDR)

obj-asm= asm_func.o
obj-c= example.o

OUTPUT = example.out


$(OUTPUT) : $(obj-asm) $(obj-c) 
	$(LD) $(LD_FLAGS) $(obj-asm) $(obj-c) -o $@

$(obj-asm) : %.o : %.asm
	$(AS) $(AS_FLAGS) $< -o $@

$(obj-c) : %.o : %.c
	$(CC) $(CC_FLAGS) $< -o $@

clean :
	-rm $(TEST_OUT) $(obj-asm) $(obj-c)

.PHONY: clean