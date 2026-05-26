module alu (
    input  [31:0] a, b,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result,
    output zero
);
    assign zero = (result == 0);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a & b;
            4'b0001: result = a | b;
            4'b0010: result = a + b;
            4'b0110: result = a - b;
            4'b0111: result = ($signed(a) < $signed(b)) ? 1 : 0;
            4'b1100: result = ~(a | b);
            default: result = 0;
        endcase
    end
endmodule