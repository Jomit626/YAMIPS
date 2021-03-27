module PS2_host #(
    parameter C_DEBOUNCE_BITS = 4
) (
    input wire CLK,
    input wire RESETN,

    input wire PS2_CLK,
    input wire PS2_DATA,

    output wire [31:0] DATA,
    output wire INT_O
);

    reg [1:0] ps2_clk_d;

    reg [31:0] data;
    reg [3:0] recv_counter;
    reg [8:0] recv_data;
    reg recv_end;

    reg interrupt;

    wire [7:0] recv_byte = recv_data[7:0];
    wire party_bit = recv_data[8];
    wire ps2_clk;
    wire ps2_data;

    // I/O assignment 
    assign DATA = data;
    assign INT_O = interrupt;

    Debouncer #(.C_BITS(C_DEBOUNCE_BITS)) debouncer_ps2_clk(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(PS2_CLK),
        .SIGNAL_O(ps2_clk)
    );

    Debouncer #(.C_BITS(C_DEBOUNCE_BITS)) debouncer_ps2_data(
        .CLK(CLK),
        .RESETN(RESETN),
        .SIGNAL_I(PS2_DATA),
        .SIGNAL_O(ps2_data)
    );

    // Dectetc negedge of ps2_clk
    wire ps2_clk_negedge = ps2_clk_d[1] & ~ps2_clk_d[0];
    always @(posedge CLK) begin
        if(~RESETN)
            ps2_clk_d <= 'd0;
        else
            ps2_clk_d <= {ps2_clk_d[0], ps2_clk};
    end

    always @(negedge CLK) begin
        if(~RESETN)
            recv_data <= 'd0;
        else if (ps2_clk_negedge)
            recv_data <= {ps2_data, recv_data[8:1]};
    end

    // transfer counter
    always @(negedge CLK) begin
        if(~RESETN)
            recv_counter <= 'd0;
        else if (ps2_clk_negedge) begin
            if (recv_counter == 'd10)
                recv_counter <= 'd0;
            else
                recv_counter <= recv_counter + 'd1;
        end
    end

    always @(negedge CLK) begin
        if(~RESETN)
            recv_end <= 'd0;
        else if (ps2_clk_negedge) begin
            if (recv_counter == 'd9)
                recv_end <= 'd1;
            else
                recv_end <= 'd0;
        end
    end

    wire data_valid = ^recv_data & recv_end;
    always @(negedge CLK) begin
        if(~RESETN)
            data <= 'd0;
        else if (data_valid & ps2_clk_negedge)
            data <= {data[23:0], recv_byte};
    end

    always @(negedge CLK) begin
        if(~RESETN)
            interrupt <= 'd0;
        else if (data_valid & ps2_clk_negedge)
            interrupt <= 'd1;
        else
            interrupt <= 'd0;
    end
endmodule