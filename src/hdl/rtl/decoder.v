`timescale 1ns / 1ns

`include "config.v"

module decoder(
    input wire [31:0] pc,
    input wire [31:0] pc_plus_4,

    input wire [5:0] funct,
    input wire [5:0] shmat,
    input wire [4:0] rd,
    input wire [4:0] rt,
    input wire [4:0] rs,
    input wire [5:0] opcode,

    input wire [15:0] immediate,
    input wire [25:0] address,

    output wire[`REG_INFO_BUS_LENGTH - 1:0] s_reg_info_bus,
    output wire[`BRANCH_JMP_BUS_LENGTH - 1:0] s_branch_jmp_bus,
    output wire[`ALU_CONTRAL_BUS_LENGTH - 1:0] s_alu_contral_bus,
    output wire[`REG_WRITE_BUS_LENGTH - 1:0] s_reg_write_bus,
    output wire[`MEM_CONTRAL_BUS_LENGTH - 1:0] s_mem_contral_bus,
    output wire[31:0] extended_imm,
    output wire[31:0] jump_address,

    output wire s_syscall,
    output wire s_eret,
    output wire s_mtc0,
    output wire s_mfc0
    );

    assign jump_address = { pc_plus_4[31:28], address, 2'b0 };

    wire opcode_special = ~|opcode;
    // R-Type
    wire i_sll =        opcode_special & (funct == 6'b000000);
    wire i_srl =        opcode_special & (funct == 6'b000010);
    wire i_sra =        opcode_special & (funct == 6'b000011);
    wire i_sllv =       opcode_special & (funct == 6'b000100);
    wire i_srlv =       opcode_special & (funct == 6'b000110);
    wire i_srav =       opcode_special & (funct == 6'b000111);
    wire i_add =        opcode_special & (funct == 6'b100000);
    wire i_addu =       opcode_special & (funct == 6'b100001);
    wire i_sub =        opcode_special & (funct == 6'b100010);
    wire i_subu =       opcode_special & (funct == 6'b100011);
    wire i_and =        opcode_special & (funct == 6'b100100);
    wire i_or =         opcode_special & (funct == 6'b100101);
    wire i_xor =        opcode_special & (funct == 6'b100110);
    wire i_nor =        opcode_special & (funct == 6'b100111);
    wire i_slt =        opcode_special & (funct == 6'b101010);
    wire i_sltu =       opcode_special & (funct == 6'b101011);

    wire i_syscall =    opcode_special & (funct == 6'b001100);

    wire i_jr =         opcode_special & (funct == 6'b001000);
    wire i_jalr =       opcode_special & (funct == 6'b001001);

    // J-Type
    wire i_j =          (opcode == 6'b000010);
    wire i_jal =        (opcode == 6'b000011);

    // I-Type
    wire i_beq =        (opcode == 6'b000100);
    wire i_bne =        (opcode == 6'b000101);
    wire i_bgtz =       (opcode == 6'b000111);
    wire i_blez =       (opcode == 6'b000110);
    wire i_bltz =       (opcode == 6'b000001) & (rt == 5'b00000);
    wire i_bltzal =     (opcode == 6'b000001) & (rt == 5'b10000);
    wire i_bgez =       (opcode == 6'b000001) & (rt == 5'b00001);
    wire i_bgezal =     (opcode == 6'b000001) & (rt == 5'b10001);


    wire i_addi =       (opcode == 6'b001000);
    wire i_addiu =      (opcode == 6'b001001);
    wire i_andi =       (opcode == 6'b001100);
    wire i_ori =        (opcode == 6'b001101);
    wire i_xori =       (opcode == 6'b001110);
    wire i_slti =       (opcode == 6'b001010);
    wire i_sltiu =      (opcode == 6'b001011);

    wire i_lh =         (opcode == 6'b100001);
    wire i_lw =         (opcode == 6'b100011);
    wire i_sw =         (opcode == 6'b101011);
    wire i_lui =        (opcode == 6'b001111);

    // COP0
    wire i_eret =       (opcode == 6'b010000) & (funct == 6'b011000);
    wire i_mfc0 =       (opcode == 6'b010000) & (rs == 5'b00000);
    wire i_mtc0 =       (opcode == 6'b010000) & (rs == 5'b00100);

    wire [3:0] alu_op = 
        i_sll   ? `OP_SLL    :
        i_srl   ? `OP_SRL    :
        i_sra   ? `OP_SRA    :
        i_sllv  ? `OP_SLL    :
        i_srlv  ? `OP_SRL    :
        i_srav  ? `OP_SRA    :
        i_add   ? `OP_ADD    :
        i_addu  ? `OP_ADD    :
        i_sub   ? `OP_SUB    :
        i_subu  ? `OP_SUB    :
        i_and   ? `OP_AND    :
        i_or    ? `OP_OR     :
        i_xor   ? `OP_XOR    :
        i_nor   ? `OP_NOR    :
        i_slt   ? `OP_SLT    :
        i_sltu  ? `OP_SLTU   :
        i_addi  ? `OP_ADD    :
        i_addiu ? `OP_ADD    :
        i_andi  ? `OP_AND    :
        i_ori   ? `OP_OR     :
        i_xori  ? `OP_XOR    :
        i_slti  ? `OP_SLT    :
        i_sltiu ? `OP_SLTU   :
        i_lw    ? `OP_ADD    :
        i_lh    ? `OP_ADD    :
        i_sw    ? `OP_ADD    :
        `OP_SUB;
    
    wire s_shmat_reg = i_sllv | i_srlv | i_srav;
    wire s_alu_imm = 
        i_addi | i_addiu | i_andi | i_ori | i_xori | 
        i_slti | i_sltiu | i_lh  | i_lw | i_sw | i_beq | 
        i_bne | i_bgtz | i_blez | i_bltz | i_bltzal | 
        i_bgez | i_bgezal;
    wire s_lui = i_lui;

    assign s_alu_contral_bus[`BUS_DECODE_ALU_OP] = alu_op;
    assign s_alu_contral_bus[`BUS_DECODE_SHMAT] = shmat;
    assign s_alu_contral_bus[`BUS_DECODE_SHMAT_REG] = s_shmat_reg;
    assign s_alu_contral_bus[`BUS_DECODE_ALU_IMM] = s_alu_imm;
    assign s_alu_contral_bus[`BUS_DECODE_LUI] = s_lui;
    assign s_alu_contral_bus[`BUS_DECODE_S_RS_BYPASS] = i_mfc0;

    // Register wirte
    wire s_reg_write = 
        i_sll | i_srl | i_sra | i_sllv | i_srlv | i_srav | 
        i_add | i_addu | i_sub | i_subu | i_and | i_or | 
        i_xor | i_nor | i_slt | i_sltu | i_addi | i_addiu | 
        i_andi | i_ori | i_xori | i_slti | i_sltiu | i_lh | i_lw | 
        i_lui | i_jalr | i_jal | i_bltzal | i_bgezal |
        i_mfc0 ;

    wire [4:0] s_reg_write_dst = 
        (i_jalr | i_jal | i_bltzal | i_bgezal ) ? 5'd31 :
        (i_addi | i_addiu | i_andi | i_ori | i_xori | i_slti | i_sltiu | i_lh | i_lw | i_lui | i_mfc0) ? rt :
        rd;
    
    assign s_reg_write_bus[`BUS_DECODE_REG_WRITE] = s_reg_write;
    assign s_reg_write_bus[`BUS_DECODE_REG_WRITE_DST] = s_reg_write_dst;

    // memory    
    wire s_mem_read = i_lw | i_lh;
    wire s_mem_write = i_sw;
    wire s_mem_half = i_lh;

    assign s_mem_contral_bus[`BUS_DECODE_MEM_READ] = s_mem_read;
    assign s_mem_contral_bus[`BUS_DECODE_MEM_WIRTE] = s_mem_write;
    assign s_mem_contral_bus[`BUS_DECODE_MEM_HALF] = s_mem_half;

    // branch and jmp
    wire s_branch = 
        i_beq | i_bne | i_bgtz | i_blez | i_bltz | i_bltzal | i_bgez | i_bgezal;
    wire s_branch_cmp_zero = i_bgtz | i_blez | i_bltz | i_bltzal | i_bgez | i_bgezal;
    wire s_branch_eq = i_beq | i_blez | i_bgez | i_bgezal;
    wire s_branch_neq = i_bne;
    wire s_branch_gtz = i_bgtz | i_bgez | i_bgezal;
    wire s_branch_ltz = i_blez | i_bltz | i_bltzal;
    wire s_jmp = i_j | i_jal;
    wire s_jr = i_jr | i_jalr;
    wire s_link = i_jal | i_jalr | i_bltzal | i_bgezal;

    assign s_branch_jmp_bus[`BUS_DECODE_BRANCH] = s_branch;
    assign s_branch_jmp_bus[`BUS_DECODE_CMP_ZERO] = s_branch_cmp_zero;
    assign s_branch_jmp_bus[`BUS_DECODE_BRANCH_EQ] = s_branch_eq;
    assign s_branch_jmp_bus[`BUS_DECODE_BRANCH_NEQ] = s_branch_neq;
    assign s_branch_jmp_bus[`BUS_DECODE_BRANCH_GTZ] = s_branch_gtz;
    assign s_branch_jmp_bus[`BUS_DECODE_BRANCH_LTZ] = s_branch_ltz;
    assign s_branch_jmp_bus[`BUS_DECODE_JMP] = s_jmp;
    assign s_branch_jmp_bus[`BUS_DECODE_JR] = s_jr;
    assign s_branch_jmp_bus[`BUS_DECODE_LINK] = s_link;
    
    // imm
    wire s_imm_signed_ext = 
        i_addi | i_addiu | i_slti | i_sltiu | i_lw | i_lh |  
        i_sw | i_beq | i_bne | i_bgtz | i_blez | 
        i_bltz | i_bltzal | i_bgez | i_bgezal;
    wire s_imm_ext_bit = immediate[15] & s_imm_signed_ext;
    assign extended_imm = { { 16 { s_imm_ext_bit } } ,immediate } ;

    // rs rt usage
    wire s_rs_used =  
        i_sllv | i_srlv | i_srav | i_add | i_addu | i_sub | i_subu | 
        i_and | i_or | i_xor | i_nor | i_slt | i_sltu | i_addi | i_addiu | 
        i_andi | i_ori | i_xori | i_slti | i_sltiu | i_lw | i_lh | i_sw | i_beq | 
        i_bne | i_bgtz | i_blez | i_bltz | i_bltzal | i_bgez | i_bgezal | 
        i_jalr | i_jr;

    wire s_rt_used = 
        i_sll | i_srl | i_sra | i_sllv | i_srlv | i_srav | i_add | 
        i_addu | i_sub | i_subu | i_and | i_or | i_xor | i_nor | 
        i_slt | i_sltu | i_sw | i_beq | i_bne |
        i_mtc0 ;

    assign s_reg_info_bus[`BUS_DECODE_RS] = i_syscall ? 5'd4 : rs;
    assign s_reg_info_bus[`BUS_DECODE_RT] = i_syscall ? 5'd2 : rt;
    assign s_reg_info_bus[`BUS_DECODE_RS_USE] = s_rs_used;
    assign s_reg_info_bus[`BUS_DECODE_RT_USE] = s_rt_used;


    assign s_syscall = i_syscall;
    assign s_eret = i_eret;

    assign s_mtc0 = i_mtc0;
    assign s_mfc0 = i_mfc0;

endmodule
