`timescale 1ns / 1ps

module one_hot_decoder #(
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

    genvar i,j,k;
    generate 
        for(i=0;i<OUTPUT_WIDTH;i=i+1) begin :gen_group
            wire [(INPUT_WIDTH / (2<<i))-1:0] group;
            for(j=(1 << i); j<INPUT_WIDTH; j=j+(2<<i)) begin :gen_set
                wire [(1 << i) -1:0] set;
                for(k=0;k<(1<<i);k=k+1) begin :assign_set
                    assign set[k] = A[j + k];
                end
                assign group[j/(2 << i)] = |set;
            end
            assign B[i] = |group;
        end
    endgenerate

    assign ANY = |A;
endmodule
