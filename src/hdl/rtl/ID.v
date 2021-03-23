`timescale 1ns / 1ps

`include "config.v"

module ID(
    input wire clk,
    input wire rst_n,
    input wire PIPELINE_FLUSH,
    input wire PIPELINE_READY,
    output wire PIPELINE_VALID,

    input wire [31:0] PC,
    input wire [31:0] PC_PLUS_4,
    input wire [31:0] IR,

    input wire [31:0] cp0_reg_in,
    input wire [`REG_WRITE_RESULT_BUS_LENGTH - 1:0] wb_reg_write_result_bus,

    input wire s_rs_fastforward,
    input wire s_rs_fastforward_bj,
    input wire [31:0] d_rs_fastforward,
    input wire s_rt_fastforward,
    input wire s_rt_fastforward_bj,
    input wire [31:0] d_rt_fastforward,

    output wire [`CP0_RW_BUS_WIDTH-1:0] cp0_rw_bus,
    output wire[`BRANCH_JMP_RESULT_BUS_LENGTH - 1:0] branch_jmp_result_bus,
    output wire[`BRANCH_JMP_BUS_LENGTH-1:0] s_branch_jmp_bus,
    output wire[`REG_INFO_BUS_LENGTH - 1:0] s_reg_info_bus,
    output wire[`ALU_CONTRAL_BUS_LENGTH - 1:0] s_alu_contral_bus,
    output wire[`REG_WRITE_BUS_LENGTH - 1:0] s_reg_write_bus,
    output wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] s_mem_contral_bus,
    output wire s_link,

    output wire[31:0] extended_imm,
    output wire[31:0] d_rs,
    output wire[31:0] d_rt,

    output reg [31:0] pc,

    output wire [31:0] pc_plus_8,

    output wire s_eret,

    output wire s_syscall
    );
    assign PIPELINE_VALID = 1;


    reg [31:0] ir;

    reg [5:0] funct;
    reg [5:0] shmat;
    reg [4:0] rd;
    reg [4:0] rt;
    reg [4:0] rs;

    reg [4:0] rt_for_regfile;
    reg [4:0] rs_for_regfile;

    reg [5:0] opcode;
    reg [15:0] immediate;
    reg [25:0] address;

    reg [31:0] pc_plus_4;
    always @(posedge clk) begin
        if (PIPELINE_READY)
            pc <= PC;
    end

    always @(posedge clk) begin
        if (PIPELINE_READY)
            pc_plus_4 <= PC_PLUS_4;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            ir <= 32'd0;
        else if (PIPELINE_READY)
            ir <= IR;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            funct <= 32'd0;
        else if (PIPELINE_READY)
            funct <= IR[5:0];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            shmat <= 32'd0;
        else if (PIPELINE_READY)
            shmat <= IR[10:6];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            rd <= 32'd0;
        else if (PIPELINE_READY)
            rd <= IR[15:11];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            rt <= 32'd0;
        else if (PIPELINE_READY)
            rt <= IR[20:16];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            rs <= 32'd0;
        else if (PIPELINE_READY)
            rs <= IR[25:21];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            rt_for_regfile <= 32'd0;
        else if (PIPELINE_READY)
            rt_for_regfile <= IR[20:16];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            rs_for_regfile <= 32'd0;
        else if (PIPELINE_READY)
            rs_for_regfile <= IR[25:21];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            opcode <= 32'd0;
        else if (PIPELINE_READY)
            opcode <= IR[31:26];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            immediate <= 32'd0;
        else if (PIPELINE_READY)
            immediate <= IR[15:0];
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_FLUSH && PIPELINE_READY))
            address <= 32'd0;
        else if (PIPELINE_READY)
            address <= IR[25:0];
    end

    assign pc_plus_8 = pc_plus_4 + 'd4;

    wire[31:0] jump_address;
    wire s_mfc0;
    wire s_mtc0;
    decoder decoder_inst_0(
        .pc(pc),
        .pc_plus_4(pc_plus_4),

        .funct(funct),
        .shmat(shmat),
        .rd(rd),
        .rt(rt),
        .rs(rs),
        .opcode(opcode),
        .immediate(immediate),
        .address(address),

        .s_reg_info_bus(s_reg_info_bus),
        .s_branch_jmp_bus(s_branch_jmp_bus),
        .s_alu_contral_bus(s_alu_contral_bus),
        .s_reg_write_bus(s_reg_write_bus),
        .s_mem_contral_bus(s_mem_contral_bus),
        .extended_imm(extended_imm),
        .jump_address(jump_address),

        .s_syscall(s_syscall),
        .s_eret(s_eret),
        .s_mfc0(s_mfc0),
        .s_mtc0(s_mtc0)
    );

    
    wire[31:0] branch_address = pc_plus_4 + {extended_imm[29:0], 2'b00};
    wire [31:0] d_rs_bj;
    wire [31:0] d_rt_bj;
    assign s_link = s_branch_jmp_bus[`BUS_DECODE_LINK];
    branch_jmp_unit branch_jmp_unit_inst_0(
        .s_branch_jmp_bus(s_branch_jmp_bus),
        .d_rs(d_rs_bj),
        .d_rt(d_rt_bj),
        .jump_address(jump_address),
        .branch_address(branch_address),

        .branch_jmp_result_bus(branch_jmp_result_bus)
    );

    wire s_reg_write = wb_reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE];
    wire [4:0] rw = wb_reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE_DST];
    wire [31:0] rw_data = wb_reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE_DATA];

    wire [31:0] reg_rs;
    wire [31:0] reg_rt;
    regfiles regfile_inst_0(
        .clk(clk),
        .rst_n(rst_n),

        .r1_i(rs_for_regfile),
        .r1_data_o(reg_rs),

        .r2_i(rt_for_regfile),
        .r2_data_o(reg_rt),

        .we(s_reg_write),
        .rw_i(rw),
        .rw_data_i(rw_data)
    );


    assign d_rs_bj = ({32{s_rs_fastforward_bj}} & d_rs_fastforward)
                |   ({32{~s_rs_fastforward_bj}} & reg_rs);
    
    assign d_rt_bj =   ({32{s_rt_fastforward_bj}} & d_rt_fastforward )
                |   ({32{~s_rt_fastforward_bj}} & reg_rt );
    
    assign d_rs = ({32{s_mfc0}} & cp0_reg_in)
                 |({32{~s_mfc0}} & reg_rs);
    assign d_rt = reg_rt;

    assign cp0_rw_bus[`BUS_DECODE_CP0_REG_DATA] = d_rt;
    assign cp0_rw_bus[`BUS_DECODE_CP0_REG] = rd;
    assign cp0_rw_bus[`BUS_DECODE_CP0_REG_W] = s_mtc0;

endmodule
