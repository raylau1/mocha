# AXI crossbar

The AXI crossbar forms the primary interconnect in Mocha and is imported from the [PULP AXI repository](https://github.com/pulp-platform/axi).
The documentation for this hardware IP block is located in the [vendored HW directory tree][block doc].

This checklist covers the [design and verification signoffs][stages] for the AXI crossbar block.

## Design sign-offs

### D1

The sign-off checklist items are described in the [D1 design sign-off checklist][D1 checklist].
This sign-off is based on commit [`6122cb1`][d1-commit] (nightly 2026-06-22).

| Type          | Item                       | Status      | Note/Collaterals |
|---------------|----------------------------|-------------|------------------|
| Documentation | SPEC_COMPLETED             | Doone       | [AXI crossbar specification][block doc]
| Documentation | CSR_DEFINED                | N/A         | AXI crossbar has no CSRs.
| RTL           | CLKRST_CONNECTED           | Done        | Modules containing submodules checked: `axi_xbar`, `axi_xbar_unmuxed`, `axi_demux`, `spill_register`, `axi_demux_simple`, `axi_demux_id_counters`, `delta_counter`, `prim_count`, `prim_flop`, `counter`, `rr_arb_tree`, `axi_err_slv`, `axi_atop_filter`, `stream_register`, `fifo_v3`, `prim_fifo_sync`, `prim_fifo_sync_cnt`, `axi_multicut`, `axi_cut` and `axi_mux`. Modules without clocks and resets are confirmed to be purely combinational: `addr_decode`, `lzc` and `axi_id_prepend`.
| RTL           | IP_TOP                     | Done        | This module is defined in `axi_xbar.sv`.
| RTL           | IP_INSTANTIABLE            | Done        | Block is instantiated in `top_chip_system.sv`.
| RTL           | PHYSICAL_MACROS_DEFINED_80 | Done        | `axi_err_slv` AXI channel FIFO depth fixed to constant in `axi_xbar` submodules. `axi_mux` W channel FIFO depth specified in crossbar configuration.
| RTL           | FUNC_IMPLEMENTED           | Done        | All functionality already implemented.
| RTL           | ASSERT_KNOWN_ADDED         | Not Started |
| Code Quality  | LINT_SETUP                 | Not Started |

## Verification sign-offs

*None so far.*

[stages]: stages.md
[block doc]: ../../hw/vendor/pulp_axi/doc/axi_xbar.md
[D1 checklist]: stages.md#d1-design-sign-off-checklist
[design stages]: stages.md#design-stages
[V1 checklist]: stages.md#v1-verification-sign-off-checklist
[verification stages]: stages.md#verification-stages
[d1-commit]: https://github.com/lowRISC/mocha/commit/6122cb1b6d0c43181eeaf23e738bc977723a1361
