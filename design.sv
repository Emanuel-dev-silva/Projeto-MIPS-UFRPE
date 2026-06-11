// _____________________________________
// Projeto MIPS Monociclo
// Arquitetura e Organização de Computadores
// UFRPE
//
// Esse arquivo junta os módulos principais
// do processador MIPS que estamos montando.
// _____________________________________


// _____________________________________
// PC
//
// O PC guarda o endereço da instrução atual.
// A cada subida do clock ele recebe o próximo
// endereço. Se reset estiver ligado, volta para 0.
// _____________________________________

module pc(
    input clk,
    input reset,
    input [31:0] nextPC,
    output reg [31:0] PC
);

always @(posedge clk)
begin
    if(reset)
        PC <= 32'd0;
    else
        PC <= nextPC;
end

endmodule


// _____________________________________
// Banco de Registradores
//
// Aqui ficam os 32 registradores do MIPS.
// Dá para ler dois registradores ao mesmo tempo
// e escrever em um registrador na subida do clock.
// O registrador 0 não pode ser alterado.
// _____________________________________

module regfile(
    input [4:0] ReadAddr1,
    input [4:0] ReadAddr2,

    output [31:0] ReadData1,
    output [31:0] ReadData2,

    input Clock,
    input Reset,

    input [4:0] WriteAddr,
    input [31:0] WriteData,

    input RegWrite
);

reg [31:0] regs [0:31];

integer i;

always @(posedge Clock)
begin
    if(Reset)
    begin
        for(i = 0; i < 32; i = i + 1)
            regs[i] <= 32'd0;
    end

    // Só escreve se RegWrite estiver ligado
    // e se o registrador não for o R0.
    else if(RegWrite && (WriteAddr != 0))
    begin
        regs[WriteAddr] <= WriteData;
    end
end

// As leituras são diretas, sem precisar de clock.
assign ReadData1 = regs[ReadAddr1];
assign ReadData2 = regs[ReadAddr2];

endmodule


// _____________________________________
// ULA
//
// A ULA faz as contas, operações lógicas,
// comparações e deslocamentos.
// O código OP diz qual operação ela deve fazer.
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

        // Soma
        4'b0000:
            result = In1 + In2;

        // Subtração
        4'b0001:
            result = In1 - In2;

        // AND
        4'b0010:
            result = In1 & In2;

        // OR
        4'b0011:
            result = In1 | In2;

        // XOR
        4'b0100:
            result = In1 ^ In2;

        // NOR
        4'b0101:
            result = ~(In1 | In2);

        // SLT com sinal
        4'b0110:
            result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;

        // SLTU sem sinal
        4'b0111:
            result = (In1 < In2) ? 32'd1 : 32'd0;

        // SLL
        4'b1000:
            result = In2 << shamt;

        // SRL
        4'b1001:
            result = In2 >> shamt;

        // SRA
        4'b1010:
            result = $signed(In2) >>> shamt;

        // SLLV
        4'b1011:
            result = In2 << In1[4:0];

        // SRLV
        4'b1100:
            result = In2 >> In1[4:0];

        // SRAV
        4'b1101:
            result = $signed(In2) >>> In1[4:0];

        default:
            result = 32'd0;

    endcase
end

assign Zero_flag = (result == 0);

endmodule


// _____________________________________
// Controle da ULA
//
// Esse módulo recebe o ALUOp da unidade de controle
// e o funct da instrução tipo R.
// A partir disso ele escolhe a operação da ULA.
// _____________________________________

module ula_ctrl(
    input [1:0] ALUOp,
    input [5:0] funct,

    output reg [3:0] OP
);

always @(*)
begin
    case(ALUOp)

        // Soma para lw, sw, addi etc.
        2'b00:
            OP = 4'b0000;

        // Subtração para beq e bne.
        2'b01:
            OP = 4'b0001;

        // Tipo R usa o funct.
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


