obj-asm	= int_enter.o
obj-c	= int_handler.o

ENTER	= main
OUTPUT 	= int_test.out

LDFLAGS =  -e $(ENTER) -call_shared -Ttext $(TEXT_ADDR)

$(OUTPUT) : $(obj-asm) $(obj-c) 
	$(LD) $(LDFLAGS) $(obj-asm) $(obj-c) -o $@

$(obj-asm) : %.o : %.asm
	$(AS)  $(ASFLAG) $< -o $@

$(obj-c) : %.o : %.c
	$(CC) $(CFLAG) $< -o $@

clean :
	-rm $(TEST_OUT) $(obj-asm) $(obj-c)

.PHONY: clean