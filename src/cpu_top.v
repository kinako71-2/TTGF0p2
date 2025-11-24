`include "cpu_pkg.v"

module cpu_top (
    input wire clk,
    input wire rst_n,
    input wire [31:0] imem_wr_data,
    input wire imem_wr_en,
    output reg [31:0] debug_rd_value
);

    wire [31:0] pc, next_pc;
    wire [31:0] insn;
    wire [31:0] imm;
    wire [4:0] alu_code;
    wire alu_op1_sel;
    wire alu_op2_sel;
    wire reg_we;
    wire [2:0] is_load;
    wire [1:0] is_store;

    wire [31:0] rd_value;
    wire [31:0] rs1_value;
    wire [31:0] rs2_value;

    wire [31:0] alu_op1;
    wire [31:0] alu_op2;
    wire [31:0] alu_result;

    wire br_taken;
    wire [31:0] br_addr;

    wire [31:0] dmem_rd_data;


    assign next_pc = br_taken ? br_addr : pc + 32'd4;
    program_counter pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    imem imem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .addr(pc),
        .wr_data(imem_wr_data),
        .wr_en(imem_wr_en),
        .rd_data(insn)
    );

    decoder decoder_inst (
        .insn(insn),
        .imm(imm),
        .alu_code(alu_code),
        .alu_op1_sel(alu_op1_sel),
        .alu_op2_sel(alu_op2_sel),
        .reg_we(reg_we),
        .is_load(is_load),
        .is_store(is_store)
    );

    regfile regfile_inst (
        .clk(clk),
        .reg_we(reg_we),
        .rs1(insn[19:15]),
        .rs2(insn[24:20]),
        .rd(insn[11:7]),
        .rd_value(rd_value),
        .rs1_value(rs1_value),
        .rs2_value(rs2_value)
    );

    assign alu_op1 = alu_op1_sel ? pc : rs1_value;
    assign alu_op2 = alu_op2_sel ? imm : rs2_value;

    alu alu_inst (
        .alu_code(alu_code),
        .op1(alu_op1),
        .op2(alu_op2),
        .alu_result(alu_result),
        .br_taken(br_taken)
    );
    assign br_addr = (alu_code == `ALU_JALR) ? rs1_value + imm : pc + imm;

    dmem dmem_inst (
        .clk(clk),
        .addr(alu_result),
        .wr_data(rs2_value),
        .is_load(is_load),
        .is_store(is_store),
        .rd_data(dmem_rd_data)
    );
    assign rd_value = (is_load == `LOAD_DISABLE) ? alu_result : dmem_rd_data;

    assign debug_rd_value = rd_value;

endmodule