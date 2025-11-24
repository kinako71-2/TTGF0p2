module imem (
    input wire clk,
    input wire rst_n,
    input wire [31:0] addr,
    input wire [31:0] wr_data,
    input wire wr_en,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:7];

    // store
    always @(posedge clk) begin
        if (wr_en) mem[addr[31:2]] <= wr_data;
    end

    // load
    assign rd_data = wr_en ? 32'd0 : mem[addr[31:2]];

endmodule