module register_file (
    input        clk,
    input        we,
    input  [4:0] rs, rt, rd,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] regs [0:31];

    assign read_data1 = (rs == 0) ? 32'b0 : regs[rs];
    assign read_data2 = (rt == 0) ? 32'b0 : regs[rt];

    always @(posedge clk) begin
        if (we && rd != 0)
            regs[rd] <= write_data;
    end

endmodule