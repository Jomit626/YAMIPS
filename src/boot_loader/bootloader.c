#include "../driver/uart.h"
#include "bootloader.h"

#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)
void _test();
void main(){
    CRAL_REG = CRAL_RST_TX | CRAL_RST_RX & ~CRAL_EN_INT;
    SEG_DISPLAY = 1;
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
/*
void _test(){
    unsigned *ins = (unsigned*)0xC2000000;
    void (*enter)(void);
    enter = (void (*)(void))0xC2000000;
    ins[0] =0X27bdfff0;
    ins[1] =0Xafbe000c;
    ins[2] =0Xafb10008;
    ins[3] =0Xafb00004;
    ins[4] =0X3a0f025;
    ins[5] =0X3c114000;
    ins[6] =0X8025;
    ins[7] =0X10000003;
    ins[8] =0X0;
    ins[9] =0Xae300000;
    ins[10] =0X26100001;
    ins[11] =0X24020005;
    ins[12] =0X202102b;
    ins[13] =0X1440fffb;
    ins[14] =0X0;
    ins[15] =0X0;
    ins[16] =0X3c0e825;
    ins[17] =0X8fbe000c;
    ins[18] =0X8fb10008;
    ins[19] =0X8fb00004;
    ins[20] =0X27bd0010;
    ins[21] =0X3e00008;
    ins[22] =0X0;
    ins[23] =0X0;
    enter();
}*/