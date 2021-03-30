#include "../../src/driver/segment_display.h"
#include "../../src/game/graphic.h"
#include "../../src/math/math.h"
unsigned long __stack_chk_guard = 0xBAAAAAAD;
void __stack_chk_guard_setup(void)
{
     __stack_chk_guard = 0xBAAAAAAD;//provide some magic numbers
}

void __stack_chk_fail(void)                         
{
    //SEG_DISPLAY = 0x0F0F0F0F;                             
    //while (1)
    //    ;
    
}// will be called when guard variable is corrupted 
/*
void display_set_color(unsigned x, unsigned y, unsigned color){
    volatile char* addr = (volatile char*) VDMA_FRAME_ADDR;

    addr += mulu(x ,DISPLAY_LINE_STRIDE_BYTE);
    addr += mulu(y ,DISPLAY_BLOCK_STRIDE_BYTE);

    volatile register unsigned* block_base_addr = (unsigned*)addr;
    for(register int i=0; i<BLOCK_HEIGHT_PIX; i++){
        for(register int j=0; j< BLOCK_WIDTH_WORD; j++)
            block_base_addr[j] = color;
        block_base_addr += MONITOR_LINE_STRIDE_WORD;
    }
    return ;
} 
*/
unsigned color_set[] = {
    0x00000000,
    0x000f000f,
    0x00f000f0,
    0x00ff00ff,
    0x0f000f00,
    0x0f0f0f0f,
    0x0ff00ff0,
    0x0fff0fff,
    0x0f000f00
};
 
void main(){
    vdma_init();
    vdma_ram_init();
    register unsigned color = 0;
    while(1)
    for(int i=0;i<DISPLAY_HEIGHT;i++)
    //int i = 9;
    for(int j=0;j<DISPLAY_WIDTH;j++){
        display_set_color(i, j, color_set[color]);
        color += 1;
        if(color >= 9)
            color = 0;
    }
    return;
}