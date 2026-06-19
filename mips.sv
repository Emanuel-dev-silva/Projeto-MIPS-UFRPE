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
// Arquivo: mips.sv
//
// Descrição:
// Esse é o módulo principal do processador.
// Aqui juntamos os outros módulos, como PC,
// memória de instruções, controle, banco de
// registradores, ULA e memória de dados.
// Também fica aqui a lógica de branch, jump,
// jal e jr.
// _____________________________________

module mips(
    input clk,
    input reset,

    output [31:0] debug_pc,
    output [31:0] debug_instruction,
    output [31:0] debug_alu_result,
    output [31:0] debug_mem_data
);

    // _____________________________________
    // Ligações principais do processador
    // _____________________________________

    wire [31:0] PC;
    wire [31:0] nextPC;
    wire [31:0] instruction;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    wire [3:0] ALUControlFromFunct;
    wire [3:0] ALUControlFinal;

    wire [31:0] ALUResult;
    wire Zero;

    wire [31:0] MemReadData;

    // _____________________________________
    // Separação dos campos da instrução
    // _____________________________________

    // Aqui dividimos a instrução nos campos do MIPS.
    // Esses campos são usados pelo controle, banco de registradores e ULA.
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] imm;
    wire [25:0] jump_addr;

    assign opcode    = instruction[31:26];
    assign rs        = instruction[25:21];
    assign rt        = instruction[20:16];
    assign rd        = instruction[15:11];
    assign shamt     = instruction[10:6];
    assign funct     = instruction[5:0];
    assign imm       = instruction[15:0];
    assign jump_addr = instruction[25:0];

    // _____________________________________
    // Sinais gerados pela unidade de controle
    // _____________________________________

    wire RegDst;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire BranchNE;
    wire Jump;
    wire Jal;

    wire ZeroExtend;
    wire Lui;

    wire ALUCtrlSrc;
    wire [3:0] ALUControlDirect;

    wire [1:0] ALUOp;

    // _____________________________________
    // Fios auxiliares usados no caminho de dados
    // _____________________________________

    wire [4:0] WriteAddr;
    wire [31:0] WriteData;

    wire [31:0] SignExtImm;
    wire [31:0] ZeroExtImm;
    wire [31:0] ExtImm;
    wire [31:0] LuiResult;

    wire [31:0] ALUIn2;

    wire [31:0] PCPlus4;
    wire [31:0] BranchAddr;
    wire [31:0] JumpAddr;
    wire [31:0] PCAfterBranch;
    wire [31:0] PCAfterJump;

    wire BranchTaken;
    wire Jr;
    wire RegWriteFinal;

    // _____________________________________
    // Tratamento do imediato
    // _____________________________________

    // Algumas instruções usam o imediato com sinal, como addi, lw, sw, beq e bne.
    assign SignExtImm = {{16{imm[15]}}, imm};

    // Outras usam o imediato completando com zero, como andi, ori e xori.
    assign ZeroExtImm = {16'd0, imm};

    // A unidade de controle escolhe qual tipo de extensão será usado.
    assign ExtImm = (ZeroExtend) ? ZeroExtImm : SignExtImm;

    // No lui, o imediato vai para a parte alta do registrador.
    assign LuiResult = {imm, 16'h0000};

    // _____________________________________
    // Entrada da ULA
    // _____________________________________

    // A segunda entrada da ULA pode vir do registrador ou do imediato.
    // Isso depende do tipo da instrução.
    assign ALUIn2 = (ALUSrc) ? ExtImm : ReadData2;

    // _____________________________________
    // Escolha do registrador que receberá o resultado
    // _____________________________________

    // No jal, o resultado vai para o registrador 31, que é o $ra.
    // Em instruções tipo R, o destino é rd.
    // Em várias instruções tipo I, o destino é rt.
    assign WriteAddr = (Jal) ? 5'd31 :
                       (RegDst) ? rd :
                       rt;

    // _____________________________________
    // Escolha do controle final da ULA
    // _____________________________________

    // Algumas instruções têm controle direto da ULA.
    // Já as instruções tipo R usam o funct, passando pela ula_ctrl.
    assign ALUControlFinal = (ALUCtrlSrc) ? ALUControlDirect : ALUControlFromFunct;

    // _____________________________________
    // Valor que será escrito no banco de registradores
    // _____________________________________

    // Aqui escolhemos o que volta para o banco de registradores.
    // Pode ser PC+4 no jal, o resultado do lui, dado da memória ou resultado da ULA.
    // No teste do professor, o jal precisa salvar PC+4 no $ra.
    assign WriteData = (Jal) ? PCPlus4 :
                       (Lui) ? LuiResult :
                       (MemtoReg) ? MemReadData :
                       ALUResult;

    // _____________________________________
    // Cálculo do próximo PC
    // _____________________________________

    // Normalmente o PC só anda para a próxima instrução.
    assign PCPlus4 = PC + 4;

    // Endereço usado quando acontece um branch.
    assign BranchAddr = PCPlus4 + (SignExtImm << 2);

    // Endereço usado nas instruções de jump.
    assign JumpAddr = {PCPlus4[31:28], jump_addr, 2'b00};

    // beq desvia quando a ULA indica zero.
    // bne desvia quando a ULA não indica zero.
    assign BranchTaken = (Branch & Zero) | (BranchNE & ~Zero);

    // Primeiro escolhemos entre seguir normal ou fazer branch.
    assign PCAfterBranch = (BranchTaken) ? BranchAddr : PCPlus4;

    // Depois escolhemos se vai ter jump.
    assign PCAfterJump = (Jump) ? JumpAddr : PCAfterBranch;

    // O jr é identificado pelo opcode de tipo R e pelo funct específico.
    assign Jr = (opcode == 6'b000000) && (funct == 6'b001000);

    // Se for jr, o próximo PC vem do registrador rs.
    // Caso contrário, segue a lógica normal.
    assign nextPC = (Jr) ? ReadData1 : PCAfterJump;

    // Como jr só muda o PC, ele não deve escrever no banco de registradores.
    assign RegWriteFinal = RegWrite & ~Jr;

    // _____________________________________
    // PC
    // _____________________________________

    pc pc0(
        .clk(clk),
        .reset(reset),
        .nextPC(nextPC),
        .PC(PC)
    );

    // _____________________________________
    // Memória de instruções
    // _____________________________________

    // A instrução atual é buscada usando o valor do PC.
    i_mem imem0(
        .addr(PC),
        .i_out(instruction),
        .instruction()
    );

    // _____________________________________
    // Unidade de controle
    // _____________________________________

    // A unidade de controle olha o opcode e ativa os sinais necessários.
    ctrl ctrl0(
        .opcode(opcode),

        .RegDst(RegDst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .BranchNE(BranchNE),
        .Jump(Jump),
        .Jal(Jal),

        .ZeroExtend(ZeroExtend),
        .Lui(Lui),

        .ALUCtrlSrc(ALUCtrlSrc),
        .ALUControlDirect(ALUControlDirect),

        .ALUOp(ALUOp)
    );

    // _____________________________________
    // Banco de registradores
    // _____________________________________

    // O banco de registradores lê rs e rt.
    // Quando permitido, escreve o resultado no registrador escolhido.
    regfile regfile0(
        .ReadAddr1(rs),
        .ReadAddr2(rt),

        .ReadData1(ReadData1),
        .ReadData2(ReadData2),

        .Clock(clk),
        .Reset(reset),

        .WriteAddr(WriteAddr),
        .WriteData(WriteData),

        .RegWrite(RegWriteFinal)
    );

    // _____________________________________
    // Controle da ULA
    // _____________________________________

    // Esse módulo usa o ALUOp e o funct para definir a operação da ULA.
    ula_ctrl alu_ctrl0(
        .ALUOp(ALUOp),
        .funct(funct),
        .OP(ALUControlFromFunct)
    );

    // _____________________________________
    // ULA
    // _____________________________________

    // A ULA faz as operações aritméticas, lógicas, comparações e shifts.
    ula ula0(
        .In1(ReadData1),
        .In2(ALUIn2),
        .shamt(shamt),
        .OP(ALUControlFinal),

        .result(ALUResult),
        .Zero_flag(Zero)
    );

    // _____________________________________
    // Memória de dados
    // _____________________________________

    // A memória de dados é usada principalmente nas instruções lw e sw.
    d_mem dmem0(
        .clk(clk),

        .MemRead(MemRead),
        .MemWrite(MemWrite),

        .addr(ALUResult),
        .write_data(ReadData2),

        .read_data(MemReadData)
    );

    // _____________________________________
    // Saídas para acompanhar no testbench
    // _____________________________________

    assign debug_pc = PC;
    assign debug_instruction = instruction;
    assign debug_alu_result = ALUResult;
    assign debug_mem_data = MemReadData;

endmodule
