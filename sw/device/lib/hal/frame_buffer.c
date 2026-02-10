// Copyright lowRISC contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hal/frame_buffer.h"
#include "hal/mmio.h"
#include <stdint.h>

void frame_buffer_write_pixel_565(frame_buffer_t frame_buffer, uint16_t x, uint16_t y, uint8_t r, uint8_t g, uint8_t b) {
    if (x >= FRAME_BUFFER_WIDTH || y >= FRAME_BUFFER_HEIGHT) {
        return;
    }

    DEV_WRITE16(
        frame_buffer + (y * FRAME_BUFFER_WIDTH * FRAME_BUFFER_BYTES_PER_PIXEL) + (x * FRAME_BUFFER_BYTES_PER_PIXEL),
        (r & 0b11111) | ((g & 0b111111) << 5) | ((b & 0b11111) << 11)
    );
}