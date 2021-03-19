`timescale 1ns / 1ps

`include "config.v"

module IF(
    input wire clk,
    input wire rst_n,
    input wire PIPELINE_FLUSH,
    input wire PIPELINE_READY,
    output wire PIPELINE_VALID,

    input wire[`BRANCH_JMP_RESULT_BUS_LENGTH - 1:0] branch_jmp_result_bus,
    input wire s_syscall,
    input wire s_eret,
    input wire [31:0] epc,

    output wire [31:0] PC,
    output wire [31:0] IR,
    output wire [31:0] PC_PLUS_4,

    output wire [31:0] M_ARADDR,
    output wire M_ARVALID,

    input wire [31:0] M_RDATA,
    input wire M_RVALID
    );

    localparam integer 
        STATE_READ = 2'b01,
        STATE_WAIT = 2'b00,
        STATE_RESET = 2'b10;
    
    // interal siganls
    reg [1:0] cstate;
    reg [1:0] nstate;

    wire pipeline_next = PIPELINE_VALID && PIPELINE_READY; 

    reg [31:0] pc;
    reg [31:0] pc_dup;
    wire [31:0] pc_plus_4 = pc + 32'd4;

    reg arvalid;

    // ID stage signal
    wire [31:0] address = branch_jmp_result_bus[`BUS_DECODE_RES_ADDR];
    wire s_branch_taken = branch_jmp_result_bus[`BUS_DECODE_RES_BRANCH_TAKEN];
    wire s_branch = branch_jmp_result_bus[`BUS_DECODE_RES_BRANCH];
    wire s_jmp = branch_jmp_result_bus[`BUS_DECODE_RES_JMP];
    wire s_jr = branch_jmp_result_bus[`BUS_DECODE_RES_JR];

    wire s_branch_jmp = (s_branch_taken & s_branch) | s_jmp | s_jr;

    // I/O Assignment
    assign PC = pc;
    assign IR = M_RDATA;
    assign PC_PLUS_4 = pc_plus_4;

    assign M_ARADDR = pc_dup;
    assign M_ARVALID = arvalid;

    assign PIPELINE_VALID = M_RVALID;

    // State Mechine 
    always @(posedge clk) begin
        if(!rst_n)
            cstate <= STATE_RESET;
        else
            cstate <= nstate;
    end

    always @(*) begin
        if(cstate == STATE_RESET)
            nstate <= STATE_READ;
        else if(~pipeline_next)
            nstate <= STATE_WAIT;
        else
            nstate <= STATE_READ;
    end

    always @(*) begin
        if(cstate == STATE_READ)
            arvalid <= 1;
        else
            arvalid <= 1;
    end

    // PC reg
    always @(posedge clk) begin
        if(!rst_n)
            pc <= 32'd0;
        else if(pipeline_next) begin
            if(s_branch_jmp)
                pc <= address;
            else if(s_syscall)
                pc <= `SYSCALL_ENTRAL_ADDRESS;
            else if(s_eret)
                pc <= epc;
            else
                pc <= pc_plus_4;
        end else 
            pc <= pc;
    end

    always @(posedge clk) begin
        if(!rst_n)
            pc_dup <= 32'd0;
        else if(pipeline_next) begin
            if(s_branch_jmp)
                pc_dup <= address;
            else if(s_syscall)
                pc_dup <= `SYSCALL_ENTRAL_ADDRESS;
            else if(s_eret)
                pc_dup <= epc;
            else
                pc_dup <= pc_plus_4;
        end else 
            pc_dup <= pc_dup;
    end
endmodule
