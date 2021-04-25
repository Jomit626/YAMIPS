#include "../math/math.h"
#include "display.h"


void display_set_color(unsigned x, unsigned y, unsigned color){
    volatile char* addr = (volatile char*) VDMA_FRAME_ADDR; 

    addr += mulu(x ,DISPLAY_LINE_STRIDE_BYTE);
    addr += mulu(y ,DISPLAY_BLOCK_STRIDE_BYTE);

    volatile register unsigned* block_base_addr = (unsigned*)addr;
    for(register int i=0; i<BLOCK_HEIGHT_PIX; i++){
        for(register int j=0; j< BLOCK_WIDTH_WORD; j+=1){
            block_base_addr[j] = color;
            //block_base_addr[j+1] = color;
        }
        block_base_addr += MONITOR_LINE_STRIDE_WORD;
    }
    return ;
} 

void display_set_image(unsigned x, unsigned y,const unsigned* image){
    register volatile char* addr = (volatile char*) VDMA_FRAME_ADDR;
    register int k = 0;

    addr += mulu(x ,DISPLAY_LINE_STRIDE_BYTE);
    addr += mulu(y ,DISPLAY_BLOCK_STRIDE_BYTE);

    volatile register unsigned* block_base_addr = (unsigned*)addr;
    for(register int i=0; i<BLOCK_HEIGHT_PIX; i++){
        for(register int j=0; j< BLOCK_WIDTH_WORD; j++){
            block_base_addr[j] = image[k];
            k++;
        }
        block_base_addr += MONITOR_LINE_STRIDE_WORD;
    }
    return ;
} 