`ifndef CPU_PKG_V
`define CPU_PKG_V

// -----------------------------
// ALU code
// -----------------------------
`define ALU_ADD   5'd0
`define ALU_SUB   5'd1
`define ALU_XOR   5'd2
`define ALU_OR    5'd3
`define ALU_AND   5'd4
`define ALU_SLT   5'd5
`define ALU_SLTU  5'd6
`define ALU_SLL   5'd7
`define ALU_SRL   5'd8
`define ALU_SRA   5'd9
`define ALU_LUI   5'd10
`define ALU_BEQ   5'd11
`define ALU_BNE   5'd12
`define ALU_BLT   5'd13
`define ALU_BGE   5'd14
`define ALU_BLTU  5'd15
`define ALU_BGEU  5'd16
`define ALU_JAL   5'd17
`define ALU_JALR  5'd18

// -----------------------------
// control signals
// -----------------------------
`define DISABLE 1'b0
`define ENABLE  1'b1

// -----------------------------
// op_code
// -----------------------------
`define OPIMM   7'b0010011
`define OPREG   7'b0110011
`define LUI     7'b0110111
`define AUIPC   7'b0010111
`define LOAD    7'b0000011
`define STORE   7'b0100011
`define BRANCH  7'b1100011
`define JAL     7'b1101111
`define JALR    7'b1100111

// -----------------------------
// ALU operand select
// -----------------------------
`define ALU_OP1_RS1 1'b0
`define ALU_OP1_PC  1'b1
`define ALU_OP2_RS2 1'b0
`define ALU_OP2_IMM 1'b1

// -----------------------------
// load type
// -----------------------------
`define LOAD_DISABLE 3'b000
`define LOAD_LB      3'b001
`define LOAD_LH      3'b010
`define LOAD_LW      3'b011
`define LOAD_LBU     3'b101
`define LOAD_LHU     3'b110

// -----------------------------
// store type
// -----------------------------
`define STORE_DISABLE 2'b00
`define STORE_SB      2'b01
`define STORE_SH      2'b10
`define STORE_SW      2'b11

`endif
