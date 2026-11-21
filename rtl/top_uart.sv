`timescale 1ns / 1ps

module top_uart (
    input  wire       clk,
    input  wire       rst,
    input  wire       uart_rx,
    output wire       uart_tx,
    output wire [7:0] led,
    output wire       ca, cb, cc, cd, ce, cf, cg, dp,
    output wire [7:0] an
);

    localparam int CLKS_PER_BIT = 10417;

    logic [7:0] data_bus;
    logic       rx_done_pulse;
    logic       tx_busy;

    logic [7:0] byte_reg;
    logic [7:0] tx_buf;
    logic       tx_pending;
    logic       tx_start_reg;

    always_ff @(posedge clk) begin
        if (rst)
            byte_reg <= 8'h00;
        else if (rx_done_pulse)
            byte_reg <= data_bus;
    end

    assign led = byte_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            tx_buf       <= 8'h00;
            tx_pending   <= 1'b0;
            tx_start_reg <= 1'b0;
        end else begin
            tx_start_reg <= 1'b0;

            if (rx_done_pulse) begin
                tx_buf     <= data_bus;
                tx_pending <= 1'b1;
            end

            if (tx_pending && !tx_busy && !tx_start_reg) begin
                tx_start_reg <= 1'b1;
                tx_pending   <= 1'b0;
            end
        end
    end

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_rx (
        .clk     (clk),
        .rst     (rst),
        .rx      (uart_rx),
        .rx_data (data_bus),
        .rx_done (rx_done_pulse)
    );

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_tx (
        .clk       (clk),
        .rst       (rst),
        .tx_start  (tx_start_reg),
        .tx_data   (tx_buf),
        .tx        (uart_tx),
        .tx_active (tx_busy),
        .tx_done   ()
    );

    seven_seg_hex u_7seg (
        .clk      (clk),
        .rst      (rst),
        .hex_byte (byte_reg),
        .ca(ca), .cb(cb), .cc(cc), .cd(cd),
        .ce(ce), .cf(cf), .cg(cg), .dp(dp),
        .an       (an)
    );

endmodule