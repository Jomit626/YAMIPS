#include "../driver/timer.h"
#include "../interrupt/interrupt_enter.h"
#include "../driver/vdma.h"
#include "../driver/segment_display.h"
#include "game.h"

unsigned buttons = 0x0;

static unsigned frame_time = 0x0;

void int_handler(unsigned cause){
    buttons |= (0x1 << cause);
}

void main(){
    register unsigned frame_interval = 33333; // 33.333 ms between frames
    register unsigned last_frame_time;

    // interrupt init
    load_int_enter();

    // graphic init
    vdma_init();
    vdma_ram_init();

    game_init();
    
    buttons = 0;

    // main game loop
    while(1){
        
        last_frame_time = frame_time;
        
        // wait next frame
        while((TIME - last_frame_time) < frame_interval)
            ;
        frame_time = TIME;
        
        if( game_loop(buttons) )
            break;

        // clean buttons, because interrupt comes only when buttons are pressed
        buttons = 0;
    }
}