`timescale 1ns / 1ps

`include "config.v"

`define  T 10

module CP0_tb (
);
    reg [31:0] clk_counter = 0;
    reg CLK100MHZ = 0;
    reg CPU_RESETN = 0;
    reg PIPELINE_READY = 0;

    reg INT1 = 0;
    reg INT2 = 0;
    reg INT3 = 0;
    reg INT4 = 0;
    reg INT5 = 0;
    reg INT6 = 0;
    reg INT7 = 0;

    wire S_INT;
    wire [31:0] EPC;
    wire [31:0] INT_ENTER;

    wire [31:0] REG_OUT;

    reg [31:0] REG_IN = 'd0;
    reg [4:0] REG_R = 'd0;
    reg REG_WE = 'd0;

    reg S_SYSCALL = 0;
    reg [31:0] EPC_IN = 'h80808080;

    CP0 CP0_tb_inst_0(
        .CLK(CLK100MHZ),
        .RESETN(CPU_RESETN),
        .PIPELINE_READY(PIPELINE_READY),

        .INT1(INT1),
        .INT2(INT2),
        .INT3(INT3),
        .INT4(INT4),
        .INT5(INT5),
        .INT6(INT6),
        .INT7(INT7),

        .S_INT(S_INT),
        .EPC(EPC),
        .INT_ENTER(INT_ENTER),

        .REG_OUT(REG_OUT),
        .REG_IN(REG_IN),
        .REG_R(REG_R),
        .REG_WE(REG_WE),

        .S_SYSCALL(S_SYSCALL),
        .EPC_IN(EPC_IN)
    );  

    always #(`T/2) CLK100MHZ = ~CLK100MHZ;
    always @(posedge CLK100MHZ) begin
        clk_counter <= clk_counter + 1;
    end

    initial begin
        #(10*`T) CPU_RESETN = 1;
        // test write data to cp0
        write_CP0(32'hf0f0f0f0, `CP0_CAUSE);
        read_CP0(`CP0_CAUSE);
        write_CP0(32'hf0f0f0f0, `CP0_EPC);
        read_CP0(`CP0_EPC);
        write_CP0(32'hf0f0f0f0, `CP0_INT_ENTER);
        read_CP0(`CP0_INT_ENTER);

        // disable all ints
        write_CP0(32'h00000000, `CP0_CAUSE);

        // give INT1
        INT1 = 1;
        #(`T);
        INT1 = 0;
        pipeline_move();
        $stop;

        // enable ints
        write_CP0({ 16'h0000 , 8'b11111111, 2'b0, 4'b0000, 2'b00 }, `CP0_CAUSE);
        pipeline_move();
        pipeline_move();

        // enable ints
        write_CP0({ 16'h0000 , 8'b11111111, 2'b0, 4'b0000, 2'b00 }, `CP0_CAUSE);
         // give INT1
        INT1 = 1;
        #(`T);
        INT1 = 0;
        pipeline_move();
        pipeline_move();


        // enable ints
        write_CP0({ 16'h0000 , 8'b11111111, 2'b0, 4'b0000, 2'b00 }, `CP0_CAUSE);
        // give INT2 and INT3
        INT2 = 1;
        INT3 = 1;
        #(`T);
        INT2 = 0;
        INT3 = 0;
        pipeline_move();
        pipeline_move();
        // enable ints
        write_CP0({ 16'h0000 , 8'b11111111, 2'b0, 4'b0000, 2'b00 }, `CP0_CAUSE);

    end

    task write_CP0;
        input [31:0] value;
        input [4:0] index;
        begin
            @(negedge CLK100MHZ);
            REG_IN = value;
            REG_R = index;
            REG_WE = 1;
            PIPELINE_READY = 1;
            #(`T);
            REG_WE = 0;
            PIPELINE_READY = 0;
            $display("Write %x to CP0 %d", value, index);
            $stop;
        end
    endtask

    task read_CP0;
        input [4:0] index;
        begin
            @(negedge CLK100MHZ);
            REG_R = index;
            PIPELINE_READY = 1;
            #(`T);
            PIPELINE_READY = 0;
            $display("CP0 %d: %x", index, REG_OUT);
            $stop;
        end
    endtask

    task pipeline_move;
    begin
        PIPELINE_READY = 1;
        #(`T);
        PIPELINE_READY = 0;
    end
    endtask
endmodule

