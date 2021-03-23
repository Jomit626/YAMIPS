`timescale 1ns / 1ps

module Core(
    input wire clk,
    input wire resetn,

    input wire INT1,
    input wire INT2,
    input wire INT3,
    input wire INT4,
    input wire INT5,
    input wire INT6,
    input wire INT7,

    // AXI4 Master 0 used for IF
    //output wire M00_AXI_AWID,
    //output wire [31:0] M00_AXI_AWADDR,
    //output wire [7:0] M00_AXI_AWLEN,
    //output wire [2:0] M00_AXI_AWSIZE,
    //output wire [1:0] M00_AXI_AWBURST,
    //output wire M00_AXI_AWLOCK,
    //output wire [3:0] M00_AXI_AWCACHE,
    //output wire [2:0] M00_AXI_AWPROT,
    //output wire [3:0] M00_AXI_AWQOS,
    //output wire M00_AXI_AWUSER,
    //output wire M00_AXI_AWVALID,
    //input wire M00_AXI_AWREADY,

    //output wire [31 :0] M00_AXI_WDATA,
    //output wire [3:0] M00_AXI_WSTRB,
    //output wire M00_AXI_WLAST,
    //output wire M00_AXI_WUSER,
    //output wire M00_AXI_WVALID,
    //input wire M00_AXI_WREADY,

    //input wire M00_AXI_BID,
    //input wire [1:0] M00_AXI_BRESP,
    //input wire M00_AXI_BUSER,
    //input wire M00_AXI_BVALID,
    //output wire M00_AXI_BREADY,

    //output wire M00_AXI_ARID,
    output wire [31:0] M00_AXI_ARADDR,
    output wire [7:0] M00_AXI_ARLEN,
    output wire [2:0] M00_AXI_ARSIZE,
    output wire [1 : 0] M00_AXI_ARBURST,
    //output wire M00_AXI_ARLOCK,
    //output wire [3:0] M00_AXI_ARCACHE,
    //output wire [2:0] M00_AXI_ARPROT,
    //output wire [3:0] M00_AXI_ARQOS,
    //output wire M00_AXI_ARUSER,
    output wire M00_AXI_ARVALID,
    input wire M00_AXI_ARREADY,

    //input wire M00_AXI_RID,
    input wire [31:0] M00_AXI_RDATA,
    input wire [1:0] M00_AXI_RRESP,
    input wire M00_AXI_RLAST,
    //input wire M00_AXI_RUSER,
    input wire  M00_AXI_RVALID,
    output wire M00_AXI_RREADY,

    // AXI4 Master 1 used for MEM Stage
    //output wire M01_AXI_AWID,
    output wire [31:0] M01_AXI_AWADDR,
    output wire [7:0] M01_AXI_AWLEN,
    output wire [2:0] M01_AXI_AWSIZE,
    output wire [1:0] M01_AXI_AWBURST,
    //output wire M01_AXI_AWLOCK,
    //output wire [3:0] M01_AXI_AWCACHE,
    //output wire [2:0] M01_AXI_AWPROT,
    //output wire [3:0] M01_AXI_AWQOS,
    //output wire M01_AXI_AWUSER,
    output wire M01_AXI_AWVALID,
    input wire M01_AXI_AWREADY,

    output wire [31:0] M01_AXI_WDATA,
    output wire [3:0] M01_AXI_WSTRB,
    output wire M01_AXI_WLAST,
    //output wire M01_AXI_WUSER,
    output wire M01_AXI_WVALID,
    input wire M01_AXI_WREADY,

    //input wire M01_AXI_BID,
    input wire [1:0] M01_AXI_BRESP,
    //input wire M01_AXI_BUSER,
    input wire M01_AXI_BVALID,
    output wire M01_AXI_BREADY,

    //output wire M01_AXI_ARID,
    output wire [31:0] M01_AXI_ARADDR,
    output wire [7:0] M01_AXI_ARLEN,
    output wire [2:0] M01_AXI_ARSIZE,
    output wire [1 : 0] M01_AXI_ARBURST,
    //output wire M01_AXI_ARLOCK,
    //output wire [3:0] M01_AXI_ARCACHE,
    //output wire [2:0] M01_AXI_ARPROT,
    //output wire [3:0] M01_AXI_ARQOS,
    //output wire M01_AXI_ARUSER,
    output wire M01_AXI_ARVALID,
    input wire M01_AXI_ARREADY,

    //input wire M01_AXI_RID,
    input wire [31 : 0] M01_AXI_RDATA,
    input wire [1 : 0] M01_AXI_RRESP,
    input wire M01_AXI_RLAST,
    //input wire M01_AXI_RUSER,
    input wire  M01_AXI_RVALID,
    output wire M01_AXI_RREADY
    );
    // pipecontral singals
    wire if_valid;
    wire if_ready;
    wire if_flush;

    wire id_valid;
    wire id_ready;
    wire id_flush;

    wire ex_valid;
    wire ex_ready;
    wire ex_flush;

    wire mem_valid;
    wire mem_ready;
    wire mem_flush;

    wire wb_valid;
    wire wb_ready;
    wire wb_flush;

    // wires between stages
    wire [31:0] if_id_pc;
    wire [31:0] if_id_ir;
    wire [31:0] if_id_pc_plus_4;

    wire[`BRANCH_JMP_RESULT_BUS_LENGTH - 1:0] if_id_branch_jmp_result_bus;

    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_pc_plus_8;
    
    wire [`CP0_RW_BUS_WIDTH-1:0] cp0_rw_bus;
    wire [31:0] cp0_reg_out;

    wire[`BRANCH_JMP_BUS_LENGTH-1:0] id_s_branch_jmp_bus;
    wire[`REG_INFO_BUS_LENGTH - 1:0] id_ex_s_reg_info_bus;
    wire[`ALU_CONTRAL_BUS_LENGTH - 1:0] id_ex_s_alu_contral_bus;
    wire[`REG_WRITE_BUS_LENGTH - 1:0] id_ex_s_reg_write_bus;
    wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] id_ex_s_mem_contral_bus;
    wire id_ex_s_link;

    wire[31:0] id_ex_extended_imm;
    wire[31:0] id_ex_d_rs;
    wire[31:0] id_ex_d_rt;
    wire s_syscall;

    wire[`REG_WRITE_BUS_LENGTH - 1:0] ex_mem_s_reg_write_bus;
    wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] ex_mem_s_mem_contral_bus;
    wire[`EX_RESULT_BUS_LENGTH - 1:0] ex_mem_ex_result_bus;

    wire[`REG_WRITE_RESULT_BUS_LENGTH - 1:0] mem_wb_reg_write_result_bus;

    wire [`REG_WRITE_RESULT_BUS_LENGTH - 1:0] wb_id_reg_write_result_bus;

    wire s_loaduse;
    wire s_branch_jr_ok;
    wire s_rs_fastforward;
    wire s_rs_fastforward_bj;
    wire [31:0] d_rs_fastforward;
    wire s_rt_fastforward;
    wire s_rt_fastforward_bj;
    wire [31:0] d_rt_fastforward;

    // MEM AXI-like
    wire [31:0] MEM_ARWADDR;
    wire MEM_AWVALID;
    wire MEM_AWREADY;

    wire [31:0] MEM_WDATA;
    wire MEM_WVALID;
    wire MEM_WREADY;

    wire MEM_BVALID;
    wire MEM_BREADY;

    wire MEM_ARVALID;
    wire MEM_ARREADY;

    wire [31:0] MEM_RDATA;
    wire MEM_RVALID;
    wire MEM_RREADY;
    
    // IF 
    wire [31:0] IF_ARADDR;
    wire IF_ARVALID;

    wire [31:0] IF_RDATA;
    wire IF_RVALID;

    wire [31:0] epc;
    wire [31:0] int_enter;
    wire s_eret;
    wire s_int;

    IF if_unit(
        .clk(clk),
        .rst_n(resetn),

        .PIPELINE_FLUSH(if_flush),
        .PIPELINE_VALID(if_valid),
        .PIPELINE_READY(if_ready),

        .branch_jmp_result_bus(if_id_branch_jmp_result_bus),
        .s_eret(s_eret),
        .epc(epc),
        .s_int(s_int),
        .int_enter(int_enter),

        .PC(if_id_pc),
        .IR(if_id_ir),
        .PC_PLUS_4(if_id_pc_plus_4),

        .M_ARADDR(IF_ARADDR),
        .M_ARVALID(IF_ARVALID),
        .M_RDATA(IF_RDATA),
        .M_RVALID(IF_RVALID)
    );

    ID id_unit(
        .clk(clk),
        .rst_n(resetn),

        .PIPELINE_FLUSH(id_flush),
        .PIPELINE_VALID(id_valid),
        .PIPELINE_READY(id_ready),
        
        .PC(if_id_pc),
        .IR(if_id_ir),
        .PC_PLUS_4(if_id_pc_plus_4),

        .cp0_reg_in(cp0_reg_out),
        .wb_reg_write_result_bus(wb_id_reg_write_result_bus),

        .s_rs_fastforward(s_rs_fastforward),
        .s_rs_fastforward_bj(s_rs_fastforward_bj),
        .d_rs_fastforward(d_rs_fastforward),
        .s_rt_fastforward(s_rt_fastforward),
        .s_rt_fastforward_bj(s_rt_fastforward_bj),
        .d_rt_fastforward(d_rt_fastforward),

        .cp0_rw_bus(cp0_rw_bus),
        .branch_jmp_result_bus(if_id_branch_jmp_result_bus),
        .s_branch_jmp_bus(id_s_branch_jmp_bus),
        .s_reg_info_bus(id_ex_s_reg_info_bus),
        .s_alu_contral_bus(id_ex_s_alu_contral_bus),
        .s_reg_write_bus(id_ex_s_reg_write_bus),
        .s_mem_contral_bus(id_ex_s_mem_contral_bus),
        .s_link(id_ex_s_link),

        .extended_imm(id_ex_extended_imm),
        .d_rs(id_ex_d_rs),
        .d_rt(id_ex_d_rt),

        .pc(id_ex_pc),
        .pc_plus_8(id_ex_pc_plus_8),

        .s_syscall(s_syscall),
        .s_eret(s_eret)
    );

    EX ex_unit(
        .clk(clk),
        .rst_n(resetn),

        .PIPELINE_FLUSH(ex_flush),
        .PIPELINE_VALID(ex_valid),
        .PIPELINE_READY(ex_ready),

        .pc_i(id_ex_pc),
        .pc_plus_8_i(id_ex_pc_plus_8),

        .s_link_i(id_ex_s_link),
        .s_alu_contral_bus_i(id_ex_s_alu_contral_bus),
        .s_reg_write_bus_i(id_ex_s_reg_write_bus),
        .s_mem_contral_bus_i(id_ex_s_mem_contral_bus),
        .extended_imm_i(id_ex_extended_imm),
        .d_rs_i(id_ex_d_rs),
        .d_rt_i(id_ex_d_rt),

        .s_rs_fastforward(s_rs_fastforward),
        .d_rs_fastforward(d_rs_fastforward),
        .s_rt_fastforward(s_rt_fastforward),
        .d_rt_fastforward(d_rt_fastforward),

        .s_reg_write_bus(ex_mem_s_reg_write_bus),
        .s_mem_contral_bus(ex_mem_s_mem_contral_bus),
        .ex_result_bus(ex_mem_ex_result_bus)
    );

    MEM mem_unit(
        .clk(clk),
        .rst_n(resetn),

        .PIPELINE_FLUSH(mem_flush),
        .PIPELINE_VALID(mem_valid),
        .PIPELINE_READY(mem_ready),

        .s_reg_write_bus_i(ex_mem_s_reg_write_bus),
        .s_mem_contral_bus_i(ex_mem_s_mem_contral_bus),
        .ex_result_bus_i(ex_mem_ex_result_bus),

        .reg_write_result_bus(mem_wb_reg_write_result_bus),

        .M_ARWADDR(MEM_ARWADDR),
        .M_AWVALID(MEM_AWVALID),
        .M_AWREADY(MEM_AWREADY),

        .M_WDATA(MEM_WDATA),
        .M_WVALID(MEM_WVALID),
        .M_WREADY(MEM_WREADY),

        .M_BVALID(MEM_BVALID),
        .M_BREADY(MEM_BREADY),

        .M_ARVALID(MEM_ARVALID),
        .M_ARREADY(MEM_ARREADY),

        .M_RDATA(MEM_RDATA),
        .M_RVALID(MEM_RVALID),
        .M_RREADY(MEM_RREADY)
    );

    WB wb_unit(
        .clk(clk),
        .rst_n(resetn),

        .PIPELINE_FLUSH(wb_flush),
        .PIPELINE_VALID(wb_valid),
        .PIPELINE_READY(wb_ready),

        .reg_write_result_bus_i(mem_wb_reg_write_result_bus),

        .reg_write_result_bus(wb_id_reg_write_result_bus)
    );

    pipiline_contral pip_contral_00(
        .clk(clk),
        .rst_n(resetn),

        .IF_VALID(if_valid),
        .IF_READY(if_ready),
        .IF_FLUSH(if_flush),

        .ID_VALID(id_valid),
        .ID_READY(id_ready),
        .ID_FLUSH(id_flush),

        .EX_VALID(ex_valid),
        .EX_READY(ex_ready),
        .EX_FLUSH(ex_flush),

        .MEM_VALID(mem_valid),
        .MEM_READY(mem_ready),
        .MEM_FLUSH(mem_flush),

        .WB_VALID(wb_valid),
        .WB_READY(wb_ready),
        .WB_FLUSH(wb_flush),

        .if_id_branch_jmp_result_bus(if_id_branch_jmp_result_bus),

        .S_BRANCH_JR_OK(s_branch_jr_ok),
        .S_LOADUSE(s_loaduse),

        .S_SYSCALL(s_syscall),
        .S_INT(s_int),
        .S_ERET(s_eret)
    );

    readonly_cache ro_cache_dfasdf_tb(
        .CLK(clk),
        .RES_N(resetn),

        .S_RADDR(IF_ARADDR),
        .S_RDATA(IF_RDATA),
        .S_ARVALID(IF_ARVALID),
        .S_RVALID(IF_RVALID),

        //.M_AXI_AWID(M00_AXI_AWID),
        //.M_AXI_AWADDR(M00_AXI_AWADDR),
        //.M_AXI_AWLEN(M00_AXI_AWLEN),
        //.M_AXI_AWSIZE(M00_AXI_AWSIZE),
        //.M_AXI_AWBURST(M00_AXI_AWBURST),
        //.M_AXI_AWLOCK(M00_AXI_AWLOCK),
        //.M_AXI_AWCACHE(M00_AXI_AWCACHE),
        //.M_AXI_AWPROT(M00_AXI_AWPROT),
        //.M_AXI_AWQOS(M00_AXI_AWQOS),
        //.M_AXI_AWUSER(M00_AXI_AWUSER),
        //.M_AXI_AWVALID(M00_AXI_AWVALID),
        //.M_AXI_AWREADY(M00_AXI_AWREADY),

        //.M_AXI_WDATA(M00_AXI_WDATA),
        //.M_AXI_WSTRB(M00_AXI_WSTRB),
        //.M_AXI_WLAST(M00_AXI_WLAST),
        //.M_AXI_WUSER(M00_AXI_WUSER),
        //.M_AXI_WVALID(M00_AXI_WVALID),
        //.M_AXI_WREADY(M00_AXI_WREADY),

        //.M_AXI_BID(M00_AXI_BID),
        //.M_AXI_BRESP(M00_AXI_BRESP),
        //.M_AXI_BUSER(M00_AXI_BUSER),
        //.M_AXI_BVALID(M00_AXI_BVALID),
        //.M_AXI_BREADY(M00_AXI_BREADY),

        //.M_AXI_ARID(M00_AXI_ARID),
        .M_AXI_ARADDR(M00_AXI_ARADDR),
        .M_AXI_ARLEN(M00_AXI_ARLEN),
        .M_AXI_ARSIZE(M00_AXI_ARSIZE),
        .M_AXI_ARBURST(M00_AXI_ARBURST),
        //.M_AXI_ARLOCK(M00_AXI_ARLOCK),
        //.M_AXI_ARCACHE(M00_AXI_ARCACHE),
        //.M_AXI_ARPROT(M00_AXI_ARPROT),
        //.M_AXI_ARQOS(M00_AXI_ARQOS),
        //.M_AXI_ARUSER(M00_AXI_ARUSER),
        .M_AXI_ARVALID(M00_AXI_ARVALID),
        .M_AXI_ARREADY(M00_AXI_ARREADY),

        //.M_AXI_RID(M00_AXI_RID),
        .M_AXI_RDATA(M00_AXI_RDATA),
        .M_AXI_RRESP(M00_AXI_RRESP),
        .M_AXI_RLAST(M00_AXI_RLAST),
        //.M_AXI_RUSER(M00_AXI_RUSER),
        .M_AXI_RVALID(M00_AXI_RVALID),
        .M_AXI_RREADY(M00_AXI_RREADY)
    );

    MEM_to_AXI_Bridge mem_axi4_bridge(
        .S_ARWADDR(MEM_ARWADDR),
        .S_AWVALID(MEM_AWVALID),
        .S_AWREADY(MEM_AWREADY),

        .S_WDATA(MEM_WDATA),
        .S_WVALID(MEM_WVALID),
        .S_WREADY(MEM_WREADY),

        .S_BVALID(MEM_BVALID),
        .S_BREADY(MEM_BREADY),

        .S_ARVALID(MEM_ARVALID),
        .S_ARREADY(MEM_ARREADY),

        .S_RDATA(MEM_RDATA),
        .S_RVALID(MEM_RVALID),
        .S_RREADY(MEM_RREADY),

        //.M_AXI_AWID(M01_AXI_AWID),
        .M_AXI_AWADDR(M01_AXI_AWADDR),
        .M_AXI_AWLEN(M01_AXI_AWLEN),
        .M_AXI_AWSIZE(M01_AXI_AWSIZE),
        .M_AXI_AWBURST(M01_AXI_AWBURST),
        //.M_AXI_AWLOCK(M01_AXI_AWLOCK),
        //.M_AXI_AWCACHE(M01_AXI_AWCACHE),
        //.M_AXI_AWPROT(M01_AXI_AWPROT),
        //.M_AXI_AWQOS(M01_AXI_AWQOS),
        //.M_AXI_AWUSER(M01_AXI_AWUSER),
        .M_AXI_AWVALID(M01_AXI_AWVALID),
        .M_AXI_AWREADY(M01_AXI_AWREADY),

        .M_AXI_WDATA(M01_AXI_WDATA),
        .M_AXI_WSTRB(M01_AXI_WSTRB),
        .M_AXI_WLAST(M01_AXI_WLAST),
        //.M_AXI_WUSER(M01_AXI_WUSER),
        .M_AXI_WVALID(M01_AXI_WVALID),
        .M_AXI_WREADY(M01_AXI_WREADY),

        //.M_AXI_BID(M01_AXI_BID),
        .M_AXI_BRESP(M01_AXI_BRESP),
        //.M_AXI_BUSER(M01_AXI_BUSER),
        .M_AXI_BVALID(M01_AXI_BVALID),
        .M_AXI_BREADY(M01_AXI_BREADY),

        //.M_AXI_ARID(M01_AXI_ARID),
        .M_AXI_ARADDR(M01_AXI_ARADDR),
        .M_AXI_ARLEN(M01_AXI_ARLEN),
        .M_AXI_ARSIZE(M01_AXI_ARSIZE),
        .M_AXI_ARBURST(M01_AXI_ARBURST),
        //.M_AXI_ARLOCK(M01_AXI_ARLOCK),
        //.M_AXI_ARCACHE(M01_AXI_ARCACHE),
        //.M_AXI_ARPROT(M01_AXI_ARPROT),
        //.M_AXI_ARQOS(M01_AXI_ARQOS),
        //.M_AXI_ARUSER(M01_AXI_ARUSER),
        .M_AXI_ARVALID(M01_AXI_ARVALID),
        .M_AXI_ARREADY(M01_AXI_ARREADY),

        //.M_AXI_RID(M01_AXI_RID),
        .M_AXI_RDATA(M01_AXI_RDATA),
        .M_AXI_RRESP(M01_AXI_RRESP),
        .M_AXI_RLAST(M01_AXI_RLAST),
        //.M_AXI_RUSER(M01_AXI_RUSER),
        .M_AXI_RVALID(M01_AXI_RVALID),
        .M_AXI_RREADY(M01_AXI_RREADY)
    );

    CP0 CP0_inst_0(
        .CLK(clk),
        .RESETN(resetn),
        .PIPELINE_READY(id_ready),

        .INT1(INT1),
        .INT2(INT2),
        .INT3(INT3),
        .INT4(INT4),
        .INT5(INT5),
        .INT6(INT6),
        .INT7(INT7),

        .S_INT(s_int),
        .EPC(epc),
        .INT_ENTER(int_enter),

        .REG_OUT(cp0_reg_out),
        .REG_IN(cp0_rw_bus[`BUS_DECODE_CP0_REG_DATA]),
        .REG_R(cp0_rw_bus[`BUS_DECODE_CP0_REG]),
        .REG_WE(cp0_rw_bus[`BUS_DECODE_CP0_REG_W]),

        .S_SYSCALL(s_syscall),
        .EPC_IN(id_ex_pc)
    );

    fastforward fastforward_unit_inst_0(
        .clk(clk),
        .reset_n(resetn),
        .PIPELINE_READY(ex_ready),
        .id_s_reg_info_bus(id_ex_s_reg_info_bus),
        .s_branch_jmp_bus(id_s_branch_jmp_bus),

        .ex_reg_write_bus(ex_mem_s_reg_write_bus),
        .ex_result_bus(ex_mem_ex_result_bus),
        .ex_s_mem_contral_bus(ex_mem_s_mem_contral_bus),

        .mem_reg_write_result_bus(mem_wb_reg_write_result_bus),

        .s_branch_jr_ok(s_branch_jr_ok),
        .s_loaduse(s_loaduse),
        .s_rs_fastforward(s_rs_fastforward),
        .s_rs_fastforward_bj(s_rs_fastforward_bj),
        .d_rs_fastforward(d_rs_fastforward),
        .s_rt_fastforward(s_rt_fastforward),
        .s_rt_fastforward_bj(s_rt_fastforward_bj),
        .d_rt_fastforward(d_rt_fastforward)
    );
endmodule