// _____________________________________
// Unidade de Controle
//
// Esse módulo olha o opcode da instrução
// e gera os sinais de controle do processador.
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
    // Valores padrão
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

        // Tipo R
        6'b000000:
        begin
            RegDst     = 1;
            RegWrite   = 1;
            ALUOp      = 2'b10;
            ALUCtrlSrc = 0;
        end

        // addi
        6'b001000:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // add
        end

        // andi
        6'b001100:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0010; // and
        end

        // ori
        6'b001101:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0011; // or
        end

        // xori
        6'b001110:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            RegWrite         = 1;
            ZeroExtend       = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0100; // xor
        end

        // slti
        6'b001010:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0110; // slt
        end

        // sltiu
        6'b001011:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            RegWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0111; // sltu
        end

        // lui
        6'b001111:
        begin
            RegDst     = 0;
            RegWrite   = 1;
            Lui        = 1;
            ALUCtrlSrc = 1;
        end

        // lw
        6'b100011:
        begin
            RegDst           = 0;
            ALUSrc           = 1;
            MemtoReg         = 1;
            RegWrite         = 1;
            MemRead          = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // add
        end

        // sw
        6'b101011:
        begin
            ALUSrc           = 1;
            MemWrite         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0000; // add
        end

        // beq
        6'b000100:
        begin
            Branch           = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0001; // sub
        end

        // bne
        6'b000101:
        begin
            BranchNE         = 1;
            ALUCtrlSrc       = 1;
            ALUControlDirect = 4'b0001; // sub
        end

        // j
        6'b000010:
        begin
            Jump = 1;
        end

        // jal
        // Salva PC + 8 no registrador $31 e faz jump.
        6'b000011:
        begin
            Jump     = 1;
            Jal      = 1;
            RegWrite = 1;
        end

        default:
        begin
            // Instrução desconhecida: não faz nada.
        end

    endcase
end

endmodule


// _____________________________________
// Memória de Instruções
//
// A memória de instruções guarda o programa
// que será executado pelo processador.
//
// As instruções são carregadas de um arquivo externo
// chamado instruction.list, como pedido no projeto.
// _____________________________________

module i_mem(
    input [31:0] addr,
    output [31:0] instruction
);

reg [31:0] mem [0:255];

integer i;

initial
begin
    // Preenche tudo com NOP para evitar xxxxxxxx
    // caso o PC passe do final do programa.
    for(i = 0; i < 256; i = i + 1)
        mem[i] = 32'h00000020;

    // Carrega as instruções do arquivo externo.
$readmemh("instruction.list", mem, 0, 18);
end

assign instruction = mem[addr[31:2]];

endmodule


// _____________________________________
// Memória de Dados
//
// Essa memória é usada pelas instruções lw e sw.
// sw grava um valor nela.
// lw lê um valor dela.
// _____________________________________

module d_mem(
    input clk,

    input MemRead,
    input MemWrite,

    input [31:0] addr,
    input [31:0] write_data,

    output [31:0] read_data
);

reg [31:0] mem [0:255];

integer i;

initial
begin
    for(i = 0; i < 256; i = i + 1)
        mem[i] = 32'd0;
end

always @(posedge clk)
begin
    if(MemWrite)
        mem[addr[31:2]] <= write_data;
end

assign read_data = (MemRead) ? mem[addr[31:2]] : 32'd0;

endmodule


// _____________________________________
// Top Level do Processador
//
// Esse módulo junta tudo.
// Aqui o PC busca a instrução, a instrução é decodificada,
// os registradores são lidos, a ULA executa,
// a memória pode ser acessada e o resultado pode voltar
// para o banco de registradores.
// _____________________________________

module mips(
    input clk,
    input reset,

    output [31:0] debug_pc,
    output [31:0] debug_instruction,
    output [31:0] debug_alu_result,
    output [31:0] debug_mem_data
);

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
// Separando os campos da instrução
// _____________________________________

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
// Sinais de controle
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
// Sinais auxiliares
// _____________________________________

wire [4:0] WriteAddr;
wire [31:0] WriteData;

wire [31:0] SignExtImm;
wire [31:0] ZeroExtImm;
wire [31:0] ExtImm;
wire [31:0] LuiResult;

