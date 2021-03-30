`timescale 1ns / 1ns


module timer(
    input wire CLK,
    input wire RESETN,

    output wire [31:0] TIME_COUNTER
);

    reg [6:0] counter_100;
    reg [31:0] timer;

    wire _us = counter_100 == 7'd99;

    assign TIME_COUNTER = timer;

    always @(posedge CLK) begin
        if(~RESETN)
            counter_100 <= 'd0;
        else begin
            if(_us)
                counter_100 <= 'd0;
            else
                counter_100 <= counter_100 + 'd1;
        end
    end

    always @(posedge CLK) begin
        if(~RESETN)
            timer <= 'd0;
        else begin
            if(_us)
                timer <= timer + 'd1;
        end
    end

endmodule