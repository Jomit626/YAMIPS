#ifndef TIMER_H
#define TIMER_H

#define TIMER_ADDR ((volatile unsigned *)0x40000008)

// us timer
#define TIME (*TIMER_ADDR)

#endif