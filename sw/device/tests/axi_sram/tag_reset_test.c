// Copyright lowRISC and contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "hal/mocha.h"
#include "hal/rstmgr.h"
#include <stdbool.h>
#include <stdint.h>

bool test_main()
{
    rstmgr_t rstmgr = mocha_system_rstmgr();
    uint32_t reset_reason = rstmgr_reset_reason_get(rstmgr);

    if (reset_reason & RSTMGR_RESET_INFO_POR) {
        rstmgr_reset_reason_clear(rstmgr, RSTMGR_RESET_INFO_POR);

#if defined(__CHERI_PURE_CAPABILITY__)
        uint64_t res1, res2, res3, res4;

        __asm__ volatile(
            "j test_start\n\t"

            // Capability storage.
            ".p2align 7\n\t"
            "storage:\n\t"
            ".zero 64\n\t" // Four capabilities of 16 bytes each.

            // Get capability to storage in t0.
            "test_start: lly t0, storage\n\t"

            // Store valid capabilities.
            "sy t0, 0(t0)\n\t"
            "sy t0, 16(t0)\n\t"
            "sy t0, 32(t0)\n\t"
            "sy t0, 48(t0)\n\t"
            "fence\n\t"

            // Check that all capability tag bits are set.
            "ly t1, 0(t0)\n\t"
            "ytagr %0, t1\n\t"
            "ly t1, 16(t0)\n\t"
            "ytagr %1, t1\n\t"
            "ly t1, 32(t0)\n\t"
            "ytagr %2, t1\n\t"
            "ly t1, 48(t0)\n\t"
            "ytagr %3, t1\n\t"

            : "=r"(res1), "=r"(res2), "=r"(res3), "=r"(res4)
            :
            : "t1", "t0", "memory");
        if (!(res1 != 0 && res2 != 0 && res3 != 0 && res4 != 0)) {
            return false;
        }
#endif /* defined(__CHERI_PURE_CAPABILITY__) */

        rstmgr_software_reset_request(rstmgr);

        // Must wait here for reset to happen.
        while (1) {
        }
    }

    if (reset_reason & RSTMGR_RESET_INFO_SW_RESET) {
        rstmgr_reset_reason_clear(rstmgr, RSTMGR_RESET_INFO_SW_RESET);

#if defined(__CHERI_PURE_CAPABILITY__)
        uint64_t res1, res2, res3, res4;

        __asm__ volatile(
            // Get capability to storage in t0.
            "lly t0, storage\n\t"

            // Check that all capability tag bits are unset.
            "ly t1, 0(t0)\n\t"
            "ytagr %0, t1\n\t"
            "ly t1, 16(t0)\n\t"
            "ytagr %1, t1\n\t"
            "ly t1, 32(t0)\n\t"
            "ytagr %2, t1\n\t"
            "ly t1, 48(t0)\n\t"
            "ytagr %3, t1\n\t"

            : "=r"(res1), "=r"(res2), "=r"(res3), "=r"(res4)
            :
            : "t1", "t0", "memory");
        if (!(res1 == 0 && res2 == 0 && res3 == 0 && res4 == 0)) {
            return false;
        }
#endif /* defined(__CHERI_PURE_CAPABILITY__) */

        return true;
    }

    return false;
}
