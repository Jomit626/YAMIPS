`timescale 1ns / 1ps

`include "config.v"

module EX(
    input wire clk,
    input wire rst_n,

    input wire PIPELINE_FLUSH,
    input wire PIPELINE_READY,
    output wire PIPELINE_VALID,

    input wire [31:0] pc_i,
    input wire [31:0] pc_plus_8_i,

    input wire s_link_i,
    input wire[`ALU_CONTRAL_BUS_LENGTH - 1:0] s_alu_contral_bus_i,
    input wire[`REG_WRITE_BUS_LENGTH - 1:0] s_reg_write_bus_i,
    input wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] s_mem_contral_bus_i,
    input wire[31:0] extended_imm_i,
    input wire[31:0] d_rs_i,
    input wire[31:0] d_rt_i,

    input wire s_rs_fastforward,
    input wire [31:0] d_rs_fastforward,
    input wire s_rt_fastforward,
    input wire [31:0] d_rt_fastforward,

    output reg[`REG_WRITE_BUS_LENGTH - 1:0] s_reg_write_bus,
    output reg[`MEM_CONTRAL_BUS_LENGTH - 1:0] s_mem_contral_bus,
    output wire[`EX_RESULT_BUS_LENGTH - 1:0] ex_result_bus
    );
    assign PIPELINE_VALID = 1;

    reg [31:0] pc;
    reg [31:0] pc_plus_8;

    reg s_link;
    reg [`ALU_CONTRAL_BUS_LENGTH - 1:0] s_alu_contral_bus;
    reg [31:0] extended_imm;
    reg [31:0] reg_rs;
    reg [31:0] reg_rt;
    wire[31:0] d_rs = ({32{s_rs_fastforward}} & d_rs_fastforward)
                    |   ({32{~s_rs_fastforward}} & reg_rs);
    
    wire[31:0] d_rt =   ({32{s_rt_fastforward}} & d_rt_fastforward )
                    |   ({32{~s_rt_fastforward}} & reg_rt );
    //
    always @(posedge clk) begin
        if(PIPELINE_READY)
            pc <= pc_i;
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            pc_plus_8 <= pc_plus_8_i;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            s_link <= 'd0;
        else if(PIPELINE_READY)
            s_link <= s_link_i;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            s_alu_contral_bus <= 'd0;
        else if(PIPELINE_READY)
            s_alu_contral_bus <= s_alu_contral_bus_i;
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            extended_imm <= extended_imm_i;
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            reg_rs <= d_rs_i;
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            reg_rt <= d_rt_i;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            s_reg_write_bus <= 'd0;
        else if(PIPELINE_READY)
            s_reg_write_bus <= s_reg_write_bus_i;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            s_mem_contral_bus <= 'd0;
        else if(PIPELINE_READY)
            s_mem_contral_bus <=s_mem_contral_bus_i;
    end

    wire [3:0] alu_op = s_alu_contral_bus[`BUS_DECODE_ALU_OP];
    wire [4:0] ir_shamt = s_alu_contral_bus[`BUS_DECODE_SHMAT];
    wire s_shmat_reg = s_alu_contral_bus[`BUS_DECODE_SHMAT_REG];
    wire s_alu_imm = s_alu_contral_bus[`BUS_DECODE_ALU_IMM];
    wire s_lui = s_alu_contral_bus[`BUS_DECODE_LUI];
    wire s_rs_bypass = s_alu_contral_bus[`BUS_DECODE_S_RS_BYPASS];
    wire [31:0] A = d_rs;
    wire [31:0] B = s_alu_imm ? extended_imm : d_rt;
    wire [4:0] alu_shamt = s_shmat_reg ? d_rs[4:0] : ir_shamt;
    wire [31:0] alu_res;

    ALU alu(
        .op(alu_op),
        .A(A),
        .B(B),
        .shmat(alu_shamt),

        .res(alu_res),
        .zero_flag(),
        .carray_flag(),
        .overflow_flag()
    );

    assign ex_result_bus[`BUS_DECODE_EX_RESULT] =   ({32{s_rs_bypass}}     &   d_rs)
                                                |   ({32{s_lui} }          &   {extended_imm[15:0], { 16{1'b0} }})
                                                |   ({32{s_link}}          &   pc_plus_8)
                                                |   ({32{~s_rs_bypass & ~s_lui & ~s_link}} & alu_res);
    assign ex_result_bus[`BUS_DECODE_RT_BYPASS] = d_rt;
endmodule
