`timescale 1ns / 1ps

`include "config.v"

module fastforward(
    input wire clk,
    input wire reset_n,
    input wire PIPELINE_READY,

    input wire[`REG_INFO_BUS_LENGTH - 1:0] id_s_reg_info_bus,
    input wire[`BRANCH_JMP_BUS_LENGTH-1:0] s_branch_jmp_bus,

    input wire[`REG_WRITE_BUS_LENGTH - 1:0] ex_reg_write_bus,
    input wire[`EX_RESULT_BUS_LENGTH - 1:0] ex_result_bus,
    input wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] ex_s_mem_contral_bus,

    input wire [`REG_WRITE_RESULT_BUS_LENGTH - 1:0] mem_reg_write_result_bus,

    output wire s_loaduse,
    output wire s_branch_jr_ok,

    output reg s_rs_fastforward,
    output reg s_rs_fastforward_bj,
    output reg [31:0] d_rs_fastforward,
    output reg s_rt_fastforward,
    output reg s_rt_fastforward_bj,
    output reg [31:0] d_rt_fastforward
    );


    wire [4:0] rs = id_s_reg_info_bus[`BUS_DECODE_RS];
    wire [4:0] rt = id_s_reg_info_bus[`BUS_DECODE_RT];
    wire s_rs_used = id_s_reg_info_bus[`BUS_DECODE_RS_USE];
    wire s_rt_used = id_s_reg_info_bus[`BUS_DECODE_RT_USE];

    wire s_branch           = s_branch_jmp_bus[`BUS_DECODE_BRANCH];
    wire s_jr               = s_branch_jmp_bus[`BUS_DECODE_JR];

    wire ex_s_mem_read = ex_s_mem_contral_bus[`BUS_DECODE_MEM_READ];

    wire [4:0] ex_reg_dst = ex_reg_write_bus[`BUS_DECODE_REG_WRITE_DST];
    wire ex_reg_wen = ex_reg_write_bus[`BUS_DECODE_REG_WRITE] & (|ex_reg_dst);
    wire [31:0] ex_result_fastforward = ex_result_bus[`BUS_DECODE_EX_RESULT];

    wire [4:0] mem_reg_dst = mem_reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE_DST];
    wire mem_reg_wen = mem_reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE] & (|mem_reg_dst);
    wire [31:0] mem_result_fastforward = mem_reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE_DATA];

    wire rw_hazar_ex_rs = (ex_reg_dst == rs) && ex_reg_wen & s_rs_used;
    wire rw_hazar_mem_rs = (mem_reg_dst == rs) && mem_reg_wen & s_rs_used;
    wire rw_hazar_ex_rt = (ex_reg_dst == rt) && ex_reg_wen & s_rt_used;
    wire rw_hazar_mem_rt = (mem_reg_dst == rt) && mem_reg_wen & s_rt_used;

    wire rs_fastforward_ex = rw_hazar_ex_rs && ~ex_s_mem_read;
    wire rs_fastforward_mem = rw_hazar_mem_rs;

    wire rt_fastforward_ex = rw_hazar_ex_rt && ~ex_s_mem_read;
    wire rt_fastforward_mem = rw_hazar_mem_rt;

    assign s_loaduse = (rw_hazar_ex_rs || rw_hazar_ex_rt) && ex_s_mem_read;
    wire s_branch_jr_stall = (rw_hazar_ex_rs || rw_hazar_ex_rt || rw_hazar_mem_rs || rw_hazar_mem_rt) & (s_branch | s_jr);
    reg s_branch_jr_stalled;
    assign s_branch_jr_ok = ~s_branch_jr_stall | (s_branch_jr_stall & s_branch_jr_stalled) | (~s_branch & ~s_jr);

    always @(posedge clk) begin
        if(~reset_n)
            s_branch_jr_stalled <= 'b0;
        else if(PIPELINE_READY) begin
            if(s_branch_jr_stalled)
                s_branch_jr_stalled <= 'b0;
            else
                s_branch_jr_stalled <= s_branch_jr_stall;
        end
    end

    always @(posedge clk) begin
        if(~reset_n)
            s_rs_fastforward <= 'b0;
        else if(PIPELINE_READY)
            s_rs_fastforward <= rs_fastforward_ex | rs_fastforward_mem;
    end

    always @(posedge clk) begin
        if(~reset_n)
            s_rs_fastforward_bj <= 'b0;
        else if(PIPELINE_READY)
            s_rs_fastforward_bj <= (rs_fastforward_ex | rs_fastforward_mem) & (s_branch | s_jr);
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            d_rs_fastforward <=     ({32{rs_fastforward_ex}} & ex_result_fastforward)
                                |   ({32{~rs_fastforward_ex & rs_fastforward_mem}} & mem_result_fastforward);
    end

    always @(posedge clk) begin
        if(~reset_n)
            s_rt_fastforward <= 'b0;
        else if(PIPELINE_READY)
            s_rt_fastforward <= rt_fastforward_ex | rt_fastforward_mem;
    end

    always @(posedge clk) begin
        if(~reset_n)
            s_rt_fastforward_bj <= 'b0;
        else if(PIPELINE_READY)
            s_rt_fastforward_bj <= (rt_fastforward_ex | rt_fastforward_mem )& (s_branch | s_jr);
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            d_rt_fastforward <=     ({32{rt_fastforward_ex}} & ex_result_fastforward)
                                |   ({32{~rt_fastforward_ex & rt_fastforward_mem}} & mem_result_fastforward);
    end
endmodule
