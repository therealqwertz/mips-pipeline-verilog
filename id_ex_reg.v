module id_ex_reg (
    input        clk,
    input        reset,
    input        flush,
    input [31:0] pc_in, rd1_in, rd2_in, imm_in,
    input [4:0]  rs_in, rt_in, rd_in,
    input        reg_dst_in, alu_src_in, mem_read_in,
    input        mem_write_in, reg_write_in, mem_to_reg_in,
    input [1:0]  alu_op_in,
    input [5:0]  funct_in,
    output reg [31:0] pc_out, rd1_out, rd2_out, imm_out,
    output reg [4:0]  rs_out, rt_out, rd_out,
    output reg        reg_dst_out, alu_src_out, mem_read_out,
    output reg        mem_write_out, reg_write_out, mem_to_reg_out,
    output reg [1:0]  alu_op_out,
    output reg [5:0]  funct_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out<=0; rd1_out<=0; rd2_out<=0; imm_out<=0;
            rs_out<=0; rt_out<=0; rd_out<=0;
            reg_dst_out<=0; alu_src_out<=0; mem_read_out<=0;
            mem_write_out<=0; reg_write_out<=0; mem_to_reg_out<=0;
            alu_op_out<=0; funct_out<=0;
        end else begin
            pc_out<=pc_in; rd1_out<=rd1_in; rd2_out<=rd2_in; imm_out<=imm_in;
            rs_out<=rs_in; rt_out<=rt_in; rd_out<=rd_in;
            reg_dst_out<=reg_dst_in; alu_src_out<=alu_src_in;
            mem_read_out<=mem_read_in; mem_write_out<=mem_write_in;
            reg_write_out<=reg_write_in; mem_to_reg_out<=mem_to_reg_in;
            alu_op_out<=alu_op_in; funct_out<=funct_in;
        end
    end
endmodule