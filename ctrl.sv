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
// - Erick
// - João Matheus
//
// Arquivo: ctrl.sv
//
// Descrição:
// Implementa a unidade de controle principal.
// A partir do opcode da instrução, gera os sinais
// que controlam o caminho de dados do processador.
// _____________________________________

module ctrl(
    input [5:0] opcode,

    output reg RegDst,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg BranchNE,
    output reg Jump,
    output reg Jal,

    output reg ZeroExtend,
    output reg Lui,

    output reg ALUCtrlSrc,
    output reg [3:0] ALUControlDirect,

    output reg [1:0] ALUOp
);

always @(*)
begin
    RegDst           = 0;
    ALUSrc           = 0;
    MemtoReg         = 0;
    RegWrite         = 0;
    MemRead          = 0;
    MemWrite         = 0;
    Branch           = 0;
    BranchNE         = 0;
    Jump             = 0;
    Jal              = 0;
    ZeroExtend       = 0;
    Lui              = 0;
    ALUCtrlSrc       = 0;
    ALUControlDirect = 4'b0000;
    ALUOp            = 2'b00;

    case(opcode)

        6'b000000:
        begin
            RegDst     = 1;
            RegWrite   = 1;
            ALUOp      = 2'b10;
            ALUCtrlSrc = 0;
        end

        6'b001000:
        begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // addi
        end

        6'b001100:
        begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0010; // andi
        end

        6'b001101:
        begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0011; // ori
        end

        6'b001110:
        begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0100; // xori
        end

        6'b001010:
        begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0110; // slti
        end

        6'b001011:
        begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0111; // sltiu
        end

        6'b001111:
        begin
            RegWrite   = 1;
            Lui        = 1;
            ALUCtrlSrc = 1; // lui
        end

        6'b100011:
        begin
            ALUSrc           = 1;
            MemtoReg         = 1;
            RegWrite         = 1;
            MemRead          = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // lw
        end

        6'b101011:
        begin
            ALUSrc           = 1;
            MemWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // sw
        end

        6'b000100:
        begin
            Branch           = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0001; // beq
        end

        6'b000101:
        begin
            BranchNE         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0001; // bne
        end

        6'b000010:
        begin
            Jump = 1; // j
        end

        6'b000011:
        begin
            Jump     = 1;
            Jal      = 1;
            RegWrite = 1; // jal
        end

        default:
        begin
        end

    endcase
end

endmodule
