
`timescale 1ns/1ps

module mbist_fault_tb;

    reg clk;
    reg rst;
    reg start;

    wire mem_we;
    wire [3:0] mem_addr;
    wire [7:0] mem_data_in;
    wire [7:0] mem_data_out;
    wire done;
    wire error;

    // Existing MBIST controller
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

    // Faulty SRAM model
    sram_model_faulty memory (
        .clk(clk),
        .we(mem_we),
        .addr(mem_addr),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/mbist_fault_wave.vcd");
        $dumpvars(0, mbist_fault_tb);

        rst   = 1'b1;
        start = 1'b0;

        // Reset the controller
        repeat (2) @(negedge clk);
        rst = 1'b0;

        // Start the MBIST operation
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for completion or timeout
        fork
            begin
                wait (done === 1'b1);
                #1;

                $display("----------------------------------");
                $display("FAULT-INJECTION TEST COMPLETED");
                $display("done  = %b", done);
                $display("error = %b", error);

                if (error === 1'b1)
                    $display("PASS: Injected SRAM fault detected");
                else
                    $display("FAIL: Injected SRAM fault NOT detected");

                $display("----------------------------------");
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

