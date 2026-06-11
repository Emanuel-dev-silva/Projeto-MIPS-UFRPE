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
// Arquivo: ula_ctrl.sv
//
// Descrição:
// Implementa o controle da ULA.
// Recebe ALUOp da unidade de controle e o campo funct.
// A saída OP define qual operação a ULA executará.
// _____________________________________

module ula_ctrl(
    input [1:0] ALUOp,
    input [5:0] funct,

    output reg [3:0] OP
);

always @(*)
begin
    case(ALUOp)

        2'b00:
            OP = 4'b0000; // soma

        2'b01:
            OP = 4'b0001; // subtração

        2'b10:
        begin
            case(funct)

                6'b100000: OP = 4'b0000; // add
                6'b100010: OP = 4'b0001; // sub
                6'b100100: OP = 4'b0010; // and
                6'b100101: OP = 4'b0011; // or
                6'b100110: OP = 4'b0100; // xor
                6'b100111: OP = 4'b0101; // nor
                6'b101010: OP = 4'b0110; // slt
                6'b101011: OP = 4'b0111; // sltu

                6'b000000: OP = 4'b1000; // sll
                6'b000010: OP = 4'b1001; // srl
                6'b000011: OP = 4'b1010; // sra

                6'b000100: OP = 4'b1011; // sllv
                6'b000110: OP = 4'b1100; // srlv
                6'b000111: OP = 4'b1101; // srav

                default:
                    OP = 4'b0000;

            endcase
        end

        default:
            OP = 4'b0000;

    endcase
end

endmodule
