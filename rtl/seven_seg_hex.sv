`timescale 1ns / 1ps

module seven_seg_hex (
    input  wire       clk,       // 100 MHz
    input  wire       rst,       
    input  wire [7:0] hex_byte,  
    output logic      ca, cb, cc, cd, ce, cf, cg, dp, 
    output logic [7:0] an        
);

    logic [16:0] refresh_cnt;
    always_ff @(posedge clk) begin
        if (rst)
            refresh_cnt <= 17'd0;
        else
            refresh_cnt <= refresh_cnt + 17'd1;
    end

    wire digit_sel = refresh_cnt[16];
    logic [3:0] current_nibble;
    logic [6:0] seg_bus;


    always_comb begin
        an = 8'b1111_1111;
        if (digit_sel == 1'b0) begin
            an[0]          = 1'b0;
            current_nibble = hex_byte[3:0];
        end else begin
            an[1]          = 1'b0;          
            current_nibble = hex_byte[7:4];
        end
    end


    always_comb begin
        case (current_nibble)
            4'h0: seg_bus = 7'b100_0000; // 0
            4'h1: seg_bus = 7'b111_1001; // 1
            4'h2: seg_bus = 7'b010_0100; // 2
            4'h3: seg_bus = 7'b011_0000; // 3
            4'h4: seg_bus = 7'b001_1001; // 4
            4'h5: seg_bus = 7'b001_0010; // 5
            4'h6: seg_bus = 7'b000_0010; // 6
            4'h7: seg_bus = 7'b111_1000; // 7
            4'h8: seg_bus = 7'b000_0000; // 8
            4'h9: seg_bus = 7'b001_0000; // 9
            4'hA: seg_bus = 7'b000_1000; // A
            4'hB: seg_bus = 7'b000_0011; // b
            4'hC: seg_bus = 7'b100_0110; // C
            4'hD: seg_bus = 7'b010_0001; // d
            4'hE: seg_bus = 7'b000_0110; // E
            4'hF: seg_bus = 7'b000_1110; // F
            default: seg_bus = 7'b111_1111;
        endcase
    end

    assign {cg, cf, ce, cd, cc, cb, ca} = seg_bus;
    assign dp = 1'b1;

endmodule