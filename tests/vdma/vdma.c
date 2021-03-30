#include "../../src/driver/segment_display.h"
#include "../../src/driver/vdma.h"
//python ./tools/program.py -f ./tests/vdma/vdma.out -c COM4

//#include "image.h"

#define TGP_BASE_ADDR 0x44A00000

#define TGP_CONTRAL ((volatile unsigned *)(TGP_BASE_ADDR + 0x00))
#define TGP_HEIGHT ((volatile unsigned *)(TGP_BASE_ADDR + 0x10))
#define TGP_WIDTH ((volatile unsigned *)(TGP_BASE_ADDR + 0x18))

void main(){
    
    register volatile unsigned *display = SEG_DISPLAY_ADDR;
    register volatile unsigned *vdma_sr = VDMA_MM2S_SR;
    register unsigned* addr = VDMA_FRAME_ADDR;
    register unsigned color1 = 0x00000000;
    register unsigned color2 = 0x000f000f;
    register unsigned color3 = 0x00f000f0;
    register unsigned color4 = 0x00ff00ff;
    register unsigned color5 = 0x0f000f00;
    register unsigned color6 = 0x0f0f0f0f;
    register unsigned color7 = 0x0ff00ff0;
    register unsigned color8 = 0x0fff0fff;
    register int i, j, k;
    
    for(i=0;i<600;i++){
        for(j=0;j<50;j++){
            *addr = color1;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color2;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color3;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color4;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color5;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color6;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color7;
            addr+=1;    
        }
        for(j=0;j<50;j++){
            *addr = color8;
            addr+=1;    
        }
    }
    vdma_init();
    //for(i=0;i<0x02200000;i++)
    //    *display = *vdma_sr;
    return ;
}