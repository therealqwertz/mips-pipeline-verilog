module mips_pipeline (
    input clk, reset
);
    // ── PC ──────────────────────────────────────────────
    reg [31:0] pc;
    wire [31:0] pc_plus4 = pc + 4;

    // ── IF ──────────────────────────────────────────────
    wire [31:0] instr_if;
    instruction_memory imem (.pc(pc), .instruction(instr_if));

    // ── IF/ID ───────────────────────────────────────────
    wire [31:0] pc_id, instr_id;
    wire        if_id_en, if_id_flush;
    if_id_reg if_id (
        .clk(clk), .reset(reset), .flush(if_id_flush), .en(if_id_en),
        .pc_in(pc_plus4), .instr_in(instr_if),
        .pc_out(pc_id),   .instr_out(instr_id)
    );

    // ── ID ──────────────────────────────────────────────
    wire [4:0]  rs_id  = instr_id[25:21];
    wire [4:0]  rt_id  = instr_id[20:16];
    wire [4:0]  rd_id  = instr_id[15:11];
    wire [5:0]  op_id  = instr_id[31:26];
    wire [5:0]  fn_id  = instr_id[5:0];
    wire [31:0] imm_id = {{16{instr_id[15]}}, instr_id[15:0]};

    wire [31:0] rd1_id, rd2_id;
    wire        wb_reg_write;
    wire [4:0]  wb_rd;
    wire [31:0] wb_data;

    register_file rf (
        .clk(clk), .we(wb_reg_write),
        .rs(rs_id), .rt(rt_id), .rd(wb_rd),
        .write_data(wb_data),
        .read_data1(rd1_id), .read_data2(rd2_id)
    );

    wire reg_dst_id, jump_id, branch_id, mem_read_id;
    wire mem_to_reg_id, mem_write_id, alu_src_id, reg_write_id;
    wire [1:0] alu_op_id;
    control_unit cu (
        .opcode(op_id),
        .reg_dst(reg_dst_id), .jump(jump_id), .branch(branch_id),
        .mem_read(mem_read_id), .mem_to_reg(mem_to_reg_id),
        .mem_write(mem_write_id), .alu_src(alu_src_id),
        .reg_write(reg_write_id), .alu_op(alu_op_id)
    );

    // ── ID/EX ───────────────────────────────────────────
    wire [31:0] pc_ex, rd1_ex, rd2_ex, imm_ex;
    wire [4:0]  rs_ex, rt_ex, rd_ex;
    wire        reg_dst_ex, alu_src_ex, mem_read_ex;
    wire        mem_write_ex, reg_write_ex, mem_to_reg_ex;
    wire [1:0]  alu_op_ex;
    wire [5:0]  funct_ex;
    wire        id_ex_flush;

    id_ex_reg id_ex (
        .clk(clk), .reset(reset), .flush(id_ex_flush),
        .pc_in(pc_id), .rd1_in(rd1_id), .rd2_in(rd2_id), .imm_in(imm_id),
        .rs_in(rs_id), .rt_in(rt_id), .rd_in(rd_id),
        .reg_dst_in(reg_dst_id), .alu_src_in(alu_src_id),
        .mem_read_in(mem_read_id), .mem_write_in(mem_write_id),
        .reg_write_in(reg_write_id), .mem_to_reg_in(mem_to_reg_id),
        .alu_op_in(alu_op_id), .funct_in(fn_id),
        .pc_out(pc_ex), .rd1_out(rd1_ex), .rd2_out(rd2_ex), .imm_out(imm_ex),
        .rs_out(rs_ex), .rt_out(rt_ex), .rd_out(rd_ex),
        .reg_dst_out(reg_dst_ex), .alu_src_out(alu_src_ex),
        .mem_read_out(mem_read_ex), .mem_write_out(mem_write_ex),
        .reg_write_out(reg_write_ex), .mem_to_reg_out(mem_to_reg_ex),
        .alu_op_out(alu_op_ex), .funct_out(funct_ex)
    );

    // ── EX ──────────────────────────────────────────────
    wire [1:0] fwd_a, fwd_b;
    wire [4:0] ex_mem_rd_w;
    wire       ex_mem_reg_write_w;

    forwarding_unit fwd (
        .id_ex_rs(rs_ex), .id_ex_rt(rt_ex),
        .ex_mem_rd(ex_mem_rd_w), .mem_wb_rd(wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write_w), .mem_wb_reg_write(wb_reg_write),
        .forward_a(fwd_a), .forward_b(fwd_b)
    );

    wire [31:0] ex_mem_alu_w;
    wire [31:0] alu_in_a = (fwd_a==2'b10) ? ex_mem_alu_w :
                           (fwd_a==2'b01) ? wb_data : rd1_ex;
    wire [31:0] fwd_b_val = (fwd_b==2'b10) ? ex_mem_alu_w :
                            (fwd_b==2'b01) ? wb_data : rd2_ex;
    wire [31:0] alu_in_b  = alu_src_ex ? imm_ex : fwd_b_val;

    wire [3:0]  alu_ctrl;
    alu_control ac (
        .alu_op(alu_op_ex), .funct(funct_ex), .alu_ctrl(alu_ctrl)
    );

    wire [31:0] alu_result_ex;
    wire        alu_zero_ex;
    alu alu0 (
        .a(alu_in_a), .b(alu_in_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result_ex), .zero(alu_zero_ex)
    );

    wire [4:0] rd_ex_final = reg_dst_ex ? rd_ex : rt_ex;
    wire [31:0] branch_target_ex = pc_ex + (imm_ex << 2);
    wire        branch_taken_ex  = alu_zero_ex; // beq

    // ── EX/MEM ──────────────────────────────────────────
    wire [31:0] pc_mem, alu_mem, rd2_mem;
    wire [4:0]  rd_mem;
    wire        zero_mem, mem_read_mem, mem_write_mem;
    wire        reg_write_mem, mem_to_reg_mem, branch_mem;

    ex_mem_reg ex_mem (
        .clk(clk), .reset(reset),
        .pc_in(branch_target_ex), .alu_in(alu_result_ex),
        .rd2_in(fwd_b_val), .rd_in(rd_ex_final),
        .zero_in(alu_zero_ex), .mem_read_in(mem_read_ex),
        .mem_write_in(mem_write_ex), .reg_write_in(reg_write_ex),
        .mem_to_reg_in(mem_to_reg_ex), .branch_in(branch_id),
        .pc_out(pc_mem), .alu_out(alu_mem), .rd2_out(rd2_mem),
        .rd_out(rd_mem), .zero_out(zero_mem),
        .mem_read_out(mem_read_mem), .mem_write_out(mem_write_mem),
        .reg_write_out(reg_write_mem), .mem_to_reg_out(mem_to_reg_mem),
        .branch_out(branch_mem)
    );

    assign ex_mem_rd_w         = rd_mem;
    assign ex_mem_reg_write_w  = reg_write_mem;
    assign ex_mem_alu_w        = alu_mem;

    // ── MEM ─────────────────────────────────────────────
    wire        actual_branch_taken = branch_mem && zero_mem;
    wire [31:0] mem_read_data;

    data_memory dmem (
        .clk(clk), .we(mem_write_mem), .re(mem_read_mem),
        .addr(alu_mem), .write_data(rd2_mem),
        .read_data(mem_read_data)
    );

    // ── Branch Predictor ────────────────────────────────
    wire        predict_taken;
    wire        branch_mispredicted = branch_mem && (actual_branch_taken != predict_taken);

    branch_predictor bp (
        .clk(clk), .reset(reset),
        .pc_index(pc[9:0]),
        .branch_taken(actual_branch_taken),
        .branch_valid(branch_mem),
        .predict_taken(predict_taken)
    );

    // ── Hazard Detection ────────────────────────────────
    wire pc_write_en;
    hazard_detection hdu (
        .id_ex_mem_read(mem_read_ex),
        .id_ex_rt(rt_ex),
        .if_id_rs(rs_id), .if_id_rt(rt_id),
        .branch_mispredicted(branch_mispredicted),
        .pc_write(pc_write_en), .if_id_write(if_id_en),
        .stall(), .flush_id_ex(id_ex_flush)
    );

    assign if_id_flush = branch_mispredicted;

    // ── MEM/WB ──────────────────────────────────────────
    wire [31:0] mem_wb_mem, mem_wb_alu;
    mem_wb_reg mem_wb (
        .clk(clk), .reset(reset),
        .mem_in(mem_read_data), .alu_in(alu_mem),
        .rd_in(rd_mem),
        .reg_write_in(reg_write_mem), .mem_to_reg_in(mem_to_reg_mem),
        .mem_out(mem_wb_mem), .alu_out(mem_wb_alu),
        .rd_out(wb_rd),
        .reg_write_out(wb_reg_write), .mem_to_reg_out(wb_to_reg)
    );

    assign wb_data = wb_to_reg ? mem_wb_mem : mem_wb_alu;

    // ── PC Update ───────────────────────────────────────
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else if (pc_write_en)
            pc <= actual_branch_taken ? pc_mem : pc_plus4;
    end

endmodule