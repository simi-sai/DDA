`timescale 1ns / 1ps

module tb_E4();

    reg clk, rst_n;
    reg [7:0] x_data;
    wire [12:0] y_data_wire;

    reg [12:0] tb_x1, tb_x2, tb_x3;
    reg [12:0] tb_y1, tb_y2;
    reg [12:0] ecuacion;

    E4 uut (
        .clk(clk),
        .rst_n(rst_n),
        .x(x_data),
        .y(y_data_wire)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            { tb_x1, tb_x2, tb_x3 } = { 13'b0, 13'b0, 13'b0 };
            { tb_y1, tb_y2 } = { 13'b0, 13'b0 };
        end 
        else begin
            { tb_x1, tb_x2, tb_x3 } = { {5'b0, x_data}, tb_x1, tb_x2 };
            { tb_y1, tb_y2 } = { y_data_wire, tb_y1 };
        end
    end

    integer i;
    initial begin
        rst_n = 0;
        x_data = 0;
        
        #20;
        rst_n = 1;
        @(posedge clk);

        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);
            x_data = {$random} % 15;

            @(posedge clk);
            #1;

            ecuacion = x_data - tb_x1 + tb_x2 + tb_x3 + (tb_y1 >> 1) + (tb_y2 >> 2);

            $display("----------------------------------------");
            $display("x[n]=%d, x[n-1]=%d, x[n-2]=%d, x[n-3]=%d | y[n-1]=%d, y[n-2]=%d", 
                      x_data, tb_x1, tb_x2, tb_x3, tb_y1, tb_y2);
            $display("Esperado (Ecuacion): %d | Obtenido (UUT): %d", ecuacion, y_data_wire);

            if (y_data_wire == ecuacion) begin
                $display("Status: TEST PASSED");
            end else begin
                $display("Status: TEST FAILED");
            end
        end

        $display("----------------------------------------");
        $display("TEST COMPLETED");
        $finish;
    end

endmodule
