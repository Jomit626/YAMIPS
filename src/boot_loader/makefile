CC=mips-linux-gnu-gcc
LD=mips-linux-gnu-ld
AS=mips-linux-gnu-as
OBJDUMP=mips-linux-gnu-objdump
AWK=awk

AS_FLAGS= -mips32 -no-break -no-trap -msoft-float
CC_FLAGS=-mips32 -mgp32 -msoft-float -mno-llsc \
		-mno-dsp -mno-dspr2 -mno-smartmips -mno-split-addresses \
		-mno-mad  -mno-flush-func -mno-branch-likely -mno-madd4 \
		-fno-hosted -c

FILTER_INSTRUCTION='$$2 ~ "[0-9a-f]{8}" { print $$2","} END{print "00000000;"}'

TEXTADDR= 0xC0000000

bootloader : entry.asm  bootloader.c
	$(CC) $(CC_FLAGS) bootloader.c -o bootloader.o
	$(AS) $(AS_FLAGS) entry.asm -o entry.o
	$(LD) -Ttext $(TEXTADDR)  entry.o bootloader.o -o bootloader.out
	$(OBJDUMP) bootloader.out -d -j .text | $(AWK) -f obj_to_coe.awk > bootloader.coe
clean :
