#include "display.h"
#include "../driver/segment_display.h"
#include "../driver/timer.h"
#include "../interrupt/interrupt_enter.h"
#include "engin.h"
#include "game.h"

//random
unsigned rand0_63()
{
    static unsigned seed = 0x3456326;
    seed = seed + TIME;
    return seed & 0x1f;
}

//Game ststus,game starts = 1,game end = 2
unsigned game_status = 0;

//snake
#define MAX_LENGTH 400
typedef struct
{
    int x; //row
    int y; //col
} vector;

vector snakes[MAX_LENGTH];
vector snake_v, snake_v_last;
int snake_length = 0;
//food
vector food;

// image
#define BACKGROUND_COLOR 0x00000000
#define BORDER_COLOR 0x0fff0fff
#define SNAKE_COLOR 0x00f000f0
#define FOOD_COLOR 0x0f000f00

#define MAX_ROWS_GAME 20
#define MAX_COLS_GAME 20
static inline int is_out(int x, int y)
{
    return !((y > 0) && (y < MAX_COLS_GAME - 1) && (x > 0) && (x < MAX_ROWS_GAME - 1));
}

static inline int is_on_snake(int x, int y){
    int i;
    for (i = 0; i < snake_length; i++)
    {
        if (x == snakes[i].x && y == snakes[i].y)
            return 1;
    }
    return 0;
}

unsigned game_init()
{
    game_print_border();
    game_create_snake();
    creat_food();

    game_status = 0;  //game_wait_for_start

    return 0;
}

void game_graphic_update()
{
    /*
    static unsigned last_time = 0;
    register unsigned time = TIME;
    if( (time - last_time) > 1000000){
        last_time = time;
        snake_move_and_draw();
    }
    */
    static unsigned tick = 0;

    register unsigned tick_;
    tick_ = 20 - snake_length;
    if(tick_ < 5)
        tick_ = 5;

    if(tick < tick_)
        tick++;
    else{
        tick = 0;
        snake_move_and_draw();
    }
}

void game_over()
{
    game_status = 2;
    display_set_color(food.x, food.y, FOOD_COLOR);
    game_init();
}

unsigned game_loop(unsigned button_status)
{
    if (game_status == 1)
    { //game starts
        if (button_status & BUTTON_UP)
        {
            snake_v.x = -1;
            snake_v.y = 0;
        }
        else if (button_status & BUTTON_LEFT)
        {
            snake_v.x = 0;
            snake_v.y = -1;
        }
        else if (button_status & BUTTON_RIGHT)
        {
            snake_v.x = 0;
            snake_v.y = 1;
        }
        else if (button_status & BUTTON_DOWN)
        {
            snake_v.x = 1;
            snake_v.y = 0;
        }

        //to avoid snake go back
        if (snake_length > 1 && (snake_v.x + snake_v_last.x) == 0 && (snake_v.y + snake_v_last.y) == 0){
            snake_v.x = snake_v_last.x;
            snake_v.y = snake_v_last.y;
        }

        game_graphic_update();
    } else  {
        if (button_status & BUTTON_CENTER)
            game_status = 1;
    }// else if (game_status == 2) {
    //    return 1;
    //}
    
    

    //SEG_DISPLAY = snakes[0].x;
    return 0;
}

void game_print_border()
{
    int row = 0, col = 0;

    for(row = 0; row < MAX_ROWS_GAME; row++)
        for(col = 0;col < MAX_COLS_GAME; col++)
            display_set_color(row, col, BACKGROUND_COLOR);

    for (col = 0; col < MAX_COLS_GAME; col++)
        display_set_color(0, col, BORDER_COLOR);

    for (row = 0; row < MAX_ROWS_GAME; row++)
        display_set_color(row, MAX_COLS_GAME - 1, BORDER_COLOR);

    for (col = MAX_COLS_GAME - 1; col >= 0; col--)
        display_set_color(MAX_ROWS_GAME - 1, col, BORDER_COLOR);

    for (row = MAX_ROWS_GAME - 1; row >= 0; row--)
        display_set_color(row, 0, BORDER_COLOR);
    
    for (row = 0; row < DISPLAY_HEIGHT; row++){
        display_set_color(row, DISPLAY_WIDTH - 1, 0x000f000f);
        display_set_color(row, DISPLAY_WIDTH - 2, 0x00f000f0);
        display_set_color(row, DISPLAY_WIDTH - 3, 0x0f000f00);
        display_set_color(row, DISPLAY_WIDTH - 4, 0x0fff0fff);
    }
}

void game_create_snake()
{
    snake_length = 1;
    snakes[0].x = 5;
    snakes[0].y = 5;

    //first print
    display_set_color(snakes[0].x, snakes[0].y, SNAKE_COLOR);

    snake_v.x = -1;
    snake_v.y = 0;
    snake_v_last.x = -1;
    snake_v_last.x = 0;
}

//snake contral
void snake_move_and_draw()
{
    //record its last move
    snake_v_last.x = snake_v.x;
    snake_v_last.y = snake_v.y;
    //record tail's pos
    int x = snakes[snake_length - 1].x;
    int y = snakes[snake_length - 1].y;
    //make every part of snake move forward
    int i;
    for (i = 1; i < snake_length ; i++)
    {
        snakes[snake_length - i].x = snakes[snake_length - i - 1].x;
        snakes[snake_length - i].y = snakes[snake_length - i - 1].y;
    }
    //make head move forward
    snakes[0].x += snake_v.x;
    snakes[0].y += snake_v.y;

    display_set_color(snakes[0].x, snakes[0].y, SNAKE_COLOR);
    
    //to test if the snake can eat food
    SEG_DISPLAY = ((food.x & 0xff) << 8 | (food.y & 0xff)) | 
                  ((snakes[0].x & 0xff) << 8 | (snakes[0].y & 0xff)) << 16;
    if ((snakes[0].x ^ food.x | snakes[0].y ^ food.y))
    {
        display_set_color(x, y, BACKGROUND_COLOR);
    } else {//remove the tail
        snakes[snake_length].x = x;
        snakes[snake_length].y = y;
        snake_length++;
        //make new food
        SEG_DISPLAY = 0xff00ff00;
        creat_food(); //TODO-------
        
    }
    //out of border?
    //print new head and clear old tail
    if (is_out(snakes[0].x, snakes[0].y))
        game_over();
    //touch self?
    for (i = 1; i < snake_length; i++) {
        if (snakes[0].x == snakes[i].x && snakes[0].y == snakes[i].y)
            game_over();
    }
}

//food
void creat_food()
{
    do{
        food.x = rand0_63();
        food.y = rand0_63();
    } while (is_out(food.x, food.y) || is_on_snake(food.x, food.y));

    display_set_color(food.x, food.y, FOOD_COLOR);
}