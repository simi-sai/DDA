`timescale 1ns / 1ps

module E2 (
    input [15:0] i_dataA, i_dataB,
    input [1:0] i_sel,
    output reg [15:0] o_dataC
);

    always @(*) begin
        case (i_sel)
            2'b00: o_dataC = i_dataA + i_dataB;
            2'b01: o_dataC = i_dataA - i_dataB;
            2'b10: o_dataC = i_dataA & i_dataB;
            2'b11: o_dataC = i_dataA | i_dataB;
            default: o_dataC = 16'b0;
        endcase
    end

endmodule
