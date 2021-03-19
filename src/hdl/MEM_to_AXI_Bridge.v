`timescale 1ns / 1ps

module MEM_to_AXI_Bridge#(
    parameter  integer M_AXI_ADDR_WIDTH = 32,
    parameter  integer M_AXI_DATA_WIDTH = 32,
    
    // Thread ID Width
    parameter integer M_AXI_ID_WIDTH        = 1,
    // Width of User Write Address Bus
    parameter integer M_AXI_AWUSER_WIDTH    = 0,
    // Width of User Read Address Bus
    parameter integer M_AXI_ARUSER_WIDTH    = 0,
    // Width of User Write Data Bus
    parameter integer M_AXI_WUSER_WIDTH     = 0,
    // Width of User Read Data Bus
    parameter integer M_AXI_RUSER_WIDTH     = 0,
    // Width of User Response Bus
    parameter integer M_AXI_BUSER_WIDTH     = 0
)
(
    // MEM singals
    input wire [31:0] S_ARWADDR,
    input wire S_AWVALID,
    output wire S_AWREADY,

    input wire [31:0] S_WDATA,
    input wire S_WVALID,
    output wire S_WREADY,

    output wire S_BVALID,
    input wire S_BREADY,

    input wire S_ARVALID,
    output wire S_ARREADY,

    output wire [31:0] S_RDATA,
    output wire S_RVALID,
    input wire S_RREADY,

    // --------------------
    // AXI 4 
    // --------------------

    // --------------------
    // Write Address Channel
    // --------------------
    // Master Interface Write Address ID
    // AXI Interconnet appends its value
    output wire [M_AXI_ID_WIDTH-1:0] M_AXI_AWID,
    // Master Interface Write Address
    output wire [M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
    // Burst length.
    // Burst len = AWLEN[7:0] + 1
    output wire [7:0] M_AXI_AWLEN,
    // Burst size.
    // Bytes in transfer = 1 << AxSize[2:0]
    output wire [2:0] M_AXI_AWSIZE,
    // Burst type. 
    output wire [1:0] M_AXI_AWBURST,
    // Lock type
    // Exclusive access support not implemented in endpoint Xilinx IP.
    output wire M_AXI_AWLOCK,
    // Memory type
    // Xilinx IP generally ignores (as slaves)
    output wire [3:0] M_AXI_AWCACHE,
    // Protection type.
    // Xilinx IP generally ignores (as slaves)
    output wire [2:0] M_AXI_AWPROT,
    // QoS
    // Not implemented in Xilinx Endpoint IP.
    output wire [3:0] M_AXI_AWQOS,
    // Optional User-defined signal in the write address channel.
    output wire [M_AXI_AWUSER_WIDTH-1:0] M_AXI_AWUSER,
    // Write address valid
    output wire M_AXI_AWVALID,
    // Write address ready
    input wire M_AXI_AWREADY,

    // --------------------
    // Write Data Channel
    // --------------------
    // Master Interface Write Data.
    output wire [M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
    // Write strobes.
    output wire [M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
    // Write last. This signal indicates the last transfer in a write burst.
    output wire M_AXI_WLAST,
    // Optional User-defined signal in the write channel.
    output wire [M_AXI_WUSER_WIDTH-1:0] M_AXI_WUSER,
    // Write valid.
    output wire M_AXI_WVALID,
    // Write ready.
    input wire M_AXI_WREADY,

    // --------------------
    // Write Response Channel
    // --------------------
    // Master Interface Write Response.
    input wire M_AXI_BID,
    // Write response.
    input wire [1:0] M_AXI_BRESP,
    // Optional User-defined signal in the write response channel
    input wire [M_AXI_BUSER_WIDTH-1:0] M_AXI_BUSER,
    // Write response valid.
    input wire M_AXI_BVALID,
    // Response ready.
    output wire M_AXI_BREADY,

    // --------------------
    // Read Address Channel
    // --------------------
    // Master Interface Read Address ID
    // AXI Interconnet appends its value
    output wire [M_AXI_ID_WIDTH-1:0] M_AXI_ARID,
    // Master Interface Read Address
    output wire [M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
    // Burst length.
    output wire [7:0] M_AXI_ARLEN,
    // Burst size.
    // Bytes in transfer = 1 << AxSize[2:0]
    output wire [2:0] M_AXI_ARSIZE,
    // Burst type.
    output wire [1 : 0] M_AXI_ARBURST,
    // Lock type
    // Exclusive access support not implemented in endpoint Xilinx IP.
    output wire M_AXI_ARLOCK,
    // Memory type
    // Xilinx IP generally ignores (as slaves)
    output wire [3:0] M_AXI_ARCACHE,
    // Protection type.
    // Xilinx IP generally ignores (as slaves)
    output wire [2:0] M_AXI_ARPROT,
    // QoS
    // Not implemented in Xilinx Endpoint IP.
    output wire [3:0] M_AXI_ARQOS,
    // Optional User-defined signal in the write address channel.
    output wire [M_AXI_ARUSER_WIDTH-1:0] M_AXI_ARUSER,
    // Write address valid
    output wire M_AXI_ARVALID,
    // Write address ready
    input wire M_AXI_ARREADY,

    // --------------------
    // Read Address Channel
    // --------------------
    // Read ID tag.
    input wire M_AXI_RID,
    // Master Read Data
    input wire [M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
    // Read response. 
    input wire [1 : 0] M_AXI_RRESP,
    // Read last. 
    input wire M_AXI_RLAST,
    // Optional User-defined signal in the read address channel.
    input wire [M_AXI_RUSER_WIDTH-1:0] M_AXI_RUSER,
    // Read valid. 
    input wire  M_AXI_RVALID,
    // Read ready. 
    output wire  M_AXI_RREADY
    );

    // I/O Connections assignments

    // To AXI
    // AXI Write Address
    assign M_AXI_AWID       = 'b1;
    assign M_AXI_AWADDR     = S_ARWADDR;
    assign M_AXI_AWLEN      = 'd0;  // length = 1
    assign M_AXI_AWSIZE     = 'd2;  // size = 32
    assign M_AXI_AWBURST    = 2'b00;// fixed
    assign M_AXI_AWLOCK     = 1'b0;
    assign M_AXI_AWCACHE    = 4'b0010;
    assign M_AXI_AWPROT     = 3'h0;
    assign M_AXI_AWQOS      = 4'h0;
    assign M_AXI_AWUSER     = 'b0;
    assign M_AXI_AWVALID    = S_AWVALID;
    // AXI Write Data
    assign M_AXI_WDATA      = S_WDATA;
    assign M_AXI_WSTRB      = {(M_AXI_DATA_WIDTH/8){1'b1}};
    assign M_AXI_WLAST      = 'b1;  // always last 
    assign M_AXI_WUSER      = 'b0;
    assign M_AXI_WVALID     = S_WVALID;
    // AXI Write Response
    assign M_AXI_BREADY     = S_BREADY;  // never use

    // AXI Read Address
    assign M_AXI_ARID       = 'b1;
    assign M_AXI_ARADDR     = S_ARWADDR;
    assign M_AXI_ARLEN      = 'd0;  // length = 1
    assign M_AXI_ARSIZE     = 'd2;  // size = 32
    assign M_AXI_ARBURST    = 2'b00;// fixed type
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0010;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b0;
    assign M_AXI_ARVALID    = S_ARVALID;

    // AXI Read Response
    assign M_AXI_RREADY = S_RREADY;

    // To MEM
    assign S_AWREADY = M_AXI_AWREADY;
    assign S_WREADY = M_AXI_WREADY;

    assign S_BVALID = M_AXI_BVALID;

    assign S_ARREADY = M_AXI_ARREADY;
    assign S_RDATA = M_AXI_RDATA;
    assign S_RVALID = M_AXI_RVALID;
endmodule
