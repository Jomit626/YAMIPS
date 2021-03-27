#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)
#define DECLARE_SEG_DISPLAY register volatile unsigned * const seg_display = SEG_DISPLAY_ADDR

void load_int_enter();

void main(){
    DECLARE_SEG_DISPLAY;
    register unsigned i, j;
    j = 0x00080000;
    load_int_enter();

    while(1){
        for(i=0;i<0x01800000;i++)
            ;
        j += 0x00010000;
        *seg_display = j;
    }
    
    return;
}