/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_simple_riscv (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg [31:0] imem_wr_data;
  reg [1:0] mem_idx;

  wire cpu_clk = (mem_idx[1] == 0) ? 1 : 0;
  wire [31:0] debug_rd_value;
  
  reg [7:0] out_reg;
  assign uo_out = out_reg;

  // --- Always block for memory write / output ---
  always @(posedge clk) begin
      if (!rst_n) begin
          imem_wr_data <= 0;
          mem_idx <= 0;
          out_reg <= 0;
      end else begin
          imem_wr_data[mem_idx*8 +: 8] <= ui_in;
          mem_idx <= mem_idx + 1;
          out_reg <= debug_rd_value[mem_idx*8 +: 8];
      end
  end

  wire cpu_rst_n = uio_in[0];
  wire imem_wr_en = uio_in[1];

  cpu_top cpu_top_inst (
      .clk(cpu_clk),
      .rst_n(cpu_rst_n),
      .imem_wr_data(imem_wr_data),
      .imem_wr_en(imem_wr_en),
      .debug_rd_value(debug_rd_value)
  );

  assign uio_oe  = 0;
  assign uio_out = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:2]};

endmodule
