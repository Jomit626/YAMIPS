#include "fake_malloc.h"

static char* malloc_addr = FAKE_MALLOC_START_ADDR;

void* malloc(unsigned size){
    void* addr = malloc_addr;
    malloc_addr += (size + 0x3) & 0xfffffffC;

    return addr;
}