`timescale 1ns/1ps

module mbist_tb;

    reg clk;
    reg rst;
    reg start;

    wire mem_we;
    wire [3:0] mem_addr;
    wire [7:0] mem_data_in;
    wire [7:0] mem_data_out;

    wire done;
    wire error;

    // MBIST controller
    mbist_controller controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_data_in(mem_data_in),
        .mem_data_out(mem_data_out),
        .done(done),
        .error(error)
    );

    // SRAM model
    sram_model memory (
        .clk(clk),
        .we(mem_we),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("sim/mbist_wave.vcd");
        $dumpvars(0, mbist_tb);

        rst   = 1'b1;
        start = 1'b0;

        // Apply reset
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // Start MBIST
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for completion, with a timeout
        fork
            begin
                wait (done === 1'b1);
                #1;

                $display("--------------------------------");
                $display("MBIST TEST COMPLETED");
                $display("done  = %b", done);
                $display("error = %b", error);

                if (error === 1'b0)
                    $display("PASS: SRAM passed March C- test");
                else
                    $display("FAIL: SRAM mismatch detected");

                $display("--------------------------------");
            end

            begin
                #20000;
                $display("FAIL: MBIST timeout");
            end
        join_any

        disable fork;
        $finish;
    end

endmodule
