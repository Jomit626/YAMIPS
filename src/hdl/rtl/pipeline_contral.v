`timescale 1ns / 1ps

`include "config.v"

module pipiline_contral (
    input wire clk,
    input wire rst_n,

    input wire IF_VALID,
    output wire IF_READY,
    output wire IF_FLUSH,

    input wire ID_VALID,
    output wire ID_READY,
    output wire ID_FLUSH,

    input wire EX_VALID,
    output wire EX_READY,
    output wire EX_FLUSH,

    input wire MEM_VALID,
    output wire MEM_READY,
    output wire MEM_FLUSH,

    input wire WB_VALID,
    output wire WB_READY,
    output wire WB_FLUSH,

    input wire[`BRANCH_JMP_RESULT_BUS_LENGTH - 1:0] if_id_branch_jmp_result_bus,

    input wire S_BRANCH_JR_OK,
    input wire S_LOADUSE,
    input wire S_INT,
    input wire S_SYSCALL,
    input wire S_ERET

);
    // decode
    wire s_branch_taken = if_id_branch_jmp_result_bus[`BUS_DECODE_RES_BRANCH_TAKEN];
    wire s_branch = if_id_branch_jmp_result_bus[`BUS_DECODE_RES_BRANCH];
    wire s_jmp = if_id_branch_jmp_result_bus[`BUS_DECODE_RES_JMP];
    wire s_jr = if_id_branch_jmp_result_bus[`BUS_DECODE_RES_JR];
    

    wire jump_or_branch_flush;
    wire pipeline_ready;
    
    // pipeline
    wire s_stall = S_LOADUSE | ~S_BRANCH_JR_OK;
    assign jump_or_branch_flush = S_SYSCALL | S_INT;
    assign pipeline_ready = IF_VALID & ID_VALID & EX_VALID & MEM_VALID &  WB_VALID;

    assign IF_READY = pipeline_ready & ~s_stall; 
    assign IF_FLUSH = 0;

    assign ID_READY = pipeline_ready & ~s_stall;
    assign ID_FLUSH = jump_or_branch_flush;

    assign EX_READY = pipeline_ready;
    assign EX_FLUSH = s_stall;

    assign MEM_READY = pipeline_ready;
    assign MEM_FLUSH = 0;

    assign WB_READY = pipeline_ready;
    assign WB_FLUSH = 0;
endmodule