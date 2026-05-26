module ex_mem_reg (
    input        clk,
    input        reset,
    input [31:0] pc_in, alu_in, rd2_in,
    input [4:0]  rd_in,
    input        zero_in, mem_read_in, mem_write_in,
    input        reg_write_in, mem_to_reg_in, branch_in,
    output reg [31:0] pc_out, alu_out, rd2_out,
    output reg [4:0]  rd_out,
    output reg        zero_out, mem_read_out, mem_write_out,
    output reg        reg_write_out, mem_to_reg_out, branch_out
);
    always @(posedge clk) begin
        if (reset) begin
            pc_out<=0; alu_out<=0; rd2_out<=0; rd_out<=0;
            zero_out<=0; mem_read_out<=0; mem_write_out<=0;
            reg_write_out<=0; mem_to_reg_out<=0; branch_out<=0;
        end else begin
            pc_out<=pc_in; alu_out<=alu_in; rd2_out<=rd2_in; rd_out<=rd_in;
            zero_out<=zero_in; mem_read_out<=mem_read_in;
            mem_write_out<=mem_write_in; reg_write_out<=reg_write_in;
            mem_to_reg_out<=mem_to_reg_in; branch_out<=branch_in;
        end
    end
endmodule