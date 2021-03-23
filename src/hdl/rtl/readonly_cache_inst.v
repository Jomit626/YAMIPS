`timescale 1ns / 1ps

module readonly_cache_inst #(
    parameter integer C_DATA_WIDTH = 32,
    parameter integer C_ADDRESS_WIDTH = 32,

    parameter integer C_CACHE_LINE_CNT = 8,
    parameter integer C_CACHE_LINE_WIDTH = 128,
    parameter integer C_CACHE_SET_CNT = 2,

    parameter integer C_CACHE_LRU_COUNTER_WIDTH = 16
    )
    (
    input wire CLK,
    input wire RES_N,

    input wire [C_ADDRESS_WIDTH-1:0] S_RADDR,
    input wire S_ARVALID,

    output wire[C_DATA_WIDTH-1:0] S_RDATA,
    output wire S_RVALID,

    // Memory access request
    // AXI4 read address channel
    output wire [C_ADDRESS_WIDTH-1:0] M_ARADDR,
    output wire M_ARVALID,
    input wire M_ARREADY,
    // AXI4 read response channel
    input wire [C_DATA_WIDTH-1:0] M_RDATA,
    input wire M_RVALID,
    input wire M_RLAST,
    output wire M_RREADY
    );
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
        bit_depth = bit_depth >> 1;                                 
    end                                                           
    endfunction

    localparam integer BLOCK_OFFSET = clogb2(C_DATA_WIDTH / 8 - 1);
    localparam integer BLOCKS_PER_LINE = C_CACHE_LINE_WIDTH / C_DATA_WIDTH;
    localparam integer BLOCK_BITS_WIDTH = clogb2(C_CACHE_LINE_WIDTH / C_DATA_WIDTH - 1);

    localparam integer SET_BITS_OFFSET = BLOCK_BITS_WIDTH + BLOCK_OFFSET;
    localparam integer SET_BITS_WIDTH = clogb2(C_CACHE_SET_CNT - 1);

    localparam integer TAG_BITS_OFFSET = SET_BITS_OFFSET + SET_BITS_WIDTH;
    localparam integer TAG_BITS_WIDTH = C_ADDRESS_WIDTH - SET_BITS_WIDTH - BLOCK_BITS_WIDTH - BLOCK_OFFSET;

    localparam integer VECTOR_SIZE = C_CACHE_LINE_CNT / C_CACHE_SET_CNT ;
    localparam integer VECTOR_WIDTH = clogb2(VECTOR_SIZE - 1);
    
    // Data
    reg [C_DATA_WIDTH-1:0] cache_lines [C_CACHE_SET_CNT-1:0][VECTOR_SIZE-1:0][BLOCKS_PER_LINE-1:0];
    reg [TAG_BITS_WIDTH-1:0] cache_tags [C_CACHE_SET_CNT-1:0][VECTOR_SIZE-1:0];
    reg [VECTOR_SIZE-1:0] cache_valid_bits [C_CACHE_SET_CNT-1:0];
    reg [C_CACHE_LRU_COUNTER_WIDTH-1:0] cache_lru_counter[C_CACHE_SET_CNT-1:0][VECTOR_SIZE-1:0];

    // internal singals
    wire [BLOCK_BITS_WIDTH-1:0] block;
    wire [SET_BITS_WIDTH-1:0] set;
    wire [TAG_BITS_WIDTH-1:0] tag;

    wire [C_DATA_WIDTH-1:0] rdata;

    wire [VECTOR_SIZE-1:0] cache_line_hit;
    wire [VECTOR_WIDTH-1:0] hit_index;
    wire hit;

    reg m_arvalid;
    reg [31:0] m_araddr;

    wire [VECTOR_WIDTH-1:0] empty_index;
    wire empty_index_valid;
    wire [VECTOR_WIDTH-1:0] lru_index;

    wire start_load; 
    reg load_actived;
    wire load_next;
    wire load_last;

    reg [VECTOR_WIDTH-1:0] load_index;
    reg [BLOCK_BITS_WIDTH-1:0] load_cnt;
    reg m_rready;

    // I/O assignment
    assign S_RDATA = rdata;
    assign S_RVALID = hit & S_ARVALID;

    assign M_ARADDR = m_araddr;
    assign M_ARVALID = m_arvalid;
    assign M_RREADY = m_rready;


    // Decode address
    assign block = S_RADDR[(BLOCK_OFFSET + BLOCK_BITS_WIDTH - 1):BLOCK_OFFSET];
    assign set = S_RADDR[(SET_BITS_OFFSET + SET_BITS_WIDTH - 1):SET_BITS_OFFSET];
    assign tag = S_RADDR[(TAG_BITS_OFFSET + TAG_BITS_WIDTH - 1):TAG_BITS_OFFSET];

    // --------------------
    // Cache access
    // --------------------
    genvar i, j, k;
    // Tag compare logic
    // hit 
    generate 
        wire [VECTOR_SIZE-1:0] set_compare[C_CACHE_SET_CNT-1:0];
        for(i=0;i<VECTOR_SIZE;i=i+1) begin
            for(j=0;j<C_CACHE_SET_CNT;j=j+1) begin
                assign set_compare[j][i] = (cache_tags[j][i] == tag && cache_valid_bits[j][i]);
            end
        end
        assign cache_line_hit = set_compare[set];
    endgenerate

    // one hot decoder logic
    // hit_index
    one_hot_decoder
    #(
        .INPUT_WIDTH(VECTOR_SIZE)
    ) hit_index_decode(
        .A(cache_line_hit),
        .B(hit_index),
        .ANY(hit)
    );

    // Output data logic
    assign rdata = cache_lines[set][hit_index][block];

    // --------------------
    // Load data to cache
    // --------------------

    // select empty line logic
    priority_encoder
    #(
        .INPUT_WIDTH(VECTOR_SIZE)
    ) empty_index_encoder (
        .A(~cache_valid_bits[set]),
        .B(empty_index),
        .SELN(),
        .ANY(empty_index_valid)
    );

    // LRU select
    generate
        if(VECTOR_SIZE == 4) begin
            wire [C_CACHE_LRU_COUNTER_WIDTH-1:0] size_4_max_stage2_D0;
            wire [C_CACHE_LRU_COUNTER_WIDTH-1:0] size_4_max_stage2_D1;
            wire [2-1:0] size_4_max_stage2_I0;
            wire [2-1:0] size_4_max_stage2_I1;
            max_2_with_index #(
                .C_DATA_WIDTH(C_CACHE_LRU_COUNTER_WIDTH),
                .C_INDEX_WIDTH(2)
            ) size_4_parallel_compare_0_0 (
                .D0(cache_lru_counter[set][2'b00]),
                .I0(2'b00),
                .D1(cache_lru_counter[set][2'b01]),
                .I1(2'b01),

                .D(size_4_max_stage2_D0),
                .I(size_4_max_stage2_I0)
            );
            max_2_with_index #(
                .C_DATA_WIDTH(C_CACHE_LRU_COUNTER_WIDTH),
                .C_INDEX_WIDTH(2)
            ) size_4_parallel_compare_0_1 (
                .D0(cache_lru_counter[set][2'b10]),
                .I0(2'b10),
                .D1(cache_lru_counter[set][2'b11]),
                .I1(2'b11),

                .D(size_4_max_stage2_D1),
                .I(size_4_max_stage2_I1)
            );

            max_2_with_index #(
                .C_DATA_WIDTH(C_CACHE_LRU_COUNTER_WIDTH),
                .C_INDEX_WIDTH(2)
            ) size_4_parallel_compare_1_0 (
                .D0(size_4_max_stage2_D0),
                .I0(size_4_max_stage2_I0),
                .D1(size_4_max_stage2_D1),
                .I1(size_4_max_stage2_I1),

                .D(),
                .I(lru_index)
            );
        end else begin
            //$display("Cache err!.");
        end
    endgenerate

    // LRU regster update
    generate
        for(i=0;i<C_CACHE_SET_CNT;i = i+1) begin :lru_set
            for(j=0;j<VECTOR_SIZE;j = j+1) begin :lru_block

                wire sel = (set == i) & (hit_index == j) & hit;
                always @(posedge CLK) begin
                    if(~RES_N || sel)
                        cache_lru_counter[i][j] <= 'd0;
                    else if(~&cache_lru_counter[i][j])
                        cache_lru_counter[i][j] <= cache_lru_counter[i][j] + 'd1;
                    else 
                        cache_lru_counter[i][j] <= cache_lru_counter[i][j];
                end

            end
        end
    endgenerate

    assign start_load = ~load_actived & ~hit;
    assign load_next = m_rready & M_RVALID;
    assign load_last = m_rready & M_RVALID & M_RLAST;

    always @(posedge CLK) begin
        m_araddr <= {tag,set, {SET_BITS_OFFSET{1'b0}}};
    end

    always @(posedge CLK) begin
        if(~RES_N)
            m_arvalid <= 'b0;
        else if(start_load)
            m_arvalid <= 'b1;
        else if(m_arvalid && M_ARREADY)
            m_arvalid <= 'b0;
        else 
            m_arvalid <= m_arvalid;
    end

    always @(posedge CLK) begin
        if(~RES_N)
            m_rready <= 'b0;
        else if(start_load)
            m_rready <= 'b1;
        else if(load_last)
            m_rready <= 'b0;
        else 
            m_rready <= m_rready;
    end

    always @(posedge CLK) begin
        if(~RES_N)
            load_actived <= 'b0;
        else if(start_load)
            load_actived <= 'b1;
        else if(load_last)
            load_actived <= 'b0;
        else 
            load_actived <= load_actived;
    end

    always @(posedge CLK) begin
        if(~RES_N || start_load)
            load_cnt <= 'd0;
        else if(load_next)
            load_cnt <= load_cnt + 'd1;
        else 
            load_cnt <= load_cnt;
    end

    always @(posedge CLK) begin
        if(~RES_N)
            load_index <= 'd0;
        else if(start_load)
            load_index <= empty_index_valid ? empty_index : lru_index;
        else 
            load_index <= load_index;
    end

    // cache line generate
    generate
        //genvar i,j,k;
        for(i=0;i<C_CACHE_SET_CNT;i=i+1) begin :line_set
            for(j=0;j<VECTOR_SIZE;j=j+1) begin :line_block
                for(k=0;k<BLOCKS_PER_LINE;k=k+1)begin :line_n
                    wire en = (i == set) & (j == load_index) & (load_cnt == k) & load_next;
                    always @(posedge CLK) begin
                        if(~RES_N)
                            cache_lines[i][j][k] <= 'd0;
                        else if(en)
                            cache_lines[i][j][k] <= M_RDATA;
                    end
                end
            end
        end
    endgenerate

    generate
        //genvar i,j,k;
        for(i=0;i<C_CACHE_SET_CNT;i=i+1) begin :tag_set
            for(j=0;j<VECTOR_SIZE;j=j+1) begin :tag_block
                wire en = (i == set) & (j == load_index) & load_last;
                always @(posedge CLK) begin
                    if(~RES_N)
                        cache_tags[i][j] <= 'd0;
                    else if(en)
                        cache_tags[i][j] <= tag;
                end
            end
        end
    endgenerate

    generate
        //genvar i,j,k;
        for(i=0;i<C_CACHE_SET_CNT;i=i+1) begin :valid_bit_set
            for(j=0;j<VECTOR_SIZE;j=j+1) begin :valid_bit_block
                wire en = (i == set) & (j == load_index) & load_last;
                always @(posedge CLK) begin
                    if(~RES_N)
                        cache_valid_bits[i][j] <= 'd0;
                    else if(en)
                        cache_valid_bits[i][j] <= 'd1;
                end
            end
        end
    endgenerate
endmodule
