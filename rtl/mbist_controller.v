
`timescale 1ns/1ps

module mbist_controller (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,

    output reg        mem_we,
    output reg  [3:0] mem_addr,
    output reg  [7:0] mem_data_in,
    input  wire [7:0] mem_data_out,

    output reg        done,
    output reg        error
);

    // FSM state definitions
    localparam IDLE     = 5'd0,
               M0_WRITE = 5'd1,
               M1_READ  = 5'd2,
               M1_CHECK = 5'd3,
               M1_WRITE = 5'd4,
               M2_READ  = 5'd5,
               M2_CHECK = 5'd6,
               M2_WRITE = 5'd7,
               M3_READ  = 5'd8,
               M3_CHECK = 5'd9,
               M3_WRITE = 5'd10,
               M4_READ  = 5'd11,
               M4_CHECK = 5'd12,
               M4_WRITE = 5'd13,
               M5_READ  = 5'd14,
               M5_CHECK = 5'd15,
               FINISH   = 5'd16;

    reg [4:0] state;

    // SRAM write enable and write data
    always @(*) begin
        mem_we      = 1'b0;
        mem_data_in = 8'h00;

        case (state)
            M0_WRITE: begin
                mem_we      = 1'b1;
                mem_data_in = 8'h00;
            end

            M1_WRITE, M3_WRITE: begin
                mem_we      = 1'b1;
                mem_data_in = 8'hFF;
            end

            M2_WRITE, M4_WRITE: begin
                mem_we      = 1'b1;
                mem_data_in = 8'h00;
            end

            default: begin
                mem_we      = 1'b0;
                mem_data_in = 8'h00;
            end
        endcase
    end

    // Main FSM: March C- algorithm
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            mem_addr <= 4'd0;
            done     <= 1'b0;
            error    <= 1'b0;
        end
        else begin
            case (state)

                IDLE: begin
                    done <= 1'b0;

                    if (start) begin
                        mem_addr <= 4'd0;
                        error    <= 1'b0;
                        state    <= M0_WRITE;
                    end
                end

                // M0: ↑(w0)
                M0_WRITE: begin
                    if (mem_addr == 4'd15) begin
                        mem_addr <= 4'd0;
                        state    <= M1_READ;
                    end
                    else begin
                        mem_addr <= mem_addr + 1'b1;
                    end
                end

                // M1: ↑(r0, w1)
                M1_READ: state <= M1_CHECK;

                M1_CHECK: begin
                    if (mem_data_out !== 8'h00)
                        error <= 1'b1;

                    state <= M1_WRITE;
                end

                M1_WRITE: begin
                    if (mem_addr == 4'd15) begin
                        mem_addr <= 4'd0;
                        state    <= M2_READ;
                    end
                    else begin
                        mem_addr <= mem_addr + 1'b1;
                        state    <= M1_READ;
                    end
                end

                // M2: ↑(r1, w0)
                M2_READ: state <= M2_CHECK;

                M2_CHECK: begin
                    if (mem_data_out !== 8'hFF)
                        error <= 1'b1;

                    state <= M2_WRITE;
                end

                M2_WRITE: begin
                    if (mem_addr == 4'd15) begin
                        mem_addr <= 4'd15;
                        state    <= M3_READ;
                    end
                    else begin
                        mem_addr <= mem_addr + 1'b1;
                        state    <= M2_READ;
                    end
                end

                // M3: ↓(r0, w1)
                M3_READ: state <= M3_CHECK;

                M3_CHECK: begin
                    if (mem_data_out !== 8'h00)
                        error <= 1'b1;

                    state <= M3_WRITE;
                end

                M3_WRITE: begin
                    if (mem_addr == 4'd0) begin
                        // FIX: M4 must start at address 15
                        mem_addr <= 4'd15;
                        state    <= M4_READ;
                    end
                    else begin
                        mem_addr <= mem_addr - 1'b1;
                        state    <= M3_READ;
                    end
                end

                // M4: ↓(r1, w0)
                M4_READ: state <= M4_CHECK;

                M4_CHECK: begin
                    if (mem_data_out !== 8'hFF)
                        error <= 1'b1;

                    state <= M4_WRITE;
                end

                M4_WRITE: begin
                    if (mem_addr == 4'd0) begin
                        mem_addr <= 4'd0;
                        state    <= M5_READ;
                    end
                    else begin
                        mem_addr <= mem_addr - 1'b1;
                        state    <= M4_READ;
                    end
                end

                // M5: ↑(r0)
                M5_READ: state <= M5_CHECK;

                M5_CHECK: begin
                    if (mem_data_out !== 8'h00)
                        error <= 1'b1;

                    if (mem_addr == 4'd15) begin
                        state <= FINISH;
                    end
                    else begin
                        mem_addr <= mem_addr + 1'b1;
                        state    <= M5_READ;
                    end
                end

                // Test completed
                FINISH: begin
                    done <= 1'b1;

                    if (!start)
                        state <= IDLE;
                end

                default: begin
                    state    <= IDLE;
                    mem_addr <= 4'd0;
                    done     <= 1'b0;
                end

            endcase
        end
    end

endmodule

