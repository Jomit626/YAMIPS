`timescale 1ns / 1ps

module regfiles(
    input wire clk,
    input wire rst_n,

    input wire[4:0] r1_i,
    output wire[31:0] r1_data_o,

    input wire[4:0] r2_i,
    output wire[31:0] r2_data_o,

    input wire we,
    input wire[4:0] rw_i,
    input wire[31:0] rw_data_i
    );
    
    wire [31:0] regs[31:0];

    genvar i;
    generate
        for(i=0;i<32;i=i+1)begin :regster
            if(i == 0) begin
                assign regs[0] = 'd0;
            end else begin
                reg [31:0] d_flop;
                always @(negedge clk) begin
                    if (~rst_n)
                        d_flop <= 'd0;
                    else if(we & (rw_i == i))
                        d_flop <= rw_data_i;
                end
                assign regs[i] = d_flop;
            end
        end
    endgenerate

    assign r1_data_o = regs[r1_i];
    assign r2_data_o = regs[r2_i];
endmodule
