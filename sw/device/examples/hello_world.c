// Copyright lowRISC contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "boot/trap.h"
#include "hal/gpio.h"
#include "hal/mocha.h"
#include "hal/timer.h"
#include "hal/uart.h"
#include "runtime/print.h"
#include <stdint.h>

int main(void)
{
    gpio_t gpio = mocha_system_gpio();
    uart_t uart = mocha_system_uart();
    timer_t timer = mocha_system_timer();
    rom_ctrl_t rom_ctrl = mocha_system_rom_ctrl();
    rom_t rom = mocha_system_rom();
    gpio_set_oe_pin(gpio, 0, false);
    uprintf(uart, "IO0: %x\n", gpio_read_pin(gpio, 0));

    gpio_set_oe_pin(gpio, 0, true);
    gpio_set_oe_pin(gpio, 1, true);
    gpio_set_oe_pin(gpio, 2, true);
    gpio_set_oe_pin(gpio, 3, true);
    uart_init(uart);
    timer_init(timer);

    timer_enable_write(timer, true);

    uprintf(uart, "Hello CHERI Mocha!\n");

    // uprintf(uart, "ROM F: %x\n", DEV_READ(rom_ctrl + 0x4));
    uprintf(uart, "DIG:    %x %x %x %x %x %x %x %x\n",
        DEV_READ(rom_ctrl + 0x8),
        DEV_READ(rom_ctrl + 0xc),
        DEV_READ(rom_ctrl + 0x10),
        DEV_READ(rom_ctrl + 0x14),
        DEV_READ(rom_ctrl + 0x18),
        DEV_READ(rom_ctrl + 0x1c),
        DEV_READ(rom_ctrl + 0x20),
        DEV_READ(rom_ctrl + 0x24)
    );
    uprintf(uart, "EXPDIG: %x %x %x %x %x %x %x %x\n",
        DEV_READ(rom_ctrl + 0x28),
        DEV_READ(rom_ctrl + 0x2c),
        DEV_READ(rom_ctrl + 0x30),
        DEV_READ(rom_ctrl + 0x34),
        DEV_READ(rom_ctrl + 0x38),
        DEV_READ(rom_ctrl + 0x3c),
        DEV_READ(rom_ctrl + 0x40),
        DEV_READ(rom_ctrl + 0x44)
    );

    for (int j = 0; j < 0x1ffe; j = j + 7) {
        uprintf(uart, "@%x", j);
        for (int i = 0; i < 7; ++i) {
            uprintf(uart, " %x", DEV_READ(rom + (j + i) * 4));
        }
        uprintf(uart, "\n");
        timer_busy_sleep_us(timer, 10000u);
    }
    uprintf(uart, "@00001ffe %x %x\n", DEV_READ(rom + (0x1ffe) * 4), DEV_READ(rom + (0x1fff) * 4));

    // Print every 100us
    for (int i = 0; i < 4; ++i) {
        timer_busy_sleep_us(timer, 100u);

        uprintf(uart, "timer 100us\n");
        gpio_write_pin(gpio, i, 1); // turn on LEDs in sequence
    }

    // Trying out simulation exit.
    uprintf(uart, "Safe to exit simulator.\xd8\xaf\xfb\xa0\xc7\xe1\xa9\xd7");
    uprintf(uart, "This should not be printed in simulation.\r\n");
    uprintf(uart, "TEST RESULT: PASSED\n");

    return 0;
}

void _trap_handler(struct trap_registers *registers, struct trap_context *context)
{
    (void)registers;
    (void)context;
}
