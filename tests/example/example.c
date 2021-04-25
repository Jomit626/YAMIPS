#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)
#define DECLARE_SEG_DISPLAY register volatile unsigned * const seg_display = SEG_DISPLAY_ADDR

void asm_func();

int a = 114514; 
int b = 234124;

void aaa(){
    DECLARE_SEG_DISPLAY;
    register int i;
    a = 2;
    for(i=0x02000000;i>0;i--)
        *seg_display = i;
    asm_func();
    for(i=0;i<0x02000000;i++)
        ;
    return;
}