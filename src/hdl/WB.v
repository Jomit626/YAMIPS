`timescale 1ns / 1ps

`include "config.v"

module WB(
    input wire clk,
    input wire rst_n,

    input wire PIPELINE_FLUSH,
    input wire PIPELINE_READY,
    output wire PIPELINE_VALID,

    input  wire[`REG_WRITE_RESULT_BUS_LENGTH - 1:0] reg_write_result_bus_i,
    output reg[`REG_WRITE_RESULT_BUS_LENGTH - 1:0] reg_write_result_bus
    );
    assign PIPELINE_VALID = 1;

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            reg_write_result_bus <= 'd0;
        else if(PIPELINE_READY)
            reg_write_result_bus <= reg_write_result_bus_i;
    end

endmodule
