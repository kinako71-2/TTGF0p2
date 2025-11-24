`include "cpu_pkg.v"

module decoder (
    input  wire [31:0] insn,
    output reg  [31:0] imm,
    output reg  [4:0]  alu_code,
    output reg         alu_op1_sel,
    output reg         alu_op2_sel,
    output reg         reg_we,
    output reg  [2:0]  is_load,
    output reg  [1:0]  is_store
);

    wire [6:0] op_code = insn[6:0];
    wire [2:0] funct3  = insn[14:12];

    // imm
    always @(*) begin
        case (op_code)
            `OPIMM:  imm = {{20{insn[31]}}, insn[31:20]};
            `LUI:    imm = {insn[31:12], 12'd0};
            `AUIPC:  imm = {insn[31:12], 12'd0};
            `LOAD:   imm = {{20{insn[31]}}, insn[31:20]};
            `STORE:  imm = {{20{insn[31]}}, insn[31:25], insn[11:7]};
            `BRANCH: imm = {{19{insn[31]}}, insn[31], insn[7], insn[30:25], insn[11:8], 1'b0};
            `JAL:    imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};
            `JALR:   imm = {{20{insn[31]}}, insn[31:20]};
            default: imm = 32'd0;
        endcase
    end

    // alu_code
    always @(*) begin
        case (op_code)
            `OPREG: begin
                case (funct3)
                    3'b000: alu_code = (insn[30] ? `ALU_SUB : `ALU_ADD);
                    3'b100: alu_code = `ALU_XOR;
                    3'b110: alu_code = `ALU_OR;
                    3'b111: alu_code = `ALU_AND;
                    3'b010: alu_code = `ALU_SLT;
                    3'b011: alu_code = `ALU_SLTU;
                    3'b001: alu_code = `ALU_SLL;
                    3'b101: alu_code = (insn[30] ? `ALU_SRA : `ALU_SRL);
                    default: alu_code = `ALU_ADD;
                endcase
            end

            `OPIMM: begin
                case (funct3)
                    3'b000: alu_code = `ALU_ADD;
                    3'b100: alu_code = `ALU_XOR;
                    3'b110: alu_code = `ALU_OR;
                    3'b111: alu_code = `ALU_AND;
                    3'b010: alu_code = `ALU_SLT;
                    3'b011: alu_code = `ALU_SLTU;
                    3'b001: alu_code = `ALU_SLL;
                    3'b101: alu_code = (insn[30] ? `ALU_SRA : `ALU_SRL);
                    default: alu_code = `ALU_ADD;
                endcase
            end

            `LUI:    alu_code = `ALU_LUI;
            `AUIPC:  alu_code = `ALU_ADD;

            `BRANCH: begin
                case (funct3)
                    3'b000: alu_code = `ALU_BEQ;
                    3'b001: alu_code = `ALU_BNE;
                    3'b100: alu_code = `ALU_BLT;
                    3'b101: alu_code = `ALU_BGE;
                    3'b110: alu_code = `ALU_BLTU;
                    3'b111: alu_code = `ALU_BGEU;
                    default: alu_code = `ALU_ADD;
                endcase
            end

            `JAL:    alu_code = `ALU_JAL;
            `JALR:   alu_code = `ALU_JALR;
            default: alu_code = `ALU_ADD;
        endcase
    end

    // ALU operand select
    always @(*) begin
        case (op_code)
            `OPIMM, `LOAD, `STORE, `JALR: begin
                alu_op1_sel = `ALU_OP1_RS1;
                alu_op2_sel = `ALU_OP2_IMM;
            end
            `OPREG, `BRANCH: begin
                alu_op1_sel = `ALU_OP1_RS1;
                alu_op2_sel = `ALU_OP2_RS2;
            end
            `AUIPC, `JAL, `LUI: begin
                alu_op1_sel = `ALU_OP1_PC;
                alu_op2_sel = `ALU_OP2_IMM;
            end
            default: begin
                alu_op1_sel = `ALU_OP1_RS1;
                alu_op2_sel = `ALU_OP2_RS2;
            end
        endcase
    end

    // reg_we
    always @(*) begin
        case (op_code)
            `OPIMM, `OPREG, `LUI, `AUIPC, `LOAD, `JAL, `JALR:
                reg_we = `ENABLE;
            default:
                reg_we = `DISABLE;
        endcase
    end

    // is_load
    always @(*) begin
        case (op_code)
            `LOAD: begin
                case (funct3)
                    3'b000: is_load = `LOAD_LB;
                    3'b001: is_load = `LOAD_LH;
                    3'b010: is_load = `LOAD_LW;
                    3'b100: is_load = `LOAD_LBU;
                    3'b101: is_load = `LOAD_LHU;
                    default: is_load = `LOAD_DISABLE;
                endcase
            end
            default: is_load = `LOAD_DISABLE;
        endcase
    end

    // is_store
    always @(*) begin
        case (op_code)
            `STORE: begin
                case (funct3)
                    3'b000: is_store = `STORE_SB;
                    3'b001: is_store = `STORE_SH;
                    3'b010: is_store = `STORE_SW;
                    default: is_store = `STORE_DISABLE;
                endcase
            end
            default: is_store = `STORE_DISABLE;
        endcase
    end

endmodule
