module branch_predictor (
    input        clk, reset,
    input [9:0]  pc_index,
    input        branch_taken,
    input        branch_valid,
    output       predict_taken
);
    reg [1:0] bht [0:1023];
    integer i;

    assign predict_taken = bht[pc_index][1];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                bht[i] <= 2'b01;
        end else if (branch_valid) begin
            case (bht[pc_index])
                2'b00: bht[pc_index] <= branch_taken ? 2'b01 : 2'b00;
                2'b01: bht[pc_index] <= branch_taken ? 2'b10 : 2'b00;
                2'b10: bht[pc_index] <= branch_taken ? 2'b11 : 2'b01;
                2'b11: bht[pc_index] <= branch_taken ? 2'b11 : 2'b10;
            endcase
        end
    end
endmodule