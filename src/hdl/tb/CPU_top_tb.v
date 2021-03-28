`timescale 1ns / 1ns

`define  UART_BPS_DELAY_NS 1_000_000_000 / 9600

module CPU_top_tb (
);
    localparam T = 10;

    reg [31:0] clk_counter = 0;
    reg CLK100MHZ = 0;
    reg CPU_RESETN = 0;
    reg INT1 = 0;
    reg INT2 = 0;
    reg INT3 = 0;
    reg INT4 = 0;
    reg INT5 = 0;
    reg INT6 = 0;
    reg INT7 = 0;

    wire[7:0] AN;
    wire CA;
    wire CB;
    wire CC;
    wire CD;
    wire CE;
    wire CF;
    wire CG;
    wire DP;

    wire [12:0] ddr2_addr;
    wire [2:0] ddr2_ba;
    wire  ddr2_cas_n;
    wire [0:0] ddr2_ck_n;
    wire [0:0] ddr2_ck_p;
    wire [0:0] ddr2_cke;
    wire [0:0] ddr2_cs_n;
    wire [1:0] ddr2_dm;
    wire [15:0] ddr2_dq;
    wire [1:0] ddr2_dqs_n;
    wire [1:0] ddr2_dqs_p;
    wire [0:0] ddr2_odt;
    wire  ddr2_ras_n;
    wire  ddr2_we_n;

    wire[3:0] VGA_R;
    wire[3:0] VGA_G;
    wire[3:0] VGA_B;

    wire VGA_HS;
    wire VGA_VS;

    reg UART_TXD_IN;
    wire UART_RXD_OUT;

    
    ddr2_model ddr2_model_tb_inst_0(
        .ck(ddr2_ck_p),
        .ck_n(ddr2_ck_n),
        .cke(ddr2_cke),
        .cs_n(ddr2_cs_n),
        .ras_n(ddr2_ras_n),
        .cas_n(ddr2_cas_n),
        .we_n(ddr2_we_n),
        .dm_rdqs(ddr2_dm),
        .ba(ddr2_ba),
        .addr(ddr2_addr),
        .dq(ddr2_dq),
        .dqs(ddr2_dqs_p),
        .dqs_n(ddr2_dqs_n),
        .rdqs_n(),
        .odt(ddr2_odt)
    );

    CPU_top CPU_top_tb_inst_0(
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .BTNC(INT1),
        .BTNU(INT2),
        .BTNL(INT3),
        .BTNR(INT4),
        .BTND(INT5),

        .AN(AN),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),

        .ddr2_addr(ddr2_addr),
        .ddr2_ba(ddr2_ba),
        .ddr2_cas_n(ddr2_cas_n),
        .ddr2_ck_n(ddr2_ck_n),
        .ddr2_ck_p(ddr2_ck_p),
        .ddr2_cke(ddr2_cke),
        .ddr2_ras_n(ddr2_ras_n),
        .ddr2_we_n(ddr2_we_n),
        .ddr2_dq(ddr2_dq),
        .ddr2_dqs_n(ddr2_dqs_n),
        .ddr2_dqs_p(ddr2_dqs_p),
        .ddr2_cs_n(ddr2_cs_n),
        .ddr2_dm(ddr2_dm),
        .ddr2_odt(ddr2_odt),

        .VGA_R(),
        .VGA_G(),
        .VGA_B(),

        .VGA_HS(),
        .VGA_VS(),

        .UART_TXD_IN(UART_TXD_IN),
        .UART_RXD_OUT(UART_RXD_OUT)
    );  

    always #(T/2) CLK100MHZ = ~CLK100MHZ;
    always @(posedge CLK100MHZ) begin
        clk_counter <= clk_counter + 1;
    end

    initial begin
        //#200000000;
        UART_TXD_IN = 1;
        #(10*T) CPU_RESETN = 1;

        $stop;
    end

    // Uart reciver
    reg [7:0] uart_data;
    always @(negedge UART_RXD_OUT) begin
        #(`UART_BPS_DELAY_NS);
        #(`UART_BPS_DELAY_NS/2);
        uart_data[0] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[1] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[2] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[3] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[4] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[5] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[6] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS);
        uart_data[7] = UART_RXD_OUT;
        #(`UART_BPS_DELAY_NS/2);
        $display("UART From FPGA %x", uart_data);
        #(`UART_BPS_DELAY_NS);
    end

    task uart_sent_byte;
        input [7:0] byte;
        begin
            UART_TXD_IN = 0;
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[0];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[1];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[2];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[3];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[4];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[5];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[6];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = byte[7];
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = 0;
            #(`UART_BPS_DELAY_NS);
            UART_TXD_IN = 1;
            #(`UART_BPS_DELAY_NS);
        end 
    endtask
endmodule

