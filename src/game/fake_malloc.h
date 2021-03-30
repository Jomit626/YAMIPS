#ifndef FAKE_MALLOC
#define FAKE_MALLOC

#define FAKE_MALLOC_START_ADDR ((char*)0xCC000000)

void *malloc(unsigned size);

#endif
