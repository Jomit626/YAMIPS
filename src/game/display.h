#ifndef DISPLAY_H
#define DISPLAY_H

#include "../driver/vdma.h"


#define MUL_20(x) (((x) << 2) + ((x) << 4))

#define BLOCK_WIDTH_PIX 20
#define BLOCK_HEIGHT_PIX 28

#define BLOCK_WIDTH_WORD (BLOCK_WIDTH_PIX * MONITOR_PIX_SIZE / 4)

#define DISPLAY_WIDTH (MONITOR_WIDTH / BLOCK_WIDTH_PIX)
#define DISPLAY_HEIGHT (MONITOR_HEIGHT / BLOCK_HEIGHT_PIX)

#define DISPLAY_LINE_STRIDE_BYTE (MONITOR_WIDTH * BLOCK_HEIGHT_PIX * MONITOR_PIX_SIZE)
#define DISPLAY_BLOCK_STRIDE_BYTE (BLOCK_WIDTH_PIX * MONITOR_PIX_SIZE)

#define MONITOR_LINE_STRIDE_WORD (MONITOR_WIDTH * MONITOR_PIX_SIZE / 4)

#define DISPLAY_IMAGE_SIZE_WORD (BLOCK_WIDTH_WORD * BLOCK_HEIGHT_PIX)

void display_set_color(unsigned x, unsigned y, unsigned color);
void display_set_image(unsigned x, unsigned y, const unsigned* image);

#endif