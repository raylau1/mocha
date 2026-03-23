// Copyright lowRISC contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hal/mocha.h"
#include "hal/mmio.h"
#include "hal/ethernet.h"
#include "hal/uart.h"
#include "runtime/print.h"
#include <stdbool.h>
#include <stdint.h>

bool reg_test(ethernet_t ethernet, uart_t uart)
{
    uint64_t reg;
    ethernet_mac_address_set(ethernet, 0x55AA01EFCCDD);

    reg = ethernet_mac_address_get(ethernet);
    uprintf(uart, "eth mac: 0x%lx\n", reg);

    if (reg != 0x55AA01EFCCDD) {
        return false;
    }

    // Check if TX is busy
    reg = DEV_READ64(ethernet + ETHERNET_TPLR_REG);
    uprintf(uart, "eth tx busy: 0x%lx\n", reg & ETHERNET_TPLR_BUSY_MASK);

    // write to tx buffer
    DEV_WRITE64(ethernet + ETHERNET_TXBUFF_OFFSET + 0, 0xFFFFFFFFFFFFFFFFUL);
    DEV_WRITE64(ethernet + ETHERNET_TXBUFF_OFFSET + 8, 0x5A5A5A5AA5A5A5A5UL);

    // Send packet
    DEV_WRITE64(ethernet + ETHERNET_TPLR_REG, 0x0FFF0020); // send pkt len 0x20

    // Check if TX is busy
    reg = DEV_READ64(ethernet + ETHERNET_TPLR_REG);
    uprintf(uart, "eth tx busy: 0x%lx\n", reg & ETHERNET_TPLR_BUSY_MASK);

    // Full read
    // Mapped: [0x800-0x900), [0x1000-0x1800), [0x4000-0x8000)
    for (int i = 0x800; i < 0x900; i=i+8) {
        uprintf(uart, "eth[0x%x] = 0x%lx\n", i, DEV_READ64(ethernet + i));
    }
    for (int i = 0x1000; i < 0x1800; i=i+8) {
        uprintf(uart, "eth[0x%x] = 0x%lx\n", i, DEV_READ64(ethernet + i));
    }
    for (int i = 0x4000; i < 0x8000; i=i+8) {
        uprintf(uart, "eth[0x%x] = 0x%lx\n", i, DEV_READ64(ethernet + i));
    }

    // Check if there is received packet
    for (int i=0; i < 10; ++i) {
        reg = DEV_READ64(ethernet + ETHERNET_RSR_REG);
        if (reg & ETHERNET_RSR_RECV_DONE_MASK) {
            // There is received packet
            uprintf(uart, "eth rx pending: RSR = 0x%lx\n", reg);

            int buf, len;

            buf = reg & ETHERNET_RSR_RECV_FIRST_MASK;
            // buf = (reg & ETHERNET_RSR_RECV_NEXT_MASK) >> 4;
            uprintf(uart, "eth rx buf: 0x%x\n", buf);

            len = DEV_READ64(ethernet + ETHERNET_RPLR_REG + ((buf & 0b111) << 3));
            uprintf(uart, "eth rx len: 0x%x\n", len);

            if (len > 0 && len <= ETH_FRAME_LEN + ETH_FCS_LEN) {
                // Copy RX buffer
                if (len >= 8*4) {
                    uprintf(uart, "eth rx u64 0: 0x%lx\n", DEV_READ64(ethernet + ETHERNET_RXBUFF_OFFSET + ((buf & 0b111) << 11) + 0));
                    uprintf(uart, "eth rx u64 1: 0x%lx\n", DEV_READ64(ethernet + ETHERNET_RXBUFF_OFFSET + ((buf & 0b111) << 11) + 8));
                    uprintf(uart, "eth rx u64 2: 0x%lx\n", DEV_READ64(ethernet + ETHERNET_RXBUFF_OFFSET + ((buf & 0b111) << 11) + 16));
                    uprintf(uart, "eth rx u64 3: 0x%lx\n", DEV_READ64(ethernet + ETHERNET_RXBUFF_OFFSET + ((buf & 0b111) << 11) + 24));
                }
            }

            // ack receive
            DEV_WRITE64(ethernet + ETHERNET_RSR_REG, buf);
        } else {
            uprintf(uart, "eth rx empty: RSR = 0x%lx\n", reg);
        }
    }

    return true;
}

bool test_main(uart_t console)
{
    ethernet_t ethernet = mocha_system_ethernet();

    return reg_test(ethernet, console);
}
