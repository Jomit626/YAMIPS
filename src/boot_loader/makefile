
all : bootloader.coe

bootloader.out : entry.asm  bootloader.c bootloader.h 
	$(CC) $(CFLAG) bootloader.c -o bootloader.o
	$(AS) $(ASFLAG) entry.asm -o entry.o
	$(LD) -Ttext $(PC_INIT)  entry.o bootloader.o -o bootloader.out

bootloader.coe : bootloader.out obj_to_coe.awk
	$(OBJDUMP) bootloader.out -d -j .text | awk -f obj_to_coe.awk > bootloader.coe

clean :
	-rm bootloader.o entry.o bootloader.out bootloader.coe