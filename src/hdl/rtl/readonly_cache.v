`timescale 1ns / 1ps

module readonly_cache #(
    parameter integer C_DATA_WIDTH = 32,
    parameter integer C_ADDRESS_WIDTH = 32,

    parameter integer C_CACHE_LINE_CNT = 8,
    parameter integer C_CACHE_LINE_WIDTH = 512,
    parameter integer C_CACHE_SET_CNT = 2,

    parameter integer C_CACHE_LRU_COUNTER_WIDTH = 8
    )
    (
    input wire CLK,
    input wire RES_N,

    // valid ready cache access channel
    input wire [C_ADDRESS_WIDTH-1:0] S_RADDR,
    output wire[C_DATA_WIDTH-1:0] S_RDATA,
    input wire S_ARVALID,
    output wire S_RVALID,

    // Memory access request
    // AXI4 Master 
    //output wire M_AXI_AWID,
    //output wire [31:0] M_AXI_AWADDR,
    //output wire [7:0] M_AXI_AWLEN,
    //output wire [2:0] M_AXI_AWSIZE,
    //output wire [1:0] M_AXI_AWBURST,
    //output wire M_AXI_AWLOCK,
    //output wire [3:0] M_AXI_AWCACHE,
    //output wire [2:0] M_AXI_AWPROT,
    //output wire [3:0] M_AXI_AWQOS,
    //output wire M_AXI_AWUSER,
    //output wire M_AXI_AWVALID,
    //input wire M_AXI_AWREADY,

    //output wire [31 :0] M_AXI_WDATA,
    //output wire [3:0] M_AXI_WSTRB,
    //output wire M_AXI_WLAST,
    //output wire M_AXI_WUSER,
    //output wire M_AXI_WVALID,
    //input wire M_AXI_WREADY,

    //input wire M_AXI_BID,
    //input wire [1:0] M_AXI_BRESP,
    //input wire M_AXI_BUSER,
    //input wire M_AXI_BVALID,
    //output wire M_AXI_BREADY,

    //output wire M_AXI_ARID,
    output wire [31:0] M_AXI_ARADDR,
    output wire [7:0] M_AXI_ARLEN,
    output wire [2:0] M_AXI_ARSIZE,
    output wire [1 : 0] M_AXI_ARBURST,
    //output wire M_AXI_ARLOCK,
    //output wire [3:0] M_AXI_ARCACHE,
    //output wire [2:0] M_AXI_ARPROT,
    //output wire [3:0] M_AXI_ARQOS,
    //output wire M_AXI_ARUSER,
    output wire M_AXI_ARVALID,
    input wire M_AXI_ARREADY,

    //input wire M_AXI_RID,
    input wire [31:0] M_AXI_RDATA,
    input wire [1:0] M_AXI_RRESP,
    input wire M_AXI_RLAST,
    //input wire M_AXI_RUSER,
    input wire  M_AXI_RVALID,
    output wire M_AXI_RREADY
    );

    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
        bit_depth = bit_depth >> 1;                                 
    end                

    endfunction
    wire [C_ADDRESS_WIDTH-1:0] INTER_M_ARADDR;
    wire INTER_M_ARVALID;
    wire INTER_M_ARREADY;

    wire [C_DATA_WIDTH-1:0] INTER_M_RDATA;
    wire INTER_M_RVALID;
    wire INTER_M_RLAST;
    wire INTER_M_RREADY;

    readonly_cache_inst #(
        .C_DATA_WIDTH(C_DATA_WIDTH),
        .C_ADDRESS_WIDTH(C_ADDRESS_WIDTH),

        .C_CACHE_LINE_CNT (C_CACHE_LINE_CNT ),
        .C_CACHE_LINE_WIDTH(C_CACHE_LINE_WIDTH),
        .C_CACHE_SET_CNT(C_CACHE_SET_CNT),

        .C_CACHE_LRU_COUNTER_WIDTH(C_CACHE_LRU_COUNTER_WIDTH)
    ) cache_inst_0 (
        .CLK(CLK),
        .RES_N(RES_N),
        .S_RADDR(S_RADDR),
        .S_ARVALID(S_ARVALID),
        .S_RDATA(S_RDATA),
        .S_RVALID(S_RVALID),

        .M_ARADDR(INTER_M_ARADDR),
        .M_ARVALID(INTER_M_ARVALID),
        .M_ARREADY(INTER_M_ARREADY),
        .M_RDATA(INTER_M_RDATA),
        .M_RVALID(INTER_M_RVALID),
        .M_RLAST(INTER_M_RLAST),
        .M_RREADY(INTER_M_RREADY)
    );

    readonly_cache_AXI4_bridge  #(
        .M_AXI_ADDR_WIDTH(C_ADDRESS_WIDTH),
        .M_AXI_DATA_WIDTH(C_DATA_WIDTH),
        .M_AXI_BURST_LEN(C_CACHE_LINE_WIDTH / C_DATA_WIDTH - 1),
        .M_AXI_BURST_SIZE(clogb2(C_DATA_WIDTH /8 - 1))
    ) cache_bridge_i__ins_0 (
        .S_ARADDR(INTER_M_ARADDR),
        .S_ARVALID(INTER_M_ARVALID),
        .S_ARREADY(INTER_M_ARREADY),
        .S_RDATA(INTER_M_RDATA),
        .S_RVALID(INTER_M_RVALID),
        .S_RLAST(INTER_M_RLAST),
        .S_RREADY(INTER_M_RREADY),

        //.M_AXI_AWID(M_AXI_AWID),
        //.M_AXI_AWADDR(M_AXI_AWADDR),
        //.M_AXI_AWLEN(M_AXI_AWLEN),
        //.M_AXI_AWSIZE(M_AXI_AWSIZE),
        //.M_AXI_AWBURST(M_AXI_AWBURST),
        //.M_AXI_AWLOCK(M_AXI_AWLOCK),
        //.M_AXI_AWCACHE(M_AXI_AWCACHE),
        //.M_AXI_AWPROT(M_AXI_AWPROT),
        //.M_AXI_AWQOS(M_AXI_AWQOS),
        //.M_AXI_AWUSER(M_AXI_AWUSER),
        //.M_AXI_AWVALID(M_AXI_AWVALID),
        //.M_AXI_AWREADY(M_AXI_AWREADY),

        //.M_AXI_WDATA(M_AXI_WDATA),
        //.M_AXI_WSTRB(M_AXI_WSTRB),
        //.M_AXI_WLAST(M_AXI_WLAST),
        //.M_AXI_WUSER(M_AXI_WUSER),
        //.M_AXI_WVALID(M_AXI_WVALID),
        //.M_AXI_WREADY(M_AXI_WREADY),

        //.M_AXI_BID(M_AXI_BID),
        //.M_AXI_BRESP(M_AXI_BRESP),
        //.M_AXI_BUSER(M_AXI_BUSER),
        //.M_AXI_BVALID(M_AXI_BVALID),
        //.M_AXI_BREADY(M_AXI_BREADY),

        //.M_AXI_ARID(M_AXI_ARID),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARLEN(M_AXI_ARLEN),
        .M_AXI_ARSIZE(M_AXI_ARSIZE),
        .M_AXI_ARBURST(M_AXI_ARBURST),
        //.M_AXI_ARLOCK(M_AXI_ARLOCK),
        //.M_AXI_ARCACHE(M_AXI_ARCACHE),
        //.M_AXI_ARPROT(M_AXI_ARPROT),
        //.M_AXI_ARQOS(M_AXI_ARQOS),
        //.M_AXI_ARUSER(M_AXI_ARUSER),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),

        //.M_AXI_RID(M_AXI_RID),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RLAST(M_AXI_RLAST),
        //.M_AXI_RUSER(M_AXI_RUSER),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
    );
endmodule
