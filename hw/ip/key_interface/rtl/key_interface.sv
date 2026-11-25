// Copyright lowRISC and contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module key_interface #(
  /// AXI4+ATOP request type.
  parameter type         axi_req_t    = logic,
  /// AXI4+ATOP response type.
  parameter type         axi_resp_t   = logic,
  /// AXI4+ATOP Address width.
  parameter int unsigned AxiAddrWidth = 0,
  /// AXI4+ATOP data width.
  parameter int unsigned AxiDataWidth = 0,
  /// AXI4+ATOP ID width.
  parameter int unsigned AxiIdWidth   = 0
) (
  // Clock and reset
  input  logic clk_i,
  input  logic rst_ni,

  // Capability AXI interface
  input  axi_req_t  axi_req_i,
  output axi_resp_t axi_resp_o,

  // Key interface port
  output logic [key_interface_pkg::KeyWidth-1:0] key_o
);

  // Internal TileLink signals to registers
  tlul_pkg::tl_h2d_t tl_regs_h2d;
  tlul_pkg::tl_d2h_t tl_regs_d2h;

  // Register signals
  key_interface_reg_pkg::key_interface_reg2hw_t reg2hw;

  // AXI to TL-UL conversion
  axi_to_tlul #(
    .axi_req_t    ( axi_req_t    ),
    .axi_resp_t   ( axi_resp_t   ),
    .AxiAddrWidth ( AxiAddrWidth ),
    .AxiDataWidth ( AxiDataWidth ),
    .AxiIdWidth   ( AxiIdWidth   )
  ) u_axi_to_tlul (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .axi_req_i  (axi_req_i),
    .axi_resp_o (axi_resp_o),

    .instr_type_i (prim_mubi_pkg::MuBi4False),

    .tl_o (tl_regs_h2d),
    .tl_i (tl_regs_d2h)
  );

  // Register top instance
  key_interface_reg_top u_reg_top (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),

    .tl_i (tl_regs_h2d),
    .tl_o (tl_regs_d2h),

    .reg2hw (reg2hw),

    // Unused, axi_to_tlul is assumed to generate correct integrity
    .intg_err_o ( )
  );

  // Expose key on dedicated port
  // Packing order is intentionally different from that in key_interface_reg_pkg
  assign key_o = {
    reg2hw.key7,
    reg2hw.key6,
    reg2hw.key5,
    reg2hw.key4,
    reg2hw.key3,
    reg2hw.key2,
    reg2hw.key1,
    reg2hw.key0
  };

  // Output known assertions
  `ASSERT_KNOWN(AwReadyKnownO_A, axi_resp_o.aw_ready)
  `ASSERT_KNOWN(ArReadyKnownO_A, axi_resp_o.ar_ready)
  `ASSERT_KNOWN(WReadyKnownO_A, axi_resp_o.w_ready)
  `ASSERT_KNOWN(BValidKnownO_A, axi_resp_o.b_valid)
  `ASSERT_KNOWN(RValidKnownO_A, axi_resp_o.r_valid)
  `ASSERT_KNOWN_IF(BKnownO_A, axi_resp_o.b, axi_resp_o.b_valid)
  `ASSERT_KNOWN_IF(RKnownO_A, axi_resp_o.r, axi_resp_o.r_valid)
  `ASSERT_KNOWN(KeyKnownO_A, key_o)

endmodule
