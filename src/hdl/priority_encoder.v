`timescale 1ns / 1ps

module priority_encoder #(
    parameter integer INPUT_WIDTH = 16,
    parameter integer OUTPUT_WIDTH = clogb2(INPUT_WIDTH - 1)
    )
    (
        input wire [INPUT_WIDTH-1:0]  A,
        output wire [OUTPUT_WIDTH-1:0]  B,
        output  wire ANY
    );
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
        bit_depth = bit_depth >> 1;                                 
    end                                                           
    endfunction

    wire [INPUT_WIDTH-1:0]  C;

    genvar i,j;
    generate 
        for(i=0;i<INPUT_WIDTH;i=i+1) begin :gen_other
            if(i == INPUT_WIDTH - 1) begin
                assign C[i] = A[i];
            end else begin
                wire [INPUT_WIDTH - i - 1 - 1:0] other;
                for(j=INPUT_WIDTH-1; j>i; j=j-1) begin :assign_other
                    assign other[j-i-1] = A[j];
                end
                assign C[i] = A[i] && (~|other);
            end
        end
    endgenerate

    one_hot_decoder #(.INPUT_WIDTH(INPUT_WIDTH))
    de(
        .A(C),
        .B(B),
        .ANY(ANY)
    );
endmodule
