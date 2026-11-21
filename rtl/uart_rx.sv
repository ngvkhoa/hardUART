`timescale 1ns / 1ps

module uart_rx #(
    parameter int CLKS_PER_BIT = 10417
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t      state;
    logic [15:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  rx_byte;

    logic rx_sync1, rx_sync2;
    always_ff @(posedge clk) begin
        if (rst) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            clk_count <= 16'd0;
            bit_index <= 3'd0;
            rx_data   <= 8'h00;
            rx_byte   <= 8'h00;
            rx_done   <= 1'b0;
        end else begin
            rx_done <= 1'b0;

            case (state)
                IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (rx_sync2 == 1'b0)
                        state <= START;
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT / 2) - 1) begin
                        if (rx_sync2 == 1'b0) begin
                            clk_count <= 16'd0;
                            state     <= DATA;
                        end else begin
                            state     <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 16'd1;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 16'd1;
                    end else begin
                        clk_count          <= 16'd0;
                        rx_byte[bit_index] <= rx_sync2;
                        if (bit_index < 3'd7) begin
                            bit_index <= bit_index + 3'd1;
                        end else begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 16'd1;
                    end else begin
                        clk_count <= 16'd0;
                        if (rx_sync2 == 1'b1) begin
                            rx_data <= rx_byte;
                            rx_done <= 1'b1;
                            state   <= IDLE;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule