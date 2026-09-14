`timescale 1ns / 1ps

module E1 (
    input clk, reset_n,
    input [2:0] i_data1, i_data2,
    input [1:0] i_sel,
    output wire [5:0] o_data,
    output wire o_overflow
);
    reg [3:0] mux_exit;

    always @(*) begin
        case (i_sel)
            2'b00: mux_exit = {1'b0, i_data2};
            2'b01: mux_exit = i_data1 + i_data2;
            2'b10: mux_exit = {1'b0, i_data1};
            default: mux_exit = 4'b0000;
        endcase
    end

    reg [6:0] sum;

    always @(posedge clk, negedge reset_n) begin
        sum <= (~reset_n) ? 0 : mux_exit + sum[5:0];
    end

    assign o_overflow = sum[6];
    assign o_data = sum[5:0];

endmodule
