#ifndef VDMA_H
#define VDMA_H

#define VDMA_BASE_ADDR 0x44A00000
#define VDMA_FRAME_ADDR ((unsigned *)0xC8000000)

#define VDMA_VERSION ((volatile unsigned *)(VDMA_BASE_ADDR + 0x2c))

#define VDMA_MM2S_CR ((volatile unsigned *)(VDMA_BASE_ADDR + 0x00))
#define VDMA_MM2S_SR ((volatile unsigned *)(VDMA_BASE_ADDR + 0x04))
#define VDMA_MM2S_REG_INDEX ((volatile unsigned *)(VDMA_BASE_ADDR + 0x14))


#define VDMA_MM2S_VS ((volatile unsigned *)(VDMA_BASE_ADDR + 0x50))
#define VDMA_MM2S_HS ((volatile unsigned *)(VDMA_BASE_ADDR + 0x54))
#define VDMA_MM2S_FRMDLY_STRID ((volatile unsigned *)(VDMA_BASE_ADDR + 0x58))
#define VDMA_MM2S_START_ADDR(n) ((volatile unsigned **)(VDMA_BASE_ADDR + 0x58 + (n << 2))) // n >= 1

#define MONITOR_HEIGHT  600
#define MONITOR_WIDTH   800
#define MONITOR_PIX_SIZE  2

inline static void vdma_init(){
    // send reset
    *VDMA_MM2S_CR = 0x3;

    // set start addr
    *VDMA_MM2S_START_ADDR(1) = VDMA_FRAME_ADDR;  
    *VDMA_MM2S_START_ADDR(2) = VDMA_FRAME_ADDR;
    *VDMA_MM2S_START_ADDR(3) = VDMA_FRAME_ADDR;

    // set stride
    // stride = 0x640 = 800 * 2
    *VDMA_MM2S_FRMDLY_STRID = MONITOR_WIDTH * MONITOR_PIX_SIZE;

    // set h size
    *VDMA_MM2S_HS =  MONITOR_WIDTH * MONITOR_PIX_SIZE;

    // set v size
    *VDMA_MM2S_VS = MONITOR_HEIGHT;
}


static void vdma_ram_init(){
    register unsigned* addr = VDMA_FRAME_ADDR;
    register unsigned color1 = 0x00000000;
    register unsigned color2 = 0x000f000f;
    register unsigned color3 = 0x00f000f0;
    register unsigned color4 = 0x00ff00ff;
    register unsigned color5 = 0x0f000f00;
    register unsigned color6 = 0x0f0f0f0f;
    register unsigned color7 = 0x0ff00ff0;
    register unsigned color8 = 0x0fff0fff;
    register int i, j;
    
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
}
#endif