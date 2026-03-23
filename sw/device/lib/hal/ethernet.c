// Copyright lowRISC contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hal/ethernet.h"
#include "hal/mmio.h"
#include <stdbool.h>
#include <stdint.h>

void ethernet_mac_address_set(ethernet_t ethernet, uint64_t address)
{
    DEV_WRITE64(ethernet + ETHERNET_MACLO_REG, htonl((uint32_t)(address >> 16)));
    DEV_WRITE64(ethernet + ETHERNET_MACHI_REG, htons((uint16_t)(address & 0xFFFF)));
    DEV_WRITE64(ethernet + ETHERNET_RFCS_REG, 8);
}

uint64_t ethernet_mac_address_get(ethernet_t ethernet)
{
    uint16_t hi = ntohs(DEV_READ64(ethernet + ETHERNET_MACHI_REG) & ETHERNET_MACHI_MACADDR_MASK);
    uint32_t lo = ntohl(DEV_READ64(ethernet + ETHERNET_MACLO_REG));
    return ((uint64_t)hi) | ((uint64_t)lo << 16);
}
