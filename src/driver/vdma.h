#ifndef VDMA_H
#define VDMA_H

#define VDMA_BASE_ADDR 0x44A00000
#define VDMA_FRAME_ADDR ((unsigned *)0xC9000000)

#define VDMA_VERSION ((volatile unsigned *)(VDMA_BASE_ADDR + 0x2c))

#define VDMA_MM2S_CR ((volatile unsigned *)(VDMA_BASE_ADDR + 0x00))
#define VDMA_MM2S_SR ((volatile unsigned *)(VDMA_BASE_ADDR + 0x04))
#define VDMA_MM2S_REG_INDEX ((volatile unsigned *)(VDMA_BASE_ADDR + 0x14))


#define VDMA_MM2S_VS ((volatile unsigned *)(VDMA_BASE_ADDR + 0x50))
#define VDMA_MM2S_HS ((volatile unsigned *)(VDMA_BASE_ADDR + 0x54))
#define VDMA_MM2S_FRMDLY_STRID ((volatile unsigned *)(VDMA_BASE_ADDR + 0x58))
#define VDMA_MM2S_START_ADDR(n) ((volatile unsigned **)(VDMA_BASE_ADDR + 0x58 + (n << 2))) // n >= 1


inline static void vdma_init(){
    // send reset
    *VDMA_MM2S_CR = 0x3;

    // set start addr
    *VDMA_MM2S_START_ADDR(1) = VDMA_FRAME_ADDR;  
    *VDMA_MM2S_START_ADDR(2) = VDMA_FRAME_ADDR;
    *VDMA_MM2S_START_ADDR(3) = VDMA_FRAME_ADDR;

    // set stride
    // stride = 0x640 = 800 * 2
    *VDMA_MM2S_FRMDLY_STRID = 800 * 2;

    // set h size
    *VDMA_MM2S_HS =  800 * 2;

    // set v size
    *VDMA_MM2S_VS = 600;
}


static void vdma_test(){
    register unsigned* addr = VDMA_FRAME_ADDR;
    register unsigned color = 0xffffffff;
    register int i, j, k;

    for(i =0; i <800 * 300; i++){
        addr[i] = color;
    }
    //for(i = 0; i < 6; i++){
    //    //color = ((i & 0x1) << 0) | ((i & 0x1) << 1) | ((i & 0x1) << 2) |
    //    //        ((i & 0x2) << 3) | ((i & 0x2) << 4) | ((i & 0x2) << 5) |
    //    //        ((i & 0x4) << 6) | ((i & 0x4) << 7) | ((i & 0x4) << 8);
    //    for(j = 0; j < 100; j++){
    //        for(k = 0; k < 800; k++){
    //            *addr = color;
    //            addr += 1;
    //        }
    //    }
    //}
}
#endif