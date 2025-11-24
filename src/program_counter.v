module program_counter (
    input wire clk,
    input wire rst_n,
    input wire [31:0] next_pc,
    output reg [31:0] pc
);

    always @(posedge clk) begin
        if (!rst_n) begin
            pc <= 32'd0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule