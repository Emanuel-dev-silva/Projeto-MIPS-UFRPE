// _____________________________________
// Projeto MIPS Monociclo
// Atividade: Projeto 02 - 2VA
// Disciplina: Arquitetura e Organização de Computadores
// UFRPE
// Professor: Vítor Coutinho
// Semestre: 2026.1
//
// Grupo:
// - Andrey Israel
// - Emanuel Barbosa
// - Erick Matheus
// - João Matheus
//
// Arquivo: ula.sv
//
// Descrição:
// Implementa a Unidade Lógica e Aritmética.
// A ULA realiza operações aritméticas, lógicas,
// comparações e deslocamentos usados pelo MIPS.
// O sinal OP escolhe a operação realizada.
// _____________________________________

module ula(
    input [31:0] In1,
    input [31:0] In2,
    input [4:0] shamt,
    input [3:0] OP,

    output reg [31:0] result,
    output Zero_flag
);

always @(*)
begin
    case(OP)

        4'b0000:
            result = In1 + In2; // add, addi, lw, sw

        4'b0001:
            result = In1 - In2; // sub, beq, bne

        4'b0010:
            result = In1 & In2; // and, andi

        4'b0011:
            result = In1 | In2; // or, ori

        4'b0100:
            result = In1 ^ In2; // xor, xori

        4'b0101:
            result = ~(In1 | In2); // nor

        4'b0110:
            result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0; // slt, slti

        4'b0111:
            result = (In1 < In2) ? 32'd1 : 32'd0; // sltu, sltiu

        4'b1000:
            result = In2 << shamt; // sll

        4'b1001:
            result = In2 >> shamt; // srl

        4'b1010:
            result = $signed(In2) >>> shamt; // sra

        4'b1011:
            result = In2 << In1[4:0]; // sllv

        4'b1100:
            result = In2 >> In1[4:0]; // srlv

        4'b1101:
            result = $signed(In2) >>> In1[4:0]; // srav

        default:
            result = 32'd0;

    endcase
end

assign Zero_flag = (result == 0);

endmodule
