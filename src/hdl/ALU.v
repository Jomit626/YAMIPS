`timescale 1ns / 1ps

`include "config.v"

module ALU(
    input wire[3:0] op,
    input wire[31:0] A,
    input wire[31:0] B,
    input wire[4:0] shmat,

    output wire[31:0] res,
    output wire zero_flag,
    output wire carray_flag,
    output wire overflow_flag
    );
    // shift op
    wire [31:0] shift_sll_result = B << shmat;
    wire [31:0] shift_srl_result = B >> shmat;
    wire [31:0] shift_sra_result = $signed(B) >>> shmat;

    // mul div
    // nop

    // add sub op
    wire adder_add = (op == `OP_ADD);

    wire[31:0] adder_result;
    wire adder_c_out;
    c_addsub_alu_test adder_alu(
        .A(A),
        .B(B),
        .CE(1'b1),
        .ADD(adder_add),

        .S(adder_result),
        .C_OUT(adder_c_out)
    );

    // logic op
    wire [31:0] and_result = A & B;
    wire [31:0] or_result = A | B;
    wire [31:0] xor_result = A ^ B;
    wire [31:0] nor_result = ~or_result;

    // cmp op
    //wire 
    wire sign_of_A = A[31];
    wire sign_of_B = B[31];
    wire sign_of_adder_res = adder_result[31];  // adder_add is 0 when op != OP_ADD
    wire slt_result = (sign_of_A & !sign_of_B) | ((sign_of_A ~^ sign_of_B) & sign_of_adder_res);
    wire sltu_result = !carray_flag & !zero_flag;

    // output
    assign zero_flag = ~(|adder_result);
    assign carray_flag = adder_c_out;
    assign overflow_flag = (sign_of_A & !sign_of_B & !sign_of_adder_res) | (!sign_of_A & sign_of_B & sign_of_adder_res);

    //assign res = 
    //            (op == OP_SLL) ? shift_sll_result :
    //            (op == OP_SRL) ? shift_srl_result :
    //            (op == OP_SRA) ? shift_sra_result :
    //            (op == OP_MUL) ? 32'hffffffff :
    //            (op == OP_DIV) ? 32'hffffffff :
    //            (op == OP_ADD) ? adder_result :
    //            (op == OP_SUB) ? adder_result :
    //            (op == OP_AND) ? and_result :
    //            (op == OP_OR ) ? or_result :
    //            (op == OP_XOR) ? xor_result :
    //            (op == OP_NOR) ? nor_result :
    //            (op == OP_SLT) ? 32'hffffffff :
    //            (op == OP_SLTU) ? 32'hffffffff : 32'hffffffff;

    wire op_sll = (op == `OP_SLL);
    wire op_srl = (op == `OP_SRL);
    wire op_sra = (op == `OP_SRA);
    wire op_mul = (op == `OP_MUL);
    wire op_div = (op == `OP_DIV);
    wire op_add = (op == `OP_ADD);
    wire op_sub = (op == `OP_SUB);
    wire op_and = (op == `OP_AND);
    wire op_or = (op == `OP_OR);
    wire op_xor = (op == `OP_XOR);
    wire op_nor = (op == `OP_NOR);
    wire op_slt = (op == `OP_SLT);
    wire op_sltu = (op == `OP_SLTU);

    assign res =    ({32{op_sll}} & shift_sll_result)
                |   ({32{op_srl}} & shift_srl_result)
                |   ({32{op_sra}} & shift_sra_result)
                //|   {32{op_mul}} & shift_sll_result
                //|   {32{op_div}} & shift_sll_result
                |   ({32{op_add}} & adder_result)
                |   ({32{op_sub}} & adder_result)
                |   ({32{op_and}} & and_result)
                |   ({32{op_or}} & or_result)
                |   ({32{op_xor}} & xor_result)
                |   ({32{op_nor}} & nor_result)
                |   ({32{op_slt}} & {{31{1'b0}},slt_result})
                |   ({32{op_sltu}} & {{31{1'b0}},sltu_result});
    
    //always @(*) begin
    //    case(op)
    //        `OP_SLL : res <= shift_sll_result;
    //        `OP_SRL : res <= shift_srl_result;
    //        `OP_SRA : res <= shift_sra_result;
    //        `OP_MUL : res <= 32'hffffffff;
    //        `OP_DIV : res <= 32'hffffffff;
    //        `OP_ADD : res <= adder_result;
    //        `OP_SUB : res <= adder_result;
    //        `OP_AND : res <= and_result;
    //        `OP_OR  : res <= or_result;
    //        `OP_XOR : res <= xor_result;
    //        `OP_NOR : res <= nor_result;
    //        `OP_SLT : res <= {{31{1'b0}},slt_result};
    //        `OP_SLTU: res <= {{31{1'b0}},sltu_result};
    //        default: res <= 32'hffffffff;
    //    endcase
    //end
    
endmodule
