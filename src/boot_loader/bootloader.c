#include "../driver/uart.h"
#include "bootloader.h"

#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)
void _test();
void main(){
    while(1){
        SEG_DISPLAY = 1;

        // clear out buf
        CRAL_REG = CRAL_RST_TX | CRAL_RST_RX & ~CRAL_EN_INT;

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