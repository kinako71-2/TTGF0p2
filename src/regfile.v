module regfile (
    input wire clk,
    input wire reg_we,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] rd_value,
    output reg [31:0] rs1_value,
    output reg [31:0] rs2_value
);
    reg [31:0] regfile [1:31];

    always @(posedge clk) begin
        if(reg_we) begin
            regfile[rd] <= rd_value;
        end
    end

    assign rs1_value = (rs1 == 5'd0) ? 32'd0 : regfile[rs1];
    assign rs2_value = (rs2 == 5'd0) ? 32'd0 : regfile[rs2];

endmodule