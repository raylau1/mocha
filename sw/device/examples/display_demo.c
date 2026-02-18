// Copyright lowRISC contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "boot/trap.h"
#include "hal/mocha.h"
#include "hal/frame_buffer.h"
#include "hal/spi_device.h"
#include "hal/timer.h"
#include "hal/uart.h"
#include <stdint.h>

int main(void)
{
    uart_t uart = mocha_system_uart();
    uart_init(uart);

    timer_t timer = mocha_system_timer();
    timer_init(timer);
    timer_set_prescale_step(timer, (SYSCLK_FREQ / 1000000) - 1, 1); // 1 tick/us
    timer_enable(timer);

    uart_puts(uart, "Display demo!\n");


    frame_buffer_t frame_buffer = mocha_system_frame_buffer();
    frame_buffer_write_pixel_565(frame_buffer, 0, 0, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 1, 0, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 2, 0, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 3, 0, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 0, 1, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 1, 1, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 2, 1, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 3, 1, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 0, 2, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 1, 2, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 0, 3, 0b11111, 0b111111, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 1, 3, 0b11111, 0b111111, 0b11111);

    frame_buffer_write_pixel_565(frame_buffer, 510, 0, 0b11111, 0, 0);
    frame_buffer_write_pixel_565(frame_buffer, 511, 0, 0b11111, 0, 0);
    frame_buffer_write_pixel_565(frame_buffer, 510, 1, 0b11111, 0, 0);
    frame_buffer_write_pixel_565(frame_buffer, 511, 1, 0b11111, 0, 0);
    frame_buffer_write_pixel_565(frame_buffer, 510, 2, 0b11111, 0, 0);
    frame_buffer_write_pixel_565(frame_buffer, 511, 2, 0b11111, 0, 0);

    frame_buffer_write_pixel_565(frame_buffer, 0, 1019, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 1, 1019, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 0, 1020, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 1, 1020, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 0, 1021, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 1, 1021, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 0, 1022, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 1, 1022, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 2, 1022, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 3, 1022, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 0, 1023, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 1, 1023, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 2, 1023, 0, 0b111111, 0);
    frame_buffer_write_pixel_565(frame_buffer, 3, 1023, 0, 0b111111, 0);

    frame_buffer_write_pixel_565(frame_buffer, 510, 1021, 0, 0, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 511, 1021, 0, 0, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 510, 1022, 0, 0, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 511, 1022, 0, 0, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 510, 1023, 0, 0, 0b11111);
    frame_buffer_write_pixel_565(frame_buffer, 511, 1023, 0, 0, 0b11111);

    for (int i = 0; i < 300; ++i) {
        for (int j = 0; j < 120; ++j) {
            frame_buffer_write_pixel_565(frame_buffer, 75 + i, 75 + j, 0b11111, 0b111111, 0b11111);
        }
    }

    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 50; ++j) {
            frame_buffer_write_pixel_565(frame_buffer, 100 + j, 100 + i, i, 0, 0);
        }
    }

    for (int i = 0; i < 64; ++i) {
        for (int j = 0; j < 50; ++j) {
            frame_buffer_write_pixel_565(frame_buffer, 200 + j, 100 + i, 0, i, 0);
        }
    }

    for (int i = 0; i < 32; ++i) {
        for (int j = 0; j < 50; ++j) {
            frame_buffer_write_pixel_565(frame_buffer, 300 + j, 100 + i, 0, 0, i);
        }
    }


    return 0;
}

void _trap_handler(struct trap_registers *registers, struct trap_context *context)
{
    (void)registers;
    (void)context;
}
