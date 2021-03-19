`timescale 1ns / 1ps

`include "config.v"

module MEM(
    input wire clk,
    input wire rst_n,

    input wire PIPELINE_FLUSH,
    input wire PIPELINE_READY,
    output wire PIPELINE_VALID,

    input wire [`REG_WRITE_BUS_LENGTH - 1:0] s_reg_write_bus_i,
    input wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] s_mem_contral_bus_i,
    input wire [`EX_RESULT_BUS_LENGTH - 1:0] ex_result_bus_i,

    output wire [`REG_WRITE_RESULT_BUS_LENGTH - 1:0] reg_write_result_bus,

    output wire [31:0] M_ARWADDR,
    output wire M_AWVALID,
    input wire M_AWREADY,

    output wire [31:0] M_WDATA,
    output wire M_WVALID,
    input wire M_WREADY,

    input wire M_BVALID,
    output wire M_BREADY,

    output wire M_ARVALID,
    input wire M_ARREADY,

    input wire [31:0] M_RDATA,
    input wire M_RVALID,
    output wire M_RREADY
    );
    wire s_mem_read_i  = s_mem_contral_bus_i[`BUS_DECODE_MEM_READ];
    wire s_mem_write_i = s_mem_contral_bus_i[`BUS_DECODE_MEM_READ];

    reg [`REG_WRITE_BUS_LENGTH - 1:0] s_reg_write_bus;
    reg [`MEM_CONTRAL_BUS_LENGTH - 1:0] s_mem_contral_bus;
    reg [`EX_RESULT_BUS_LENGTH - 1:0] ex_result_bus;

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            s_reg_write_bus <= 'd0;
        else if(PIPELINE_READY)
            s_reg_write_bus <= s_reg_write_bus_i;
    end

    always @(posedge clk) begin
        if(~rst_n || (PIPELINE_READY && PIPELINE_FLUSH))
            s_mem_contral_bus <= 'd0;
        else if(PIPELINE_READY)
            s_mem_contral_bus <= s_mem_contral_bus_i;
    end

    always @(posedge clk) begin
        if(PIPELINE_READY)
            ex_result_bus <= ex_result_bus_i;
    end

    wire s_mem_read = s_mem_contral_bus[`BUS_DECODE_MEM_READ];   
    wire s_mem_write = s_mem_contral_bus[`BUS_DECODE_MEM_WIRTE];
    wire s_mem_half = s_mem_contral_bus[`BUS_DECODE_MEM_HALF];

    // decode singals
    wire [31:0] mem_rw_address = ex_result_bus[`BUS_DECODE_EX_RESULT];
    wire [31:0] mem_w_data = ex_result_bus[`BUS_DECODE_RT_BYPASS];  

    wire mem_half_sel = mem_rw_address[1];
    //wire [31:0] mem_r_half_res = 
    //    mem_half_sel ? { {16 { M_RDATA[31] }}, M_RDATA[31:16] } :
    //    { {16 { M_RDATA[15] }}, M_RDATA[15:0] } ;

    wire [31:0] mem_r_half_res = 
            ({32{mem_half_sel}} & { {16 { M_RDATA[31] }}, M_RDATA[31:16] } )
        |   ({32{~mem_half_sel}} & { {16 { M_RDATA[15] }}, M_RDATA[15:0] } );
    
    wire [31:0] mem_r_result = 
        s_mem_half ? mem_r_half_res :
        M_RDATA;
    
    // interal singals
    wire start_write;
    reg write_actived;
    wire write_finish;
    reg awvalid;
    reg wvalid;

    wire start_read;
    reg read_actived;
    wire read_finish;
    reg arvalid;

    // I/O assign ment
    assign reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE] = s_reg_write_bus[`BUS_DECODE_REG_WRITE];
    assign reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE_DST] = s_reg_write_bus[`BUS_DECODE_REG_WRITE_DST];
    assign reg_write_result_bus[`BUS_DECODE_RESULT_REG_WRITE_DATA] =    ({32{s_mem_read}} & mem_r_result)
                                                                    |   ({32{~s_mem_read}} &  ex_result_bus[`BUS_DECODE_EX_RESULT]);

    assign PIPELINE_VALID = write_finish || read_finish || (~s_mem_read && ~s_mem_write);

    assign M_ARWADDR = { mem_rw_address[31:2], 2'b0 };
    assign M_AWVALID = awvalid;
    assign M_WDATA = mem_w_data;
    assign M_WVALID = wvalid;
    assign M_BREADY = PIPELINE_READY;
    assign M_ARVALID = arvalid;
    assign M_RREADY = PIPELINE_READY;
    

    assign start_write = ~write_actived & s_mem_write;
    assign write_finish = write_actived & M_BVALID;
    always @(posedge clk) begin
        if(!rst_n)
            write_actived <= 'b0;
        else if(start_write)
            write_actived <= 'b1;
        else if(M_BREADY && M_BVALID)
            write_actived <= 'b0;
        else
            write_actived <= write_actived;
    end

    always @(posedge clk) begin
        if(!rst_n)
            awvalid <= 'b0;
        else if(start_write)
            awvalid <= 'b1;
        else if(awvalid && M_AWREADY)
            awvalid <= 'b0;
        else
            awvalid <= awvalid;
    end

    always @(posedge clk) begin
        if(!rst_n)
            wvalid <= 'b0;
        else if(start_write)
            wvalid <= 'b1;
        else if(wvalid && M_WREADY)
            wvalid <= 'b0;
        else
            wvalid <= wvalid;
    end

    assign start_read = ~read_actived & s_mem_read;
    assign read_finish = read_actived & M_RVALID;
    always @(posedge clk) begin
        if(!rst_n)
            read_actived <= 'b0;
        else if(start_read)
            read_actived <= 'b1;
        else if(M_RVALID && M_RREADY)
            read_actived <= 'b0;
        else
            read_actived <= read_actived;
    end

    always @(posedge clk) begin
        if(!rst_n)
            arvalid <= 'b0;
        else if(start_read)
            arvalid <= 'b1;
        else if(arvalid && M_ARREADY)
            arvalid <= 'b0;
        else
            arvalid <= arvalid;
    end
endmodule
