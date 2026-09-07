`timescale 1ns / 100ps

module tb_TOP();

    parameter N_LEDS = 4;
    parameter NB_SEL = 2;
    parameter NB_COUNT = 32;
    parameter NB_SW = 4;

    wire [N_LEDS-1:0] LED, G_LED, B_LED;
    reg [NB_SW-1:0] switch;
    reg clk, reset;

    wire [NB_COUNT-1:0] tb_counter;
    assign tb_counter = tb_TOP.uut.counter;
    
    task reset_signal;
    begin
        reset = 0;
        #10;
        reset = 1;
    end
    endtask

    initial begin : stimulus
        switch[0] = 1'b0;
        clk = 1'b0;
        reset = 1'b0;
        switch[2:1] = 2'b00;
        switch[3] = 1'b0;

        #100 reset = 1'b1;
        #100 switch[0] = 1'b1;

        //force tb_TOP.uut.LED = 4'b0001;

        #1000000 switch[2:1] = 2'b01;
        reset_signal();
        #1000000 switch[2:1] = 2'b10;
        reset_signal();
        #1000000 switch[3]   = 1'b1;
        reset_signal();
        #1000000 switch[2:1] = 2'b11;
        reset_signal();
        #1000000 switch[0] = 1'b0;
        #1000000 $finish;
    end

    initial begin
        forever #5 clk = ~clk;
    end

    TOP #(.N_LEDS(N_LEDS), .NB_SEL(NB_SEL), .NB_COUNT(NB_COUNT), .NB_SW(NB_SW)) 
    uut (
        .clk(clk),
        .ext_reset(reset),
        .switch(switch),
        .LED(LED),
        .G_LED(G_LED),
        .B_LED(B_LED)
    );

endmodule
