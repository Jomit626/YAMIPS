module segmemt_display_driver #(
    parameter C_INPUT_CLOCK_F_MHZ = 100
)
(
    input wire CLK,
    input wire RESETN,
    input wire [31:0] DATA,

    output wire [7:0] AN,
    output wire CA,
    output wire CB,
    output wire CC,
    output wire CD,
    output wire CE,
    output wire CF,
    output wire CG,
    output wire DP
);
    reg [15:0] counter;
    wire flush_clk;

    reg [7:0] an = 8'h01;
    reg [7:0] cs = 8'h01;
    wire [3:0] seg_data[7:0];
    wire [2:0] index;

    genvar i;
    generate
        for(i=0;i<8;i=i+1) begin :seg
            assign seg_data[i] = DATA[(3 + i*4) : i*4];
        end
    endgenerate

    // I/O assign ment
    assign AN = ~an;
    assign CA = cs[7];
    assign CB = cs[6];
    assign CC = cs[5];
    assign CD = cs[4];
    assign CE = cs[3];
    assign CF = cs[2];
    assign CG = cs[1];
    assign DP = cs[0];

    // generate flush_clk
    assign flush_clk = counter[15];
    always @(posedge CLK) begin
        if(~RESETN)
            counter <= 'd0;
        else
            counter <= counter + 1;
    end

    always @(posedge flush_clk) begin
        if(~RESETN)
            an <= 8'h01;
        else
            an <= {an[6:0], an[7]};
    end

    one_hot_decoder #(
        .INPUT_WIDTH(8)
    ) index_de(
        .A(an), 
        .B(index)
    );

    always @(*) begin
        case(seg_data[index])
        4'b0000: cs <=8'b0000_0011;
        4'b0001: cs <=8'b1001_1111;
        4'b0010: cs <=8'b0010_0101;
        4'b0011: cs <=8'b0000_1101;
        4'b0100: cs <=8'b1001_1001;
        4'b0101: cs <=8'b0100_1001;
        4'b0110: cs <=8'b0100_0001;
        4'b0111: cs <=8'b0001_1111;
        4'b1000: cs <=8'b0000_0001;
        4'b1001: cs <=8'b0001_1001;
        4'b1010: cs <=8'b0001_0001;
        4'b1011: cs <=8'b1100_0001;
        4'b1100: cs <=8'b1110_0101;
        4'b1101: cs <=8'b1000_0101;
        4'b1110: cs <=8'b0110_0001;
        4'b1111: cs <=8'b0111_0001;
        default: cs <=8'b0000_0000;
        endcase
    end
endmodule