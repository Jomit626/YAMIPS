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

    output wire S_INT,
    output wire [31:0] EPC,
    output wire [31:0] INT_ENTER,

    input wire INT1,
    input wire INT2,
    input wire INT3,
    input wire INT4,
    input wire INT5,
    input wire INT6,
    input wire INT7,

    output wire [31:0] REG_OUT,
    input wire [31:0] REG_IN,
    input wire [5:0] REG_R,
    input wire REG_WE,

    input wire S_SYSCALL,
    input wire[31:0] EPC_IN
    );

    reg [31:0] epc;
    reg [31:0] int_enter;
    reg [7:0] interrupt_mask;
    reg [3:0] exception_code;
    wire [31:0] cause = { 16'h0000 , interrupt_mask, 1'b0, exception_code, 2'b00 };

    wire [7:0] input_int = {INT7,INT6,INT5,INT4,INT3,INT2,INT1, 1'b0};
    reg [7:0] pending_int;
    wire [7:0] available_int = interrupt_mask & pending_int;

    wire s_enter_int;
    wire [7:0] enter_int;
    wire [2:0] enter_int_index;

    // I/O
    assign S_INT = s_enter_int | S_SYSCALL;
    assign EPC = epc;
    assign INT_ENTER = int_enter;
    assign REG_OUT = (REG_R == `CP0_EPC) ? epc : cause;


    // CP0 regs
    always @(posedge CLK) begin
        if(~RESETN)
            epc <= 'd0;
        else if(PIPELINE_READY) begin
            
            if (S_SYSCALL | S_INT)
                epc <= EPC_IN;
            else if(REG_R == `CP0_EPC && REG_WE)
                epc <= REG_IN;
        end

    end

    always @(posedge CLK) begin
        if(~RESETN)
            int_enter <= `INT_ENTER_RESET_ADDRESS;
        else if(PIPELINE_READY) begin

            if(REG_R == `CP0_INT_ENTER && REG_WE)
                int_enter <= REG_IN;
        end
    end


    // Inter
    priority_encoder #(.INPUT_WIDTH(8)) priority_encoder_inst_cp0_0 (
        .A(available_int),
        .B(enter_int_index),
        .SELN(enter_int),
        .ANY(s_enter_int)
    );

    // record pending interupt
    genvar i;
    generate
        for(i=0;i<8;i=i+1)begin : sample_int
            always @(posedge CLK or posedge input_int[i]) begin
                if(~RESETN)
                    pending_int[i] <= 1'b0;
                else begin 
                    if (enter_int[i] & PIPELINE_READY)
                        pending_int[i] <= 1'b0;
                    else if(input_int[i])
                        pending_int[i] <= 1'b1;
                end
            end
        end
    endgenerate


    // Cause reg
    wire s_write_cause_reg = ((REG_R == `CP0_CAUSE )&& REG_WE);
    //      mask part
    generate
        for(i=0;i<8;i=i+1)begin : mask
            always @(posedge CLK) begin
                if(~RESETN)
                    interrupt_mask[i] <= 1'b0;
                else if(PIPELINE_READY) begin 
                    if (enter_int[i])
                        interrupt_mask[i] <= 1'b0;
                    else if(s_write_cause_reg)
                        interrupt_mask[i] <= REG_IN[8 + i];
                end
            end
        end
    endgenerate

    // exception code
    always @(posedge CLK) begin
        if(~RESETN)
            exception_code <= 4'h0;
        else if(PIPELINE_READY) begin 
            if (s_enter_int | S_SYSCALL)
                exception_code <= {1'b0, enter_int_index};
        end
    end
endmodule
