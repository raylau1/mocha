// Copyright lowRISC contributors (COSMIC project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module chip_mocha_genesys2 #(
  parameter BootRomInitFile = "",
  parameter LogoRomInitFile = ""
) (
  // Onboard 200MHz oscillator
  input  logic sysclk_200m_ni,
  input  logic sysclk_200m_pi,

  // External reset
  input  logic ext_rst_ni,

  // UART
  input  logic uart_rx_i,
  output logic uart_tx_o,

  // SPI
  input  logic spi_device_sck_i,
  input  logic spi_device_csb_i,
  input  logic spi_device_sd_i,
  output logic spi_device_sd_o,

  // HDMI video signal
  output logic [2:0] hdmi_data_po,
  output logic [2:0] hdmi_data_no,
  output logic       hdmi_pix_clk_po,
  output logic       hdmi_pix_clk_no
);
  // Rest of chip AXI crossbar configuration
  localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts:         int'(top_pkg::RestOfChipAxiXbarHosts),
    NoMstPorts:         int'(top_pkg::RestOfChipAxiXbarDevices),
    MaxMstTrans:        32'd10,
    MaxSlvTrans:        32'd6,
    FallThrough:        1'b0,
    LatencyMode:        axi_pkg::CUT_ALL_AX,
    PipelineStages:     32'd1,
    AxiIdWidthSlvPorts: 32'd5,
    AxiIdUsedSlvPorts:  32'd1,
    UniqueIds:          1'b0,
    AxiAddrWidth:       int'(top_pkg::AxiAddrWidth),
    AxiDataWidth:       int'(top_pkg::AxiDataWidth / 8), // In bytes
    NoAddrRules:        int'(top_pkg::RestOfChipAxiXbarDevices)
  };

  // Rest of chip AXI crossbar address mapping
  axi_pkg::xbar_rule_64_t [xbar_cfg.NoAddrRules-1:0] addr_map;
  assign addr_map = '{
    '{ idx: top_pkg::FrameBuffer, start_addr: top_pkg::FrameBufferBase, end_addr: top_pkg::FrameBufferBase + top_pkg::FrameBufferLength }
  };

  // Internal clock and reset signals
  logic clk_50m;
  logic clk_pix;
  logic clk_tmds;
  logic rst_n;

  // PLL lock signal
  logic pll_locked;

  // QSPI signals
  logic [3:0] qspi_device_sdo;
  logic [3:0] qspi_device_sdo_en;

  // AXI signals
  // top_pkg::axi_resp_t rest_of_chip_resp;
  top_pkg::axi_req_t  [xbar_cfg.NoSlvPorts-1:0] xbar_host_req;
  top_pkg::axi_resp_t [xbar_cfg.NoSlvPorts-1:0] xbar_host_resp;
  top_pkg::axi_req_t  [xbar_cfg.NoMstPorts-1:0] xbar_device_req;
  top_pkg::axi_resp_t [xbar_cfg.NoMstPorts-1:0] xbar_device_resp;

  // Frame buffer memory signals
  logic        frame_buffer_mem_en;
  logic [16:0] frame_buffer_mem_addr;
  logic [63:0] frame_buffer_mem_data;

  // Logo ROM memory signals
  logic        logo_rom_en;
  logic [17:0] logo_rom_addr;
  logic  [7:0] logo_rom_data;

  // Clock generation
  clkgen_xil7series u_clk_gen(
    .clk_200m_ni (sysclk_200m_ni),
    .clk_200m_pi (sysclk_200m_pi),
    .pll_locked_o(pll_locked),
    .clk_50m_o   (clk_50m),
    .clk_pix_o   (clk_pix),
    .clk_tmds_o  (clk_tmds)
  );

  // Internal reset generation
  assign rst_n = pll_locked & ext_rst_ni;

  // Rest of chip AXI crossbar
  axi_xbar #(
    .Cfg          (xbar_cfg               ),
    .ATOPs        (1'b0                   ),
    .Connectivity ('1                     ),
    .slv_aw_chan_t(top_pkg::axi_aw_chan_t ),
    .mst_aw_chan_t(top_pkg::axi_aw_chan_t ),
    .w_chan_t     (top_pkg::axi_w_chan_t  ),
    .slv_b_chan_t (top_pkg::axi_b_chan_t  ),
    .mst_b_chan_t (top_pkg::axi_b_chan_t  ),
    .slv_ar_chan_t(top_pkg::axi_ar_chan_t ),
    .mst_ar_chan_t(top_pkg::axi_ar_chan_t ),
    .slv_r_chan_t (top_pkg::axi_r_chan_t  ),
    .mst_r_chan_t (top_pkg::axi_r_chan_t  ),
    .slv_req_t    (top_pkg::axi_req_t     ),
    .slv_resp_t   (top_pkg::axi_resp_t    ),
    .mst_req_t    (top_pkg::axi_req_t     ),
    .mst_resp_t   (top_pkg::axi_resp_t    ),
    .rule_t       (axi_pkg::xbar_rule_64_t)
  ) u_rest_of_chip_axi_xbar (
    .clk_i                (clk_50m),
    .rst_ni               (rst_n),
    .test_i               (1'b0),
    .slv_ports_req_i      (xbar_host_req),
    .slv_ports_resp_o     (xbar_host_resp),
    .mst_ports_req_o      (xbar_device_req),
    .mst_ports_resp_i     (xbar_device_resp),
    .addr_map_i           (addr_map),
    .en_default_mst_port_i('0),
    .default_mst_port_i   ('0)
  );

  // CHERI Mocha top
  top_chip_system #(
    .SramInitFile(BootRomInitFile)
  ) u_top_chip_system (
    // Clock and reset
    .clk_i    (clk_50m),
    .rst_ni   (rst_n),
    // UART
    .uart_rx_i,
    .uart_tx_o,

    .spi_device_sck_i     (spi_device_sck_i),
    .spi_device_csb_i     (spi_device_csb_i),
    .spi_device_sd_o      (qspi_device_sdo),
    .spi_device_sd_en_o   (qspi_device_sdo_en),
    .spi_device_sd_i      ({3'h0, spi_device_sd_i}), // SPI MOSI = QSPI DQ0
    .spi_device_tpm_csb_i ('0),

    // Not using rest of chip
    .rest_of_chip_req_o  (xbar_host_req[top_pkg::Mocha]),
    .rest_of_chip_resp_i (xbar_host_resp[top_pkg::Mocha])
  );

  // Video frame buffer
  axi_frame_buffer #(
    .LogoRomInitFile(LogoRomInitFile)
  ) u_frame_buffer (
    // Clocks and reset
    .clk_axi_i (clk_50m),
    .clk_pix_i (clk_pix),
    .rst_ni    (rst_n),

    // AXI port
    .axi_req_i  (xbar_device_req[top_pkg::FrameBuffer]),
    .axi_resp_o (xbar_device_resp[top_pkg::FrameBuffer]),

    // Frame buffer memory signals
    .mem_en   (frame_buffer_mem_en),
    .mem_addr (frame_buffer_mem_addr),
    .mem_data (frame_buffer_mem_data),

    // Logo ROM memory signals
    .logo_rom_en   (logo_rom_en),
    .logo_rom_addr (logo_rom_addr),
    .logo_rom_data (logo_rom_data)
  );

  // Video transmission logic
  video_tx u_video_tx (
    // Clocking
    .clk_pix_i  (clk_pix),
    .clk_tmds_i (clk_tmds),

    // Reset
    .rst_ni (rst_n),

    // Frame buffer memory signals
    .mem_en   (frame_buffer_mem_en),
    .mem_addr (frame_buffer_mem_addr),
    .mem_data (frame_buffer_mem_data),

    // Logo ROM memory signals
    .logo_rom_en   (logo_rom_en),
    .logo_rom_addr (logo_rom_addr),
    .logo_rom_data (logo_rom_data),

    // Differential video output
    .dvi_data_po    (hdmi_data_po),
    .dvi_data_no    (hdmi_data_no),
    .dvi_pix_clk_po (hdmi_pix_clk_po),
    .dvi_pix_clk_no (hdmi_pix_clk_no)
  );

  // SPI tri-state output driver
  OBUFT u_spi_obuft (
    .I(qspi_device_sdo[1]),     // SPI MISO = QSPI DQ1
    .T(~qspi_device_sdo_en[1]), // SPI MISO = QSPI DQ1
    .O(spi_device_sd_o)
  );
endmodule
