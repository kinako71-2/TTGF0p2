`include "cpu_pkg.v"

module alu (
    input  wire [4:0]  alu_code,
    input  wire [31:0] op1,
    input  wire [31:0] op2,
    output reg  [31:0] alu_result,
    output reg         br_taken
);

    wire signed [31:0] signed_op1 = $signed(op1);
    wire signed [31:0] signed_op2 = $signed(op2);

    always @(*) begin
        case (alu_code)
            `ALU_ADD:   alu_result = signed_op1 + signed_op2;
            `ALU_SUB:   alu_result = signed_op1 - signed_op2;
            `ALU_XOR:   alu_result = op1 ^ op2;
            `ALU_OR:    alu_result = op1 | op2;
            `ALU_AND:   alu_result = op1 & op2;
            `ALU_SLT:   alu_result = (signed_op1 < signed_op2) ? 32'd1 : 32'd0;
            `ALU_SLTU:  alu_result = (op1 < op2) ? 32'd1 : 32'd0;
            `ALU_SLL:   alu_result = op1 << op2[4:0];          // 左シフトは符号不要
            `ALU_SRL:   alu_result = op1 >> op2[4:0];          // 論理右シフト
            `ALU_SRA:   alu_result = signed_op1 >>> op2[4:0];  // 算術右シフトは signed_op1
            `ALU_LUI:   alu_result = op2;
            `ALU_JAL:   alu_result = op1 + 32'd4;
            `ALU_JALR:  alu_result = op1 + 32'd4;
            default:    alu_result = 32'd0;
        endcase
    end

    always @(*) begin
        case (alu_code)
            `ALU_BEQ:   br_taken = (signed_op1 == signed_op2) ? `ENABLE : `DISABLE;
            `ALU_BNE:   br_taken = (signed_op1 != signed_op2) ? `ENABLE : `DISABLE;
            `ALU_BLT:   br_taken = (signed_op1 < signed_op2)  ? `ENABLE : `DISABLE;
            `ALU_BGE:   br_taken = (signed_op1 >= signed_op2) ? `ENABLE : `DISABLE;
            `ALU_BLTU:  br_taken = (op1 < op2) ? `ENABLE : `DISABLE;
            `ALU_BGEU:  br_taken = (op1 >= op2) ? `ENABLE : `DISABLE;
            `ALU_JAL:   br_taken = `ENABLE;
            `ALU_JALR:  br_taken = `ENABLE;
            default:    br_taken = `DISABLE;
        endcase
    end

endmodule