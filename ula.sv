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
// Arquivo: ula_ctrl.v
//
// Descrição:
// Implementa o controle da ULA (ULA Control).
// Recebe ALUOp da unidade de controle principal e o campo funct
// extraído da instrução tipo R.
// A saída OP define qual operação a ULA executará.
// _____________________________________

// ------------------------------------------------------------
// Declaração do módulo ULA Control
//
// Entradas:
//   ALUOp [1:0] - Sinal vindo da unidade de controle principal.
//                 Indica a categoria da instrução:
//                   2'b00 → instruções de memória (lw, sw) → soma
//                   2'b01 → instruções de desvio (beq, bne) → subtração
//                   2'b10 → instruções tipo R → decodificar campo funct
//
//   funct [5:0] - Campo funct dos 6 bits menos significativos
//                 da instrução tipo R. Só é relevante quando ALUOp == 2'b10.
//
// Saída:
//   OP    [3:0] - Código de operação enviado à ULA,
//                 selecionando qual operação será executada.
// ------------------------------------------------------------
module ula_ctrl(
    input  [1:0] ALUOp,
    input  [5:0] funct,
    output reg [3:0] OP
);

// ------------------------------------------------------------
// Bloco combinacional principal
//
// always @(*) garante reavaliação sempre que ALUOp ou funct
// mudarem. Toda a lógica é combinacional (sem clock).
// ------------------------------------------------------------
always @(*) begin

    case(ALUOp)

        // ------------------------------------------------------
        // ALUOp == 2'b00 — Instruções de memória (lw, sw)
        //   - Calcula endereço: base + offset → operação de soma
        //   - O campo funct é ignorado neste caso
        // ------------------------------------------------------
        2'b00:
            OP = 4'b0000; // ADD

        // ------------------------------------------------------
        // ALUOp == 2'b01 — Instruções de desvio (beq, bne)
        //   - Compara operandos via subtração
        //   - Zero_flag da ULA indica se os valores são iguais
        //   - O campo funct é ignorado neste caso
        // ------------------------------------------------------
        2'b01:
            OP = 4'b0001; // SUB

        // ------------------------------------------------------
        // ALUOp == 2'b10 — Instruções tipo R
        //   - A operação é determinada pelo campo funct
        //   - Cada valor de funct mapeia para um OP da ULA
        // ------------------------------------------------------
        2'b10: begin
            case(funct)

                // Operações aritméticas
                6'b100000: OP = 4'b0000; // ADD  — adição com sinal
                6'b100010: OP = 4'b0001; // SUB  — subtração com sinal

                // Operações lógicas
                6'b100100: OP = 4'b0010; // AND  — E bit a bit
                6'b100101: OP = 4'b0011; // OR   — OU bit a bit
                6'b100110: OP = 4'b0100; // XOR  — OU exclusivo bit a bit
                6'b100111: OP = 4'b0101; // NOR  — NOR bit a bit

                // Comparações
                6'b101010: OP = 4'b0110; // SLT  — set on less than (com sinal)
                6'b101011: OP = 4'b0111; // SLTU — set on less than (sem sinal)

                // Deslocamentos com shamt (quantidade fixa no campo da instrução)
                6'b000000: OP = 4'b1000; // SLL  — shift left logical
                6'b000010: OP = 4'b1001; // SRL  — shift right logical
                6'b000011: OP = 4'b1010; // SRA  — shift right arithmetic

                // Deslocamentos variáveis (quantidade definida por registrador rs)
                6'b000100: OP = 4'b1011; // SLLV — shift left logical variable
                6'b000110: OP = 4'b1100; // SRLV — shift right logical variable
                6'b000111: OP = 4'b1101; // SRAV — shift right arithmetic variable

                // ----------------------------------------------
                // funct não reconhecido
                //   - Saída segura: soma (neutro)
                //   - Evita comportamento indefinido em síntese
                // ----------------------------------------------
                default:
                    OP = 4'b0000;

            endcase
        end

        // ------------------------------------------------------
        // ALUOp não reconhecido
        //   - Garante saída determinística para qualquer valor
        //     inválido de ALUOp, evitando latch inferido
        // ------------------------------------------------------
        default:
            OP = 4'b0000;

    endcase
end

endmodule
