obj-asm	= 
obj-c	= graphic.o ../../src/game/display.o

ENTER	= main
OUTPUT 	= graphic.out

LDFLAGS=  -e $(ENTER) -call_shared -Ttext $(TEXT_ADDR) -Tdata $(DATA_ADDR)

$(OUTPUT) : $(obj-asm) $(obj-c) 
	$(LD) $(LDFLAGS) $(obj-asm) $(obj-c) -o $@

include $(obj-c:.o=.d)

$(obj-asm) : %.o : %.asm
	$(AS) $(ASFLAG) $< -o $@

$(obj-c) : %.o : %.c
	$(CC) $(CFLAG) -O3 $< -o $@

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

clean :
	-rm $(TEST_OUT) $(obj-asm) $(obj-c)

.PHONY: clean