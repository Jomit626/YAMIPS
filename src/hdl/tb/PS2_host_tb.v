`timescale 1ns / 1ps

`include "config.v"

`define  T 10

module PS2_host_tb (
);
    reg CLK100MHZ = 0;
    reg RESETN = 0;
    reg PS2_DATA = 0;
    reg PS2_CLK = 1;

    wire [31:0] DATA;
    wire INT;
    always #(`T/2) CLK100MHZ = ~CLK100MHZ;

    PS2_host ps2_hots_tb_inst(
        .CLK(CLK100MHZ),
        .RESETN(RESETN),

        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),

        .DATA(DATA),
        .INT(INT)
    );

    initial begin
        #(10*`T) RESETN = 1;

        PS2_sent_byte(8'h0f);

        PS2_sent_byte(8'hf0);
    end

    reg [10:0] sent_data;
    task PS2_sent_byte;
        input [7:0] byte;
        begin :f
            integer i;
            sent_data = { 1'b1, ~^byte, byte, 1'b0};
            for(i=0;i<11;i=i+1) begin
                PS2_DATA = sent_data[i];
                PS2_CLK = 1;
                #(10*`T);
                PS2_DATA = sent_data[i];
                PS2_CLK = 0;
                #(10*`T);
            end
        end
    endtask
endmodule

