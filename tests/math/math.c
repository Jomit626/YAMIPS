#include "../../src/driver/segment_display.h"
#include "../../src/math/math.h"
//python ./tools/program.py -f ./tests/vdma/vdma.out -c COM4

void main(){

    unsigned a = 2345;
    SEG_DISPLAY = a; 
    unsigned b = 12345;
    unsigned c = divu(b, a);

    SEG_DISPLAY = c;
    for(int i=0;i<0x00200000;i++)
        ;
    return ;
}