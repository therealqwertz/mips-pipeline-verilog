module instruction_memory (
    input  [31:0] pc,
    output [31:0] instruction
);
    reg [31:0] mem [0:255];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign instruction = mem[pc[9:2]];
endmodule