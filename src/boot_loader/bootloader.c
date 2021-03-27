#include "../driver/uart.h"
#include "bootloader.h"

#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)
void _test();
void main(){
    CRAL_REG = CRAL_RST_TX | CRAL_RST_RX & ~CRAL_EN_INT;
    SEG_DISPLAY = 1;
    //_test();
    while(1){
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
    unsigned *ins = (unsigned*)0xC8000000;
    void (*enter)(void);
    enter = (void (*)(void))0xc8000020;
    ins[0] =0X27bdfff0;
    ins[1] =0X3c104000;
    ins[2] =0Xae1d0000;
    ins[3] =0X3e00008;
    ins[4] =0X27bd0010;
    ins[5] =0X0;
    ins[6] =0X0;
    ins[7] =0X0;
    ins[8] =0X27bdffd8;
    ins[9] =0Xafbf0024;
    ins[10] =0Xafbe0020;
    ins[11] =0Xafb0001c;
    ins[12] =0X3a0f025;
    ins[13] =0X3c1cc802;
    ins[14] =0X279c80b0;
    ins[15] =0Xafbc0010;
    ins[16] =0X3c104000;
    ins[17] =0X3c02c801;
    ins[18] =0X24030002;
    ins[19] =0Xac4300b0;
    ins[20] =0Xf825;
    ins[21] =0X10000003;
    ins[22] =0X0;
    ins[23] =0Xae1f0000;
    ins[24] =0X27ff0001;
    ins[25] =0X3c020200;
    ins[26] =0X3e2102b;
    ins[27] =0X1440fffb;
    ins[28] =0X0;
    ins[29] =0X8f828018;
    ins[30] =0X40c825;
    ins[31] =0X411ffe0;
    ins[32] =0X0;
    ins[33] =0X8fdc0010;
    ins[34] =0X0;
    ins[35] =0X3c0e825;
    ins[36] =0X8fbf0024;
    ins[37] =0X8fbe0020;
    ins[38] =0X8fb0001c;
    ins[39] =0X27bd0028;
    ins[40] =0X3e00008;
    ins[41] =0X0;
    ins[42] =0X0;
    ins[43] =0X0;
    enter();
}