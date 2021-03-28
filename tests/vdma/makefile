obj-asm	= 
obj-c	= vdma.o

ENTER	= main
OUTPUT 	= vdma.out

LDFLAGS=  -e $(ENTER) -call_shared -Ttext $(TEXT_ADDR) -Tdata 0xC9000000

$(OUTPUT) : $(obj-asm) $(obj-c) 
	$(LD) $(LDFLAGS) $(obj-asm) $(obj-c) -o $@

include $(obj-c:.o=.d)

$(obj-asm) : %.o : %.asm
	$(AS) $(ASFLAG) $< -o $@

$(obj-c) : %.o : %.c
	$(CC) $(CFLAG) $< -o $@

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

clean :
	-rm $(TEST_OUT) $(obj-asm) $(obj-c)

.PHONY: clean