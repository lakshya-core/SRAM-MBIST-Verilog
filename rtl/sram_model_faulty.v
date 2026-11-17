
`timescale 1ns/1ps

module sram_model_faulty (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out
);

    reg [7:0] mem [0:15];

    always @(posedge clk) begin
        if (we) begin
            // Inject a fault at address 5:
            // Bit 0 is forced to 0 when writing.
            if (addr == 4'd5)
                mem[addr] <= {data_in[7:1], 1'b0};
            else
                mem[addr] <= data_in;
        end
        else begin
            data_out <= mem[addr];
        end
    end

endmodule

