`define PC_RESET_ADDRESS            32'hC000_0000
`define INT_ENTER_RESET_ADDRESS     32'hC000_04cc

// ALU op
`define ALUOP_LENGTH 4
`define OP_SLL  0
`define OP_SRL  1
`define OP_SRA  2
`define OP_MUL  3
`define OP_DIV  4
`define OP_ADD  5
`define OP_SUB  6
`define OP_AND  7
`define OP_OR   8
`define OP_XOR  9
`define OP_NOR  10
`define OP_SLT  11
`define OP_SLTU 12

// contral singal bus
`define REG_INFO_BUS_LENGTH 12
`define BUS_DECODE_RS       4:0
`define BUS_DECODE_RT       9:5
`define BUS_DECODE_RS_USE   10
`define BUS_DECODE_RT_USE   11

`define BRANCH_JMP_BUS_LENGTH   9
`define BUS_DECODE_BRANCH       0
`define BUS_DECODE_CMP_ZERO     1
`define BUS_DECODE_BRANCH_EQ    2
`define BUS_DECODE_BRANCH_NEQ   3
`define BUS_DECODE_BRANCH_GTZ   4
`define BUS_DECODE_BRANCH_LTZ   5
`define BUS_DECODE_JMP          6
`define BUS_DECODE_JR           7
`define BUS_DECODE_LINK         8

`define REG_WRITE_BUS_LENGTH        6
`define BUS_DECODE_REG_WRITE        0
`define BUS_DECODE_REG_WRITE_DST    5:1

`define REG_WRITE_RESULT_BUS_LENGTH         38
`define BUS_DECODE_RESULT_REG_WRITE         0
`define BUS_DECODE_RESULT_REG_WRITE_DST     5:1
`define BUS_DECODE_RESULT_REG_WRITE_DATA    37:6

`define MEM_CONTRAL_BUS_LENGTH  3
`define BUS_DECODE_MEM_READ     0
`define BUS_DECODE_MEM_WIRTE    1
`define BUS_DECODE_MEM_HALF     2

`define ALU_CONTRAL_BUS_LENGTH  13
`define BUS_DECODE_ALU_OP       3:0
`define BUS_DECODE_SHMAT        8:4
`define BUS_DECODE_SHMAT_REG    9
`define BUS_DECODE_ALU_IMM      10
`define BUS_DECODE_LUI          11
`define BUS_DECODE_S_RS_BYPASS  12

`define EX_RESULT_BUS_LENGTH    64
`define BUS_DECODE_EX_RESULT   31:0
`define BUS_DECODE_RT_BYPASS    63:32

`define BRANCH_JMP_RESULT_BUS_LENGTH    36
`define BUS_DECODE_RES_ADDR             31:0
`define BUS_DECODE_RES_BRANCH_TAKEN     32
`define BUS_DECODE_RES_BRANCH           33
`define BUS_DECODE_RES_JMP              34
`define BUS_DECODE_RES_JR               35

`define CP0_RW_BUS_WIDTH            39
`define BUS_DECODE_CP0_REG_DATA     31:0
`define BUS_DECODE_CP0_REG          37:32
`define BUS_DECODE_CP0_REG_W        38

`define EX_FASTFORWARD_CONTRAL_BUS_WIDTH      4
`define BUS_DECODE_RS_MEM_FASTFORWARD   0
`define BUS_DECODE_RS_WB_FASTFORWARD    1
`define BUS_DECODE_RT_MEM_FASTFORWARD   2
`define BUS_DECODE_RT_WB_FASTFORWARD    3

// CP0 regs
`define CP0_CAUSE 'd13
`define CP0_EPC 'd14
`define CP0_INT_ENTER 'd15