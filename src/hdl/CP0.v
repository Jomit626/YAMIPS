`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/11 15:37:04
// Design Name: 
// Module Name: CP0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CP0(
    input wire CLK,
    input wire RESETN,
    input wire PIPELINE_READY,

    output wire [31:0] EPC,

    output wire [31:0] REG_OUT,
    input wire [31:0] REG_IN,
    input wire [5:0] REG_R,
    input wire REG_WE,

    input wire S_SYSCALL,
    input wire[31:0] EPC_IN
    );

    reg [31:0] epc;
    reg [31:0] cause;
    wire [7:0] interrupt_mask = cause[15:8];

    assign EPC = epc;
    assign REG_OUT = (REG_R == `CP0_EPC) ? epc : cause;

    always @(posedge CLK) begin
        if(~RESETN)
            epc <= 'd0;
        else if(PIPELINE_READY) begin
            
            if (S_SYSCALL)
                epc <= EPC_IN;
            else if(REG_R == `CP0_EPC && REG_WE)
                epc <= REG_IN;
        end

    end
    always @(posedge CLK) begin
        if(~RESETN)
            cause <= 'd0;
        else if(PIPELINE_READY) begin

            if(REG_R == `CP0_CAUSE && REG_WE)
                cause <= REG_IN;
        end
    end

endmodule
