#ifndef INT_ENTER_H
#define INT_ENTER_H

#define INT_BUTTON_UP       1
#define INT_BUTTON_LEFT     2
#define INT_BUTTON_RIGHT    3
#define INT_BUTTON_DOWN     4
#define INT_BUTTON_CENTER    5

void int_enter();
void load_int_enter();

void int_hanlder(unsigned cause);

#endif