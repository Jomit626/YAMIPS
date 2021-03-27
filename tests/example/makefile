obj-asm	= asm_func.o
obj-c	= example.o

ENTER	= aaa
OUTPUT 	= example.out

LDFLAGS=  -e $(ENTER) -call_shared -Ttext $(TEXT_ADDR) -Tdata $(DATA_ADDR)

$(OUTPUT) : $(obj-asm) $(obj-c) 
	$(LD) $(LDFLAGS) $(obj-asm) $(obj-c) -o $@

$(obj-asm) : %.o : %.asm
	$(AS) $(ASFLAG) $< -o $@

$(obj-c) : %.o : %.c
	$(CC) $(CFLAG) $< -o $@

clean :
	-rm $(TEST_OUT) $(obj-asm) $(obj-c)

.PHONY: clean