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
// Arquivo: ctrl.sv
//
// Descrição:
// Implementa a unidade de controle principal (Main Control).
// A partir do opcode da instrução, gera todos os sinais
// que controlam o caminho de dados (datapath) do processador.
// _____________________________________

// ------------------------------------------------------------
// Declaração do módulo Unidade de Controle
//
// Entrada:
//   opcode [5:0] - Campo opcode, os 6 bits mais significativos
//                  (bits 31-26) da instrução. Vem direto da
//                  memória de instrução (i_mem). É o único dado
//                  que esse módulo precisa para decidir tudo.
//
// Saídas (sinais de controle, cada um liga/desliga uma parte
// do datapath):
//   RegDst     - Escolhe qual campo da instrução é o endereço
//                de escrita do regfile: rt (0) ou rd (1).
//                Tipo R usa rd, tipo I usa rt.
//   ALUSrc     - Escolhe o segundo operando da ULA: vem do
//                regfile (0) ou é o imediato da instrução (1).
//   MemtoReg   - Escolhe o que é escrito no regfile: saída da
//                ULA (0) ou dado lido da memória (1, usado no lw).
//   RegWrite   - Habilita escrita no banco de registradores.
//   MemRead    - Habilita leitura da memória de dados (lw).
//   MemWrite   - Habilita escrita na memória de dados (sw).
//   Branch     - Indica instrução de desvio condicional beq.
//   BranchNE   - Indica instrução de desvio condicional bne.
//   Jump       - Indica instrução de salto incondicional (j, jal).
//   Jal        - Indica especificamente jal, que também escreve
//                o endereço de retorno em $ra.
//   ZeroExtend - Escolhe extensão do imediato: sinal (0) ou
//                zero (1). andi/ori/xori usam zero-extend.
//   Lui        - Indica a instrução lui, que carrega o imediato
//                diretamente na metade superior do registrador.
//   ALUCtrlSrc - Escolhe a origem do código da ULA: calculado
//                pela ula_ctrl via ALUOp/funct (0), ou um valor
//                fixo já definido aqui mesmo, ALUControlDirect (1).
//                Isso evita depender da ula_ctrl para instruções
//                tipo I, que não têm campo funct.
//   ALUControlDirect [3:0] - Código de operação da ULA já pronto,
//                usado quando ALUCtrlSrc = 1 (instruções tipo I).
//   ALUOp [1:0] - Sinal resumido enviado à ula_ctrl, usado quando
//                ALUCtrlSrc = 0 (instruções tipo R).
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// Bloco combinacional principal
//
// always @(*) — lógica pura, sem clock. Sempre que opcode mudar,
// todos os sinais de controle são recalculados instantaneamente.
// ------------------------------------------------------------
always @(*) begin

    // --------------------------------------------------------
    // Valores padrão (default assignment)
    //
    // Antes de entrar no case, todos os sinais são zerados.
    // Isso é uma prática essencial em Verilog: garante que
    // TODO sinal tenha um valor definido em TODO caminho de
    // execução, evitando a inferência de latches (memória
    // indesejada que a ferramenta de síntese cria quando um
    // sinal pode "ficar sem valor" em algum branch do case).
    //
    // Cada case abaixo só precisa sobrescrever os sinais que
    // são diferentes de zero para aquela instrução — o resto
    // já está coberto pelo default.
    // --------------------------------------------------------
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

    // ----------------------------------------------------------
    // case(opcode) — a unidade de controle decodifica a
    // instrução observando apenas seus 6 bits de opcode.
    // Cada ramo configura os sinais necessários para aquela
    // instrução percorrer corretamente o datapath.
    // ----------------------------------------------------------
    case(opcode)

        // --------------------------------------------------
        // 6'b000000 — Instruções tipo R (add, sub, and, or, etc.)
        //   - RegDst = 1: destino da escrita é o campo rd
        //   - RegWrite = 1: resultado da ULA será gravado no regfile
        //   - ALUOp = 2'b10: avisa a ula_ctrl para olhar o funct
        //   - ALUCtrlSrc = 0: o código da ULA vem da ula_ctrl,
        //     não de um valor fixo aqui
        // --------------------------------------------------
        6'b000000: begin
            RegDst     = 1;
            RegWrite   = 1;
            ALUOp      = 2'b10;
            ALUCtrlSrc = 0;
        end

        // --------------------------------------------------
        // 6'b001000 — addi $rt, $rs, imm
        //   - ALUSrc = 1: segundo operando da ULA é o imediato
        //   - RegWrite = 1: grava resultado no regfile
        //   - ALUCtrlSrc = 1: usa o código fixo abaixo (ADD),
        //     pois addi não tem campo funct
        // --------------------------------------------------
        6'b001000: begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // addi
        end

        // --------------------------------------------------
        // 6'b001100 — andi $rt, $rs, imm
        //   - ZeroExtend = 1: o imediato é estendido com zeros
        //     à esquerda (não com sinal), conforme especificação
        //     do MIPS para operações lógicas com imediato
        // --------------------------------------------------
        6'b001100: begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0010; // andi
        end

        // --------------------------------------------------
        // 6'b001101 — ori $rt, $rs, imm
        //   - Mesma lógica do andi, trocando a operação da ULA
        // --------------------------------------------------
        6'b001101: begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0011; // ori
        end

        // --------------------------------------------------
        // 6'b001110 — xori $rt, $rs, imm
        //   - Mesma lógica do andi/ori, trocando a operação
        // --------------------------------------------------
        6'b001110: begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0100; // xori
        end

        // --------------------------------------------------
        // 6'b001010 — slti $rt, $rs, imm
        //   - Comparação com sinal entre $rs e o imediato
        //   - Não usa ZeroExtend: o imediato é estendido com
        //     sinal, pois é uma comparação aritmética
        // --------------------------------------------------
        6'b001010: begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0110; // slti
        end

        // --------------------------------------------------
        // 6'b001011 — sltiu $rt, $rs, imm
        //   - Mesma lógica do slti, mas comparação sem sinal
        // --------------------------------------------------
        6'b001011: begin
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0111; // sltiu
        end

        // --------------------------------------------------
        // 6'b001111 — lui $rt, imm
        //   - Lui = 1: sinaliza que o imediato deve ser carregado
        //     diretamente nos 16 bits superiores do registrador
        //   - Não usa ALUSrc nem ALUControlDirect porque essa
        //     instrução não passa pela ULA da forma usual — o
        //     próprio sinal Lui desvia o caminho de dados
        // --------------------------------------------------
        6'b001111: begin
            RegWrite   = 1;
            Lui        = 1;
            ALUCtrlSrc = 1; // lui
        end

        // --------------------------------------------------
        // 6'b100011 — lw $rt, imm($rs)
        //   - ALUSrc = 1: ULA soma $rs + imediato para formar
        //     o endereço de memória
        //   - MemRead = 1: habilita leitura da d_mem
        //   - MemtoReg = 1: o dado escrito no regfile vem da
        //     memória, não da ULA
        // --------------------------------------------------
        6'b100011: begin
            ALUSrc           = 1;
            MemtoReg         = 1;
            RegWrite         = 1;
            MemRead          = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // lw
        end

        // --------------------------------------------------
        // 6'b101011 — sw $rt, imm($rs)
        //   - ALUSrc = 1: mesma lógica do lw para calcular endereço
        //   - MemWrite = 1: habilita escrita na d_mem
        //   - RegWrite continua 0: sw não escreve no regfile
        // --------------------------------------------------
        6'b101011: begin
            ALUSrc           = 1;
            MemWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // sw
        end

        // --------------------------------------------------
        // 6'b000100 — beq $rs, $rt, imm
        //   - Branch = 1: sinaliza desvio condicional "se igual"
        //   - ALUControlDirect = SUB: a ULA subtrai os operandos;
        //     se o resultado for zero (Zero_flag = 1), os
        //     registradores são iguais e o desvio é tomado
        // --------------------------------------------------
        6'b000100: begin
            Branch           = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0001; // beq
        end

        // --------------------------------------------------
        // 6'b000101 — bne $rs, $rt, imm
        //   - BranchNE = 1: sinaliza desvio condicional "se diferente"
        //   - Mesma operação da ULA do beq (subtração), mas o
        //     desvio é tomado quando Zero_flag = 0
        // --------------------------------------------------
        6'b000101: begin
            BranchNE         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0001; // bne
        end

        // --------------------------------------------------
        // 6'b000010 — j address
        //   - Jump = 1: sinaliza salto incondicional
        //   - Nenhum outro sinal é necessário: j não usa a ULA,
        //     não lê/escreve memória, não escreve no regfile
        // --------------------------------------------------
        6'b000010: begin
            Jump = 1; // j
        end

        // --------------------------------------------------
        // 6'b000011 — jal address
        //   - Jump = 1: também é um salto incondicional
        //   - Jal = 1: além de saltar, grava o endereço de
        //     retorno (PC+8) no registrador $ra ($31)
        //   - RegWrite = 1: habilita essa escrita em $ra
        // --------------------------------------------------
        6'b000011: begin
            Jump     = 1;
            Jal      = 1;
            RegWrite = 1; // jal
        end

        // --------------------------------------------------
        // default — opcode não reconhecido
        //   - Bloco vazio é intencional: todos os sinais já
        //     foram zerados no início do always, então um
        //     opcode inválido simplesmente não faz nada
        //     (NOP de segurança), sem comportamento indefinido
        // --------------------------------------------------
        default: begin
        end

    endcase
end

endmodule
