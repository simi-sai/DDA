`timescale 1ns / 1ps

module E4 (
    input clk, rst_n,
    input [7:0] x,
    output [12:0] y
);

    reg [12:0] x1, x2, x3;
    reg [12:0] y1, y2;
    
    assign y = {5'b0, x} - x1 + x2 + x3 + (y1 >> 1) + (y2 >> 2);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            { x1, x2, x3 } = { 13'b0, 13'b0, 13'b0 };
            { y1, y2 } = { 13'b0, 13'b0 };
        end
        else begin
            { x1, x2, x3 } = { {5'b0, x}, x1, x2 };
            { y1, y2 } = { y, y1 };
        end
    end

endmodule