wire [31:0] ALUIn2;

wire [31:0] PCPlus4;
wire [31:0] PCPlus8;
wire [31:0] BranchAddr;
wire [31:0] JumpAddr;
wire [31:0] PCAfterBranch;
wire [31:0] PCAfterJump;

wire BranchTaken;
wire Jr;


// _____________________________________
// Imediatos
// _____________________________________

assign SignExtImm = {{16{imm[15]}}, imm};
assign ZeroExtImm = {16'd0, imm};

// Algumas instruções usam zero extend: andi, ori e xori.
// As demais usam sign extend.
assign ExtImm = (ZeroExtend) ? ZeroExtImm : SignExtImm;

// lui coloca o imediato nos 16 bits mais altos.
assign LuiResult = {imm, 16'h0000};


// _____________________________________
// MUXes principais
// _____________________________________

// Escolhe se a ULA usa registrador ou imediato.
assign ALUIn2 = (ALUSrc) ? ExtImm : ReadData2;

// Para jal, escreve obrigatoriamente no registrador $31.
// Tipo R escreve em rd. Tipo I escreve em rt.
assign WriteAddr = (Jal) ? 5'd31 :
                   (RegDst) ? rd :
                   rt;

// Escolhe se o controle da ULA vem da ula_ctrl ou direto da ctrl.
assign ALUControlFinal = (ALUCtrlSrc) ? ALUControlDirect : ALUControlFromFunct;

// Escolhe o dado que será escrito no banco de registradores.
assign WriteData = (Jal) ? PCPlus8 :
                   (Lui) ? LuiResult :
                   (MemtoReg) ? MemReadData :
                   ALUResult;


// _____________________________________
// Cálculo do próximo PC
// _____________________________________

assign PCPlus4 = PC + 4;
assign PCPlus8 = PC + 8;

assign BranchAddr = PCPlus4 + (SignExtImm << 2);

assign JumpAddr = {PCPlus4[31:28], jump_addr, 2'b00};

// beq desvia quando Zero = 1.
// bne desvia quando Zero = 0.
assign BranchTaken = (Branch & Zero) | (BranchNE & ~Zero);

assign PCAfterBranch = (BranchTaken) ? BranchAddr : PCPlus4;

assign PCAfterJump = (Jump) ? JumpAddr : PCAfterBranch;

// jr é tipo R com funct 001000.
// Ele coloca o PC com o valor que está em R[rs].
assign Jr = (opcode == 6'b000000) && (funct == 6'b001000);

assign nextPC = (Jr) ? ReadData1 : PCAfterJump;


// _____________________________________
// Ligando os módulos
// _____________________________________

pc pc0(
    .clk(clk),
    .reset(reset),
    .nextPC(nextPC),
    .PC(PC)
);

i_mem imem0(
    .addr(PC),
    .instruction(instruction)
);

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

regfile regfile0(
    .ReadAddr1(rs),
    .ReadAddr2(rt),

    .ReadData1(ReadData1),
    .ReadData2(ReadData2),

    .Clock(clk),
    .Reset(reset),

    .WriteAddr(WriteAddr),
    .WriteData(WriteData),

    .RegWrite(RegWrite)
);

ula_ctrl alu_ctrl0(
    .ALUOp(ALUOp),
    .funct(funct),
    .OP(ALUControlFromFunct)
);

ula ula0(
    .In1(ReadData1),
    .In2(ALUIn2),
    .shamt(shamt),
    .OP(ALUControlFinal),

    .result(ALUResult),
    .Zero_flag(Zero)
);

d_mem dmem0(
    .clk(clk),

    .MemRead(MemRead),
    .MemWrite(MemWrite),

    .addr(ALUResult),
    .write_data(ReadData2),

    .read_data(MemReadData)
);


// _____________________________________
// Saídas de debug
// _____________________________________

assign debug_pc = PC;
assign debug_instruction = instruction;
assign debug_alu_result = ALUResult;
assign debug_mem_data = MemReadData;

endmodule
