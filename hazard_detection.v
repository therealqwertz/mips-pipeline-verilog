module hazard_detection (
    input        id_ex_mem_read,
    input [4:0]  id_ex_rt,
    input [4:0]  if_id_rs, if_id_rt,
    input        branch_mispredicted,
    output reg   pc_write, if_id_write, stall, flush_id_ex
);
    always @(*) begin
        if (id_ex_mem_read &&
           ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))) begin
            // Load-use hazard: stall 1 cycle
            pc_write     = 0;
            if_id_write  = 0;
            stall        = 1;
            flush_id_ex  = 1;
        end else if (branch_mispredicted) begin
            // Flush on misprediction
            pc_write     = 1;
            if_id_write  = 1;
            stall        = 0;
            flush_id_ex  = 1;
        end else begin
            pc_write     = 1;
            if_id_write  = 1;
            stall        = 0;
            flush_id_ex  = 0;
        end
    end
endmodule