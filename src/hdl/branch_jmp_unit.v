`timescale 1ns / 1ps

`include "config.v"

module branch_jmp_unit(
    input wire[`BRANCH_JMP_BUS_LENGTH - 1:0] s_branch_jmp_bus,
    input wire[31:0] d_rs,
    input wire[31:0] d_rt,
    input wire[31:0] jump_address,
    input wire[31:0] branch_address,

    output wire[`BRANCH_JMP_RESULT_BUS_LENGTH - 1:0] branch_jmp_result_bus
    );

    wire s_branch           = s_branch_jmp_bus[`BUS_DECODE_BRANCH];
    wire s_branch_cmp_zero  = s_branch_jmp_bus[`BUS_DECODE_CMP_ZERO];
    wire s_branch_eq        = s_branch_jmp_bus[`BUS_DECODE_BRANCH_EQ];
    wire s_branch_neq       = s_branch_jmp_bus[`BUS_DECODE_BRANCH_NEQ];
    wire s_branch_gtz       = s_branch_jmp_bus[`BUS_DECODE_BRANCH_GTZ];
    wire s_branch_ltz       = s_branch_jmp_bus[`BUS_DECODE_BRANCH_LTZ];
    wire s_jmp              = s_branch_jmp_bus[`BUS_DECODE_JMP];
    wire s_jr               = s_branch_jmp_bus[`BUS_DECODE_JR];
    wire s_link             = s_branch_jmp_bus[`BUS_DECODE_LINK];

    wire cmp_zero_eq = ~|d_rs;
    wire cmp_zero_gt = !cmp_zero_eq & !d_rs[31];
    wire cmp_zero_lt = !cmp_zero_eq & d_rs[31];

    wire cmp_eq = &(d_rs ~^ d_rt);
    wire cmp_neq = ~cmp_eq;

    wire s_branch_taken = 
        s_branch & (
            (((s_branch_cmp_zero & cmp_zero_eq) | (!s_branch_cmp_zero & cmp_eq)) & s_branch_eq)  |
            (cmp_neq & s_branch_neq) |
            (s_branch_cmp_zero & cmp_zero_gt & s_branch_gtz) |
            (s_branch_cmp_zero & cmp_zero_lt & s_branch_ltz)
        );
    
    assign branch_jmp_result_bus[`BUS_DECODE_RES_ADDR] = ({32{s_jmp}} & jump_address)
                                                        |({32{s_jr}} & d_rs)
                                                        |({32{s_branch}} & branch_address);

    assign branch_jmp_result_bus[`BUS_DECODE_RES_BRANCH_TAKEN] = s_branch_taken;
    assign branch_jmp_result_bus[`BUS_DECODE_RES_BRANCH] = s_branch;
    assign branch_jmp_result_bus[`BUS_DECODE_RES_JMP] = s_jmp;
    assign branch_jmp_result_bus[`BUS_DECODE_RES_JR] = s_jr;
endmodule
