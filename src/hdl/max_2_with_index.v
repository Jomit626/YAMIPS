`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/09 12:25:21
// Design Name: 
// Module Name: max_2_with_index
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


module max_2_with_index #(
    parameter integer C_DATA_WIDTH = 3,
    parameter integer C_INDEX_WIDTH = 2
    )(
        input wire[C_DATA_WIDTH-1:0] D0,
        input wire[C_DATA_WIDTH-1:0] D1,
        input wire[C_INDEX_WIDTH-1:0] I0,
        input wire[C_INDEX_WIDTH-1:0] I1,

        output wire[C_DATA_WIDTH-1:0] D,
        output wire[C_INDEX_WIDTH-1:0] I
    );

    wire gt = $unsigned(D0) > $unsigned(D1);
    assign D = gt ? D0 : D1;
    assign I = gt ? I0 : I1;
endmodule
