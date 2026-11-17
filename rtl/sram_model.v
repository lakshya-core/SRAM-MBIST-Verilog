
`timescale 1ns/1ps

module sram_model (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] data_in,
    output wire [7:0] data_out
);

    reg [7:0] mem [0:15];

    // Asynchronous read
    assign data_out = mem[addr];

    // Synchronous write
    always @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;
    end

endmodule

