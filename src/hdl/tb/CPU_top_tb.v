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

    
    reg UART_TXD_IN;
    wire UART_RXD_OUT;

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

        .UART_TXD_IN(UART_TXD_IN),
        .UART_RXD_OUT(UART_RXD_OUT)
    );  

    always #(T/2) CLK100MHZ = ~CLK100MHZ;
    always @(posedge CLK100MHZ) begin
        clk_counter <= clk_counter + 1;
    end

    initial begin
        UART_TXD_IN = 1;
        #(10*T) CPU_RESETN = 1;

        #(2000*T) program();
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
    task program;
    begin
    uart_sent_byte( 8'hf0 );
    uart_sent_byte( 8'hf0 );
    uart_sent_byte( 8'hf0 );
    uart_sent_byte( 8'hf0 );
    uart_sent_byte( 8'hc2 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h18 );
    uart_sent_byte( 8'h27 );
    uart_sent_byte( 8'hbd );
    uart_sent_byte( 8'hff );
    uart_sent_byte( 8'hf0 );
    uart_sent_byte( 8'haf );
    uart_sent_byte( 8'hbe );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'hc );
    uart_sent_byte( 8'haf );
    uart_sent_byte( 8'hb1 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h8 );
    uart_sent_byte( 8'haf );
    uart_sent_byte( 8'hb0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h4 );
    uart_sent_byte( 8'h3 );
    uart_sent_byte( 8'ha0 );
    uart_sent_byte( 8'hf0 );
    uart_sent_byte( 8'h25 );
    uart_sent_byte( 8'h24 );
    uart_sent_byte( 8'h11 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h4 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h80 );
    uart_sent_byte( 8'h25 );
    uart_sent_byte( 8'h10 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h3 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'hae );
    uart_sent_byte( 8'h30 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h26 );
    uart_sent_byte( 8'h10 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h1 );
    uart_sent_byte( 8'h3c );
    uart_sent_byte( 8'h2 );
    uart_sent_byte( 8'h2 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h2 );
    uart_sent_byte( 8'h2 );
    uart_sent_byte( 8'h10 );
    uart_sent_byte( 8'h2b );
    uart_sent_byte( 8'h14 );
    uart_sent_byte( 8'h40 );
    uart_sent_byte( 8'hff );
    uart_sent_byte( 8'hfb );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h3 );
    uart_sent_byte( 8'hc0 );
    uart_sent_byte( 8'he8 );
    uart_sent_byte( 8'h25 );
    uart_sent_byte( 8'h8f );
    uart_sent_byte( 8'hbe );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'hc );
    uart_sent_byte( 8'h8f );
    uart_sent_byte( 8'hb1 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h8 );
    uart_sent_byte( 8'h8f );
    uart_sent_byte( 8'hb0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h4 );
    uart_sent_byte( 8'h27 );
    uart_sent_byte( 8'hbd );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h10 );
    uart_sent_byte( 8'h3 );
    uart_sent_byte( 8'he0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h8 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );

    uart_sent_byte( 8'hf );
    uart_sent_byte( 8'hf );
    uart_sent_byte( 8'hf );
    uart_sent_byte( 8'hf );
    uart_sent_byte( 8'hc2 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    uart_sent_byte( 8'h0 );
    end
    endtask
endmodule

