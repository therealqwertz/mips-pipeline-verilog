`timescale 1ns/1ps
module tb_mips_pipeline;
    reg clk, reset;

    mips_pipeline uut (.clk(clk), .reset(reset));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;
        #500;
        $stop;
    end
endmodule