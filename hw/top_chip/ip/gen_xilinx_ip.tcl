# Copyright lowRISC contributors (COSMIC project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.2 -module_name u_xlnx_mig_7_ddr3

exec cp ./src/lowrisc_mocha_chip_mocha_genesys2_0/ip/mig_genesys2_mocha.prj ./lowrisc_mocha_chip_mocha_genesys2_0.srcs/sources_1/ip/u_xlnx_mig_7_ddr3/mig_genesys2_mocha.prj

set_property -dict [list \
  CONFIG.XML_INPUT_FILE {mig_genesys2_mocha.prj} \
  CONFIG.RESET_BOARD_INTERFACE {Custom} \
  CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
  CONFIG.BOARD_MIG_PARAM {Custom}] [get_ips u_xlnx_mig_7_ddr3]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name eth_ila
set_property -dict [list \
  CONFIG.C_DATA_DEPTH {16384} \
  CONFIG.C_NUM_OF_PROBES {10} \
  CONFIG.C_EN_STRG_QUAL {1} \
  CONFIG.C_INPUT_PIPE_STAGES {1} \
  CONFIG.C_PROBE9_WIDTH {1} \
  CONFIG.C_PROBE8_WIDTH {8} \
  CONFIG.C_PROBE7_WIDTH {1} \
  CONFIG.C_PROBE6_WIDTH {1} \
  CONFIG.C_PROBE5_WIDTH {8} \
  CONFIG.C_PROBE4_WIDTH {1} \
  CONFIG.C_PROBE3_WIDTH {1} \
  CONFIG.C_PROBE2_WIDTH {1} \
  CONFIG.C_PROBE1_WIDTH {11} \
  CONFIG.C_PROBE0_WIDTH {1} \
  CONFIG.C_PROBE9_MU_CNT {2} \
  CONFIG.C_PROBE8_MU_CNT {2} \
  CONFIG.C_PROBE7_MU_CNT {2} \
  CONFIG.C_PROBE6_MU_CNT {2} \
  CONFIG.C_PROBE5_MU_CNT {2} \
  CONFIG.C_PROBE4_MU_CNT {2} \
  CONFIG.C_PROBE3_MU_CNT {2} \
  CONFIG.C_PROBE2_MU_CNT {2} \
  CONFIG.C_PROBE1_MU_CNT {2} \
  CONFIG.C_PROBE0_MU_CNT {2} \
  CONFIG.ALL_PROBE_SAME_MU_CNT {2}] [get_ips eth_ila]
