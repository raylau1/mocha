// Copyright lowRISC and contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module axi_to_tlul #(
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
  // Clocking and reset
  input  logic clk_i,
  input  logic rst_ni,

  // AXI4+ATOP subordinate port, request input.
  input  axi_req_t  axi_req_i,
  // AXI4+ATOP subordinate port, response output.
  output axi_resp_t axi_resp_o,

  // TL-UL request property
  input  prim_mubi_pkg::mubi4_t instr_type_i,

  // TL-UL manager interface
  output tlul_pkg::tl_h2d_t tl_o,
  input  tlul_pkg::tl_d2h_t tl_i
);

  // Currently only supports 64-bit AXI data to 32-bit TL-UL data conversion
  `ASSERT_INIT(AXIDataWidth64, AxiDataWidth == 64)
  `ASSERT_INIT(TLULDataWidth32, top_pkg::TL_DW == 32)

  // 64-bit memory format signals
  logic                        mem64_req;
  logic                        mem64_gnt;
  logic                        mem64_we;
  logic [(AxiDataWidth/8)-1:0] mem64_be;
  logic [AxiAddrWidth-1:0]     mem64_addr;
  logic [AxiDataWidth-1:0]     mem64_wdata;
  logic                        mem64_rvalid;
  logic [AxiDataWidth-1:0]     mem64_rdata;

  // 32-bit memory format signals
  logic                          mem32_req;
  logic                          mem32_gnt;
  logic                          mem32_we;
  logic [(top_pkg::TL_DW/8)-1:0] mem32_be;
  logic [top_pkg::TL_AW-1:0]     mem32_addr;
  logic [top_pkg::TL_DW-1:0]     mem32_wdata;
  logic                          mem32_rvalid;
  logic [top_pkg::TL_DW-1:0]     mem32_rdata;

  // AXI to 64-bit mem
  axi_to_mem #(
    .axi_req_t  ( axi_req_t    ),
    .axi_resp_t ( axi_resp_t   ),
    .AddrWidth  ( AxiAddrWidth ),
    .DataWidth  ( AxiDataWidth ),
    .IdWidth    ( AxiIdWidth   ),
    .NumBanks   ( 1            )
  ) u_axi_to_mem (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),

    // AXI interface.
    .busy_o     ( ),
    .axi_req_i  (axi_req_i),
    .axi_resp_o (axi_resp_o),

    // Memory interface.
    .mem_req_o    (mem64_req),
    .mem_gnt_i    (mem64_gnt),
    .mem_addr_o   (mem64_addr),
    .mem_wdata_o  (mem64_wdata),
    .mem_strb_o   (mem64_be),
    .mem_atop_o   ( ),
    .mem_we_o     (mem64_we),
    .mem_rvalid_i (mem64_rvalid),
    .mem_rdata_i  (mem64_rdata)
  );

  // 64-bit mem to 32-bit mem for TLUL ROM
  mem_downsizer u_mem_downsizer (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),

    // 64-bit memory request in
    .mem64_req_i    (mem64_req),
    .mem64_gnt_o    (mem64_gnt),
    .mem64_we_i     (mem64_we),
    .mem64_be_i     (mem64_be),
    .mem64_addr_i   (mem64_addr),
    .mem64_wdata_i  (mem64_wdata),
    .mem64_rvalid_o (mem64_rvalid),
    .mem64_rdata_o  (mem64_rdata),

    // 32-bit memory request out
    .mem32_req_o    (mem32_req),
    .mem32_gnt_i    (mem32_gnt),
    .mem32_we_o     (mem32_we),
    .mem32_be_o     (mem32_be),
    .mem32_addr_o   (mem32_addr),
    .mem32_wdata_o  (mem32_wdata),
    .mem32_rvalid_i (mem32_rvalid),
    .mem32_rdata_i  (mem32_rdata)
  );

  // 32-bit mem to TLUL for TLUL ROM
  tlul_adapter_host #(
    .EnableDataIntgGen      ( 1 ),
    .EnableRspDataIntgCheck ( 1 )
  ) u_tlul_host_adapter (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),

    .req_i        (mem32_req),
    .gnt_o        (mem32_gnt),
    .addr_i       (mem32_addr),
    .we_i         (mem32_we),
    .wdata_i      (mem32_wdata),
    .wdata_intg_i ('0),
    .be_i         (mem32_be),
    .instr_type_i (instr_type_i),
    .user_rsvd_i  ('0),

    .valid_o      (mem32_rvalid),
    .rdata_o      (mem32_rdata),
    .rdata_intg_o ( ),
    .err_o        ( ),
    .intg_err_o   ( ),

    .tl_o         (tl_o),
    .tl_i         (tl_i)
  );

endmodule
