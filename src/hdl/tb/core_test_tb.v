`timescale 1ns / 1ns

module core_test_tb (
);
    localparam T = 10;

    reg [31:0] clk_counter = 0;
    reg CLK100MHZ = 0;
    reg CPU_RESETN = 0;

    core_test_bd core_test_bd_inst_tb_0(
        .clk_in(CLK100MHZ),
        .resetn(CPU_RESETN),

        .BTNU(0),
        .BTNL(0),
        .BTNR(0),
        .BTND(0),
        .BTNC(0),

        .INT6(0),
        .INT7(0)
    );  

    always #(T/2) CLK100MHZ = ~CLK100MHZ;
    always @(posedge CLK100MHZ) begin
        clk_counter <= clk_counter + 1;
    end

    initial begin
        #(20*T) CPU_RESETN = 1;

        $stop;
    end
endmodule

