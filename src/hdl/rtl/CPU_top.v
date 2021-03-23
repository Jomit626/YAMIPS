`timescale 1ns / 1ps

module CPU_top (
    input wire CLK100MHZ,
    input wire CPU_RESETN,
    input wire BTNC,
    input wire BTNU,
    input wire BTNL,
    input wire BTNR,
    input wire BTND,

    output wire[7:0] AN,
    output wire CA,
    output wire CB,
    output wire CC,
    output wire CD,
    output wire CE,
    output wire CF,
    output wire CG,
    output wire DP,

    //output[12:0] ddr2_addr,
    //output[2:0] ddr2_ba,
    //output ddr2_cas_n,
    //output[0:0] ddr2_ck_n,
    //output[0:0] ddr2_ck_p,
    //output[0:0] ddr2_cke,
    //output[0:0] ddr2_cs_n,
    //output[1:0] ddr2_dm,
    //inout[15:0] ddr2_dq,
    //inout[1:0] ddr2_dqs_n,
    //inout[1:0] ddr2_dqs_p,
    //output[0:0] ddr2_odt,
    //output ddr2_ras_n,
    //output ddr2_we_n,

    input wire UART_TXD_IN,
    output wire UART_RXD_OUT
);
    CPU_bd CPU_bd_inst_0(
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .INT1(BTNC),
        .INT2(BTNU),
        .INT3(BTNL),
        .INT4(BTNR),
        .INT5(BTND),
        .INT6(0),
        .INT7(0),

        .AN(AN),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .CP(DP),

        //.ddr2_addr(ddr2_addr),
        //.ddr2_ba(ddr2_ba),
        //.ddr2_cas_n(ddr2_cas_n),
        //.ddr2_ck_n(ddr2_ck_n),
        //.ddr2_ck_p(ddr2_ck_p),
        //.ddr2_cke(ddr2_cke),
        //.ddr2_cs_n(ddr2_cs_n),
        //.ddr2_dm(ddr2_dm),
        //.ddr2_dq(ddr2_dq),
        //.ddr2_dqs_n(ddr2_dqs_n),
        //.ddr2_dqs_p(ddr2_dqs_p),
        //.ddr2_odt(ddr2_odt),
        //.ddr2_ras_n(ddr2_ras_n),
        //.ddr2_we_n(ddr2_we_n),

        .uart_rxd(UART_TXD_IN),
        .uart_txd(UART_RXD_OUT)
    );  
endmodule