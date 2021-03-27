module Debouncer #(
    parameter C_BITS = 4
) (
    input wire CLK,
    input wire RESETN,

    input wire SIGNAL_I,
    output wire SIGNAL_O
);
    reg [C_BITS-1:0] signal_d;
    reg signal_o;

    assign SIGNAL_O = signal_o;

    always @(posedge CLK) begin
        if(~RESETN)
            signal_d <= 'd0;
        else
            signal_d <= {signal_d[C_BITS-2:0], SIGNAL_I};
    end

    always @(posedge CLK) begin
        if(~RESETN)
            signal_o <= 'd0;
        else begin
            if ( &signal_d )
                signal_o <= 'd1;
            else if ( ~|signal_d )
                signal_o <= 'd0;
        end
    end
endmodule