`timescale 1ns / 1ps

module tb_E2;

    reg [15:0] i_dataA, i_dataB;
    wire [15:0] o_dataC;
    reg [1:0] i_sel;

    E2 uut (
        .i_dataA(i_dataA), .i_dataB(i_dataB),
        .i_sel(i_sel),
        .o_dataC(o_dataC)
    );

    task apply;
        input [1:0] sel;
        input [15:0] dataA, dataB;
    begin
        i_sel = sel;
        i_dataA = dataA;
        i_dataB = dataB;
    end
    endtask
    
    task check;
        input [15:0] expected;
    begin
        if (o_dataC !== expected) begin
            $error("Error: i_sel=%b i_dataA=%b i_dataB=%b | o_dataC=%b (exp=%b)",
                   i_sel, i_dataA, i_dataB, o_dataC, expected);
        end 
        else begin
            $display("OK: i_sel=%b i_dataA=%b i_dataB=%b | o_dataC=%b",
                     i_sel, i_dataA, i_dataB, o_dataC);
        end
    end
    endtask

    reg [15:0] A, B, ex;

    initial begin
        A = $random;
        B = $random;
        ex = A + B;
        
        // Aplicar casos de prueba
        apply(2'b00, A, B); // Suma
        #10;
        check(ex);

        A = $random;
        B = $random;
        ex = A - B;
        
        apply(2'b01, A, B); // Resta
        #10;
        check(ex);

        A = $random;
        B = $random;
        ex = A & B;
        
        apply(2'b10, A, B); // AND
        #10;
        check(ex);

        A = $random;
        B = $random;
        ex = A | B;
        
        apply(2'b11, A, B); // OR
        #10;
        check(ex);
        
        $display("TEST COMPLETED");
    end

endmodule
