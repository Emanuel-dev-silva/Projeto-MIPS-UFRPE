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
// Implementa o núcleo MIPS monociclo.
// Integra PC, memória de instruções, controle,
// banco de registradores, ULA e memória de dados.
// Também calcula desvios, saltos, jr e jal.
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
wire RegWriteFinal;

assign SignExtImm = {{16{imm[15]}}, imm};
assign ZeroExtImm = {16'd0, imm};

assign ExtImm = (ZeroExtend) ? ZeroExtImm : SignExtImm;

assign LuiResult = {imm, 16'h0000};

assign ALUIn2 = (ALUSrc) ? ExtImm : ReadData2;

assign WriteAddr = (Jal) ? 5'd31 :
                   (RegDst) ? rd :
                   rt;

assign ALUControlFinal = (ALUCtrlSrc) ? ALUControlDirect : ALUControlFromFunct;

assign WriteData = (Jal) ? PCPlus8 :
                   (Lui) ? LuiResult :
                   (MemtoReg) ? MemReadData :
                   ALUResult;

assign PCPlus4 = PC + 4;
assign PCPlus8 = PC + 8;

assign BranchAddr = PCPlus4 + (SignExtImm << 2);

assign JumpAddr = {PCPlus4[31:28], jump_addr, 2'b00};

assign BranchTaken = (Branch & Zero) | (BranchNE & ~Zero);

assign PCAfterBranch = (BranchTaken) ? BranchAddr : PCPlus4;

assign PCAfterJump = (Jump) ? JumpAddr : PCAfterBranch;

assign Jr = (opcode == 6'b000000) && (funct == 6'b001000);

assign nextPC = (Jr) ? ReadData1 : PCAfterJump;

// jr não deve escrever em registrador.
assign RegWriteFinal = RegWrite & ~Jr;

pc pc0(
    .clk(clk),
    .reset(reset),
    .nextPC(nextPC),
    .PC(PC)
);

i_mem imem0(
    .addr(PC),
    .i_out(instruction),
    .instruction()
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

    .RegWrite(RegWriteFinal)
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

assign debug_pc = PC;
assign debug_instruction = instruction;
assign debug_alu_result = ALUResult;
assign debug_mem_data = MemReadData;

endmodule
