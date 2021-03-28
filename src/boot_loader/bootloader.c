#include "../driver/uart.h"
#include "bootloader.h"

#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)
void _test();
void main(){
    CRAL_REG = CRAL_RST_TX | CRAL_RST_RX & ~CRAL_EN_INT;
    //_test();
    while(1){
        SEG_DISPLAY = 1;
        unsigned data = __uart_read_word_wait();
        SEG_DISPLAY = data;
        if(data == COMMAND_PROGRAM)
            _command_program();
        else if(data == COMMAND_JRL)
            _command_jrl();
        else if(data == COMMAND_ECHO)
            _command_echo();
    }
}

void _command_program(){
    SEG_DISPLAY = 4;
    unsigned* baseaddr = (unsigned*)__uart_read_word_wait();
    SEG_DISPLAY = 5;
    unsigned size = __uart_read_word_wait();
    SEG_DISPLAY = 6;
    __uart_read_word_n_wait(baseaddr, size);
    SEG_DISPLAY = 7;
    __uart_send_word(size);
}

void _command_jrl(){
    SEG_DISPLAY = 8;
    unsigned data = __uart_read_word_wait();
    SEG_DISPLAY = 9;
    __uart_send_word(data);
    SEG_DISPLAY = 10;
    ((void (*)(void) )data)();
}

void _command_echo(){
    SEG_DISPLAY = 11;
    register unsigned stat;
    register unsigned data;
    volatile register unsigned *rx_fifo = RX_FIFO_ADDR;
    volatile register unsigned *tx_fifo = TX_FIFO_ADDR;
    volatile register unsigned *stat_reg = STAT_REG_ADDR;
    volatile register unsigned *cral_reg = CRAL_REG_ADDR;

    CRAL_REG = CRAL_RST_TX | CRAL_RST_RX & ~CRAL_EN_INT;
    SEG_DISPLAY = 12;
    while (1)
    {
        SEG_DISPLAY = 13;
        do{
            stat = *stat_reg;
        } while(!(stat & STAT_RX_VALID));

        data = *rx_fifo;
        SEG_DISPLAY = 14;
        do{
            stat = *stat_reg;
        } while(stat & STAT_TX_FULL);
        
        *tx_fifo = data;
    }
}

void _test(){
    register unsigned *ins = (unsigned*)0xC8000000;
    void (*enter)(void);
    enter = (void (*)(void))0xc8000108;
ins[0] =0X27bdfff8;
ins[1] =0Xafbe0004;
ins[2] =0X3a0f025;
ins[3] =0X3c0244a0;
ins[4] =0X2403008b;
ins[5] =0Xac430000;
ins[6] =0X3c0244a0;
ins[7] =0X3442005c;
ins[8] =0X3c03c900;
ins[9] =0Xac430000;
ins[10] =0X3c0244a0;
ins[11] =0X34420060;
ins[12] =0X3c03c900;
ins[13] =0Xac430000;
ins[14] =0X3c0244a0;
ins[15] =0X34420064;
ins[16] =0X3c03c900;
ins[17] =0Xac430000;
ins[18] =0X3c0244a0;
ins[19] =0X34420058;
ins[20] =0X24030640;
ins[21] =0Xac430000;
ins[22] =0X3c0244a0;
ins[23] =0X34420054;
ins[24] =0X24030640;
ins[25] =0Xac430000;
ins[26] =0X3c0244a0;
ins[27] =0X34420050;
ins[28] =0X24030258;
ins[29] =0Xac430000;
ins[30] =0X0;
ins[31] =0X3c0e825;
ins[32] =0X8fbe0004;
ins[33] =0X27bd0008;
ins[34] =0X3e00008;
ins[35] =0X0;
ins[36] =0X27bdfff0;
ins[37] =0Xafbe000c;
ins[38] =0Xafb20008;
ins[39] =0Xafb10004;
ins[40] =0Xafb00000;
ins[41] =0X3a0f025;
ins[42] =0X3c11c900;
ins[43] =0X2412ffff;
ins[44] =0X8025;
ins[45] =0X10000006;
ins[46] =0X0;
ins[47] =0X2001025;
ins[48] =0X21080;
ins[49] =0X2221021;
ins[50] =0Xac520000;
ins[51] =0X26100001;
ins[52] =0X3c020003;
ins[53] =0X3442a980;
ins[54] =0X202102a;
ins[55] =0X1440fff7;
ins[56] =0X0;
ins[57] =0X0;
ins[58] =0X3c0e825;
ins[59] =0X8fbe000c;
ins[60] =0X8fb20008;
ins[61] =0X8fb10004;
ins[62] =0X8fb00000;
ins[63] =0X27bd0010;
ins[64] =0X3e00008;
ins[65] =0X0;
ins[66] =0X27bdffd0;
ins[67] =0Xafbf002c;
ins[68] =0Xafbe0028;
ins[69] =0Xafb30024;
ins[70] =0Xafb20020;
ins[71] =0Xafb1001c;
ins[72] =0Xafb00018;
ins[73] =0X3a0f025;
ins[74] =0X3c114000;
ins[75] =0X3c0244a0;
ins[76] =0X34520004;
ins[77] =0X3c1fc900;
ins[78] =0X2413ffff;
ins[79] =0X8025;
ins[80] =0X10000008;
ins[81] =0X0;
ins[82] =0X2001025;
ins[83] =0Xae220000;
ins[84] =0X2001025;
ins[85] =0X21080;
ins[86] =0X3e21021;
ins[87] =0Xac530000;
ins[88] =0X26100001;
ins[89] =0X3c020007;
ins[90] =0X34425300;
ins[91] =0X202102a;
ins[92] =0X1440fff5;
ins[93] =0X0;
ins[94] =0Xe000000;
ins[95] =0X0;
ins[96] =0X8025;
ins[97] =0X10000004;
ins[98] =0X0;
ins[99] =0X8e420000;
ins[100] =0Xae220000;
ins[101] =0X26100001;
ins[102] =0X3c020220;
ins[103] =0X202102a;
ins[104] =0X1440fffa;
ins[105] =0X0;
ins[106] =0X0;
ins[107] =0X3c0e825;
ins[108] =0X8fbf002c;
ins[109] =0X8fbe0028;
ins[110] =0X8fb30024;
ins[111] =0X8fb20020;
ins[112] =0X8fb1001c;
ins[113] =0X8fb00018;
ins[114] =0X27bd0030;
ins[115] =0X3e00008;
ins[116] =0X0;
ins[117] =0X0;
ins[118] =0X0;
ins[119] =0X0;
    enter();
}
