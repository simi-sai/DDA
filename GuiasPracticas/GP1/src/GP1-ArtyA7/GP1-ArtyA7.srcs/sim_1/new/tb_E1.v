`timescale 1ns / 1ps

module tb_E1;

    reg clk, reset_n;
    reg [2:0] i_data1, i_data2;
    reg [1:0] i_sel;

    wire [5:0] o_data;
    wire o_overflow;

    // Modelo de referencia
    reg [6:0] exp_o_data;
    reg exp_o_overflow;

    E1 uut (
        .clk(clk), .reset_n(reset_n),
        .i_data1(i_data1), .i_data2(i_data2),
        .i_sel(i_sel),
        .o_data(o_data), .o_overflow(o_overflow)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    integer errors;
    integer cycle_count;

    task reset_dut;
    begin
        reset_n = 1'b0;
        i_sel = 2'b00;
        i_data1 = 3'b000;
        i_data2 = 3'b000;
        #20;
        reset_n = 1'b1;
        #10;
    end
    endtask

    task apply;
        input [1:0] sel;
        input [2:0] d1, d2;
    begin
        i_sel = sel;
        i_data1 = d1;
        i_data2 = d2;
        @(posedge clk);
        #1; // espera a que el acumulador actualice sum (NBA)
    end
    endtask
    
    task check;
    begin
        if (o_data !== exp_o_data || o_overflow !== exp_o_overflow) begin
            $error("t=%0t | Error: i_sel=%b i_data1=%b i_data2=%b | o_data=%b (exp=%b) o_overflow=%b (exp=%b)",
                   $time, i_sel, i_data1, i_data2, o_data, exp_o_data, o_overflow, exp_o_overflow);
            errors = errors + 1;
        end
        else begin
            $display("t=%0t | OK: i_sel=%b i_data1=%b i_data2=%b | o_data=%b o_overflow=%b",
                     $time, i_sel, i_data1, i_data2, o_data, o_overflow);
        end
    end
    endtask
    
    reg [2:0] aux1, aux2;

    initial begin
        errors = 0;
        
        $display("[FASE 0] Reset asincrono");
        reset_dut();
        if (o_data !== 6'd0 || o_overflow !== 1'b0) begin
            $error("t=%0t | Reset no inicializo: o_data=%b o_overflow=%b",
                   $time, o_data, o_overflow);
            errors = errors + 1;
        end 
        else begin
            $display("[FASE 0] OK: o_data=0, o_overflow=0 tras reset");
        end

        $display("[FASE 1] Barrido sistematico de i_sel");
        // sel=00: acumula i_data2 (extendido a 4 bits)
        aux1 = $random; aux2 = $random;
        apply(2'b00, aux1, aux2);
        apply(2'b00, aux1, aux2);
        exp_o_data = {1'b0, aux2} + {1'b0, aux2};
        exp_o_overflow = exp_o_data[6];
        check();
        
        // sel=01: acumula suma i_data1 + i_data2
        reset_dut();
        aux1 = $random; aux2 = $random;
        apply(2'b01, aux1, aux2);
        apply(2'b01, aux1, aux2);
        exp_o_data = (aux1 + aux2) + (aux1 + aux2);
        exp_o_overflow = exp_o_data[6];
        check();

        // sel=10: acumula i_data1 (extendido a 4 bits)
        reset_dut();
        aux1 = $random; aux2 = $random;
        apply(2'b10, aux1, aux2);
        apply(2'b10, aux1, aux2);
        exp_o_data = {1'b0, aux1} + {1'b0, aux1};
        exp_o_overflow = exp_o_data[6];
        check();

        // sel=11: acumula 0 (default)
        reset_dut();
        aux1 = $random; aux2 = $random;
        apply(2'b11, aux1, aux2);
        apply(2'b11, aux1, aux2);
        exp_o_data = 6'b0;
        exp_o_overflow = exp_o_data[6];
        check();

        if (errors > 0) begin
            $error("[FASE 1] Fallaron %0d estimulos", errors);
        end
        else
            $display("[FASE 1] OK: 8 estimulos aplicados y verificados");

        $display("[FASE 2] Test de overflow (sel=01, d1=1, d2=1)");
        reset_dut();
        i_sel   = 2'b01;
        i_data1 = 3'b001;
        i_data2 = 3'b001;
        cycle_count = 0;
        
        while (o_overflow !== 1'b1 && cycle_count < 100) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;
        end
        $display("[FASE 2] Overflow detectado en %0d ciclos", cycle_count);

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED (%0d errores)", errors);
        $finish;
    end

endmodule