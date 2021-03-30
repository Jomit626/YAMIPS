`timescale 1ns / 1ps

module EdgeDetect (
    input wire CLK,
    input wire RESETN,

    input wire SIGNAL,
    output wire SIGNAL_POS_EDGE,
    output wire SIGNAL_NEG_EDGE
);
    reg [1:0] signal;

    assign SIGNAL_POS_EDGE = ~signal[1] & signal[0];
    assign SIGNAL_NEG_EDGE = signal[1] & ~signal[0];

    always @(posedge CLK) begin
        if(~RESETN)
            signal <= 'd0;
        else
            signal <= {signal[0], SIGNAL};
    end
endmodule

module Button (
    input wire CLK,
    input wire RESETN,

    input wire BTNU,
    input wire BTNL,
    input wire BTNR,
    input wire BTND,
    input wire BTNC,

    output wire SYNC_BTNU_INT,
    output wire SYNC_BTNL_INT,
    output wire SYNC_BTNR_INT,
    output wire SYNC_BTND_INT,
    output wire SYNC_BTNC_INT
);
    wire btnu;
    wire btnl;
    wire btnr;
    wire btnd;
    wire btnc;

    wire btnu_posedge;
    wire btnl_posedge;
    wire btnr_posedge;
    wire btnd_posedge;
    wire btnc_posedge;

    assign SYNC_BTNU_INT = btnu_posedge;
    assign SYNC_BTNL_INT = btnl_posedge;
    assign SYNC_BTNR_INT = btnr_posedge;
    assign SYNC_BTND_INT = btnd_posedge;
    assign SYNC_BTNC_INT = btnc_posedge;

    Debouncer debouncer_button_btnu(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(BTNU),
        .SIGNAL_O(btnu)
    );

    EdgeDetect edge_detect_btnu(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL(btnu),
        .SIGNAL_POS_EDGE(btnu_posedge),
        .SIGNAL_NEG_EDGE()
    );

    Debouncer debouncer_button_btnl(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(BTNL),
        .SIGNAL_O(btnl)
    );

    EdgeDetect edge_detect_btnl(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL(btnl),
        .SIGNAL_POS_EDGE(btnl_posedge),
        .SIGNAL_NEG_EDGE()
    );

    Debouncer debouncer_button_btnr(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(BTNR),
        .SIGNAL_O(btnr)
    );

    EdgeDetect edge_detect_btnr(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL(btnr),
        .SIGNAL_POS_EDGE(btnr_posedge),
        .SIGNAL_NEG_EDGE()
    );

    Debouncer debouncer_button_btnd(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(BTND),
        .SIGNAL_O(btnd)
    );

    EdgeDetect edge_detect_btnd(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL(btnd),
        .SIGNAL_POS_EDGE(btnd_posedge),
        .SIGNAL_NEG_EDGE()
    );

    Debouncer debouncer_button_btnc(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(BTNC),
        .SIGNAL_O(btnc)
    );

    EdgeDetect edge_detect(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL(btnc),
        .SIGNAL_POS_EDGE(btnc_posedge),
        .SIGNAL_NEG_EDGE()
    );
endmodule