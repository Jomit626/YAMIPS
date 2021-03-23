#ifndef UART_H
#define UART_H

#define UART_CONTRAL_BASE_ADDR 0x40600000

#define RX_FIFO_ADDR        ((volatile unsigned *)(UART_CONTRAL_BASE_ADDR + 0x00))
#define TX_FIFO_ADDR        ((volatile unsigned *)(UART_CONTRAL_BASE_ADDR + 0x04))
#define STAT_REG_ADDR       ((volatile unsigned *)(UART_CONTRAL_BASE_ADDR + 0x08))
#define CRAL_REG_ADDR       ((volatile unsigned *)(UART_CONTRAL_BASE_ADDR + 0x0C))

#define STAT_RX_VALID       (0x00000001 << 0)
#define STAT_RX_FULL        (0x00000001 << 1)
#define STAT_TX_VALID       (0x00000001 << 2)
#define STAT_TX_FULL        (0x00000001 << 3)
#define STAT_INT_EN         (0x00000001 << 4)
#define STAT_ERR_OVERRUN    (0x00000001 << 5)
#define STAT_ERR_FRAME      (0x00000001 << 6)
#define STAT_ERR_PARITY     (0x00000001 << 7)

#define CRAL_RST_TX         (0x00000001 << 0)
#define CRAL_RST_RX         (0x00000001 << 1)
#define CRAL_EN_INT         (0x00000001 << 4)

#define STAT_REG (*((volatile unsigned *)STAT_REG_ADDR))
#define CRAL_REG (*((volatile unsigned *)CRAL_REG_ADDR))

#define RX_FIFO (*((volatile unsigned *)RX_FIFO_ADDR))
#define TX_FIFO (*((volatile unsigned *)TX_FIFO_ADDR))

#define SEG_DISPLAY_ADDR ((volatile unsigned *)0x40000000)

#define SEG_DISPLAY (*SEG_DISPLAY_ADDR)

static inline unsigned __uart_read_word_wait(){
    register unsigned stat;
    register unsigned data;
    volatile register unsigned * const rx_fifo = RX_FIFO_ADDR;
    volatile register unsigned * const stat_reg = STAT_REG_ADDR;
    register unsigned n = 4;
    while(n--){
        data <<= 8;

        do{
            stat = *stat_reg;
        } while(!(stat & STAT_RX_VALID));

        data |= (*rx_fifo) & 0x000000ff;
    }
    
    return data;
}

static inline void __uart_read_word_n_wait(register unsigned *dst, register unsigned n){
    register unsigned stat;
    register unsigned data;
    volatile register unsigned * const rx_fifo = RX_FIFO_ADDR;
    volatile register unsigned * const stat_reg = STAT_REG_ADDR;
    while(n--){
        register unsigned m = 4;
        while(m--){
            data <<= 8;

            do{
            stat = *stat_reg;
            } while(!(stat & STAT_RX_VALID));

            data |= (*rx_fifo) & 0x000000ff;
        }
        
        *dst = data;
        dst++;
    }
}

static inline void __uart_send_word(unsigned data){
    volatile register unsigned * const tx_fifo = TX_FIFO_ADDR;
    *tx_fifo = (data >> 24);
    *tx_fifo = (data >> 16);
    *tx_fifo = (data >> 8);
    *tx_fifo = (data >> 0);
}

#endif