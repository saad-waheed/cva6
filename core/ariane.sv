// Copyright 2017-2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 19.03.2017
// Description: Ariane Top-level module


module ariane import ariane_pkg::*; #(
  parameter ariane_pkg::ariane_cfg_t ArianeCfg     = ariane_pkg::ArianeDefaultConfig
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,
  // Core ID, Cluster ID and boot address are considered more or less static
  input  logic [riscv::VLEN-1:0]       boot_addr_i,  // reset boot address
  input  logic [riscv::XLEN-1:0]       hart_id_i,    // hart id in a multicore environment (reflected in a CSR)

  // Interrupt inputs
  input  logic [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
  input  logic                         ipi_i,        // inter-processor interrupts (async)
  // Timer facilities
  input  logic                         time_irq_i,   // timer interrupt in (async)
  input  logic                         debug_req_i,  // debug request (async)
  // Accelerator request port
  output accelerator_req_t             acc_req_o,
  output logic                         acc_req_valid_o,
  input  logic                         acc_req_ready_i,
  // Accelerator response port
  input  accelerator_resp_t            acc_resp_i,
  input  logic                         acc_resp_valid_i,
  output logic                         acc_resp_ready_o,
  // Invalidation requests
  output logic                         acc_cons_en_o,
  input  logic [63:0]                  inval_addr_i,
  input  logic                         inval_valid_i,
  output logic                         inval_ready_o,
`ifdef FIRESIM_TRACE
  // firesim trace port
  output traced_instr_pkg::trace_port_t trace_o,
`endif
`ifdef RVFI_TRACE
  // RISC-V formal interface port (`rvfi`):
  // Can be left open when formal tracing is not needed.
  output ariane_rvfi_pkg::rvfi_port_t  rvfi_o,
`endif
`ifdef PITON_ARIANE
  // L15 (memory side)
  output wt_cache_pkg::l15_req_t       l15_req_o,
  input  wt_cache_pkg::l15_rtrn_t      l15_rtrn_i
`else
  // memory side, AXI Master
  output ariane_axi::req_t             axi_req_o,
  input  ariane_axi::resp_t            axi_resp_i
`endif
);

  cvxif_pkg::cvxif_req_t  cvxif_req;
  cvxif_pkg::cvxif_resp_t cvxif_resp;

  cva6 #(
    .ArianeCfg  ( ArianeCfg )
  ) i_cva6 (
    .clk_i                ( clk_i                     ),
    .rst_ni               ( rst_ni                    ),
    .boot_addr_i          ( boot_addr_i               ),
    .hart_id_i            ( hart_id_i                 ),
    .irq_i                ( irq_i                     ),
    .ipi_i                ( ipi_i                     ),
    .time_irq_i           ( time_irq_i                ),
    .debug_req_i          ( debug_req_i               ),
// Accelerator port
    .acc_req_o            ( acc_req_o                 ),
    .acc_req_valid_o      ( acc_req_valid_o           ),
    .acc_req_ready_i      ( acc_req_ready_i           ),
    .acc_resp_i           ( acc_resp_i                ),
    .acc_resp_valid_i     ( acc_resp_valid_i          ),
    .acc_resp_ready_o     ( acc_resp_ready_o          ),
    .acc_cons_en_o        ( acc_cons_en_o             ),
    .inval_addr_i         ( inval_addr_i              ),
    .inval_valid_i        ( inval_valid_i             ),
    .inval_ready_o        ( inval_ready_o             ),
`ifdef FIRESIME_TRACE
    .trace_o              ( trace_o                   ),
`endif
`ifdef RVFI_TRACE
    .rvfi_o               ( rvfi_o                    ),
`endif
    .cvxif_req_o          ( cvxif_req                 ),
    .cvxif_resp_i         ( cvxif_resp                ),
`ifdef PITON_ARIANE
    .l15_req_o            ( l15_req_o                 ),
    .l15_rtrn_i           ( l15_rtrn_i                ),
`endif
    .axi_req_o            ( axi_req_o                 ),
    .axi_resp_i           ( axi_resp_i                )
  );

  if (ariane_pkg::CVXIF_PRESENT) begin : gen_example_coprocessor
    cvxif_example_coprocessor i_cvxif_coprocessor (
      .clk_i                ( clk_i                          ),
      .rst_ni               ( rst_ni                         ),
      .cvxif_req_i          ( cvxif_req                      ),
      .cvxif_resp_o         ( cvxif_resp                     )
    );
  end

endmodule // ariane
