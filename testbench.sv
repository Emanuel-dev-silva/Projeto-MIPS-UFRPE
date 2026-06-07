module testbench;


// _____________________________________
// Teste do PC
// _____________________________________

reg clk;
reg reset;
reg [31:0] nextPC;

wire [31:0] PC;

pc pc_test(
    .clk(clk),
    .reset(reset),
    .nextPC(nextPC),
    .PC(PC)
);


// _____________________________________
// Teste da ULA
// _____________________________________

reg [31:0] In1;
reg [31:0] In2;
reg [3:0] OP;

wire [31:0] result;
wire Zero_flag;

ula ula_test(
    .In1(In1),
    .In2(In2),
    .OP(OP),
    .result(result),
    .Zero_flag(Zero_flag)
);


// _____________________________________
// Teste da ULA Control
// _____________________________________

reg [1:0] ALUOp;
reg [5:0] funct;

wire [3:0] ALUControlOut;

ula_ctrl ula_ctrl_test(
    .ALUOp(ALUOp),
    .funct(funct),
    .OP(ALUControlOut)
);


// _____________________________________
// Teste da Unidade de Controle
// _____________________________________

reg [5:0] opcode;

wire RegDst;
wire ALUSrc;
wire MemtoReg;
wire RegWrite_ctrl;
wire MemRead;
wire MemWrite;
wire Branch;

wire [1:0] ALUOp_ctrl;

ctrl ctrl_test(
    .opcode(opcode),

    .RegDst(RegDst),
    .ALUSrc(ALUSrc),
    .MemtoReg(MemtoReg),
    .RegWrite(RegWrite_ctrl),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),

    .ALUOp(ALUOp_ctrl)
);


// _____________________________________
// Teste da memória de instruções
// _____________________________________

reg [31:0] instruction_addr;
wire [31:0] instruction;

i_mem i_mem_test(
    .addr(instruction_addr),
    .instruction(instruction)
);


// _____________________________________
// Teste do banco de registradores
// _____________________________________

reg [4:0] ReadAddr1;
reg [4:0] ReadAddr2;

wire [31:0] ReadData1;
wire [31:0] ReadData2;

reg [4:0] WriteAddr;
reg [31:0] WriteData;
reg RegWrite;

regfile regfile_test(
    .ReadAddr1(ReadAddr1),
    .ReadAddr2(ReadAddr2),

    .ReadData1(ReadData1),
    .ReadData2(ReadData2),

    .Clock(clk),
    .Reset(reset),

    .WriteAddr(WriteAddr),
    .WriteData(WriteData),

    .RegWrite(RegWrite)
);


// _____________________________________
// Teste do MIPS integrado
// _____________________________________

wire [31:0] debug_pc;
wire [31:0] debug_instruction;
wire [31:0] debug_alu_result;

mips mips_test(
    .clk(clk),
    .reset(reset),

    .debug_pc(debug_pc),
    .debug_instruction(debug_instruction),
    .debug_alu_result(debug_alu_result)
);


// _____________________________________
// Geração do clock
// _____________________________________

always #5 clk = ~clk;


// _____________________________________
// Sequência de testes
// _____________________________________

initial
begin

    $display("_____________________________________");
    $display("Iniciando os testes");
    $display("_____________________________________");

    clk = 0;
    reset = 1;

    nextPC = 0;

    RegWrite = 0;
    WriteAddr = 0;
    WriteData = 0;

    ReadAddr1 = 0;
    ReadAddr2 = 0;

    instruction_addr = 0;

    #10;

    reset = 0;

    // Testando atualização do PC

    nextPC = 4;
    #10;

    nextPC = 8;
    #10;

    $display("Valor atual do PC = %d", PC);

    // Escrevendo em R5 e lendo em seguida

    WriteAddr = 5;
    WriteData = 123;
    RegWrite = 1;

    #10;

    RegWrite = 0;

    ReadAddr1 = 5;

    #2;

    $display("Valor armazenado em R5 = %d", ReadData1);

    // Testes básicos da ULA

    In1 = 10;
    In2 = 5;

    OP = 4'b0000;

    #2;

    $display("Resultado ADD = %d", result);

    OP = 4'b0001;

    #2;

    $display("Resultado SUB = %d", result);

    OP = 4'b0011;

    #2;

    $display("Resultado OR = %d", result);

    OP = 4'b0110;

    In1 = 3;
    In2 = 10;

    #2;

    $display("Resultado SLT = %d", result);

    // Testes da ULA Control

    ALUOp = 2'b10;
    funct = 6'b100000;

    #2;

    $display("ULA_CTRL ADD = %b", ALUControlOut);

    funct = 6'b100010;

    #2;

    $display("ULA_CTRL SUB = %b", ALUControlOut);

    funct = 6'b100100;

    #2;

    $display("ULA_CTRL AND = %b", ALUControlOut);

    // Testes da Unidade de Controle

    opcode = 6'b000000;

    #2;

    $display("CTRL R_TYPE -> RegDst=%b RegWrite=%b ALUOp=%b",
             RegDst, RegWrite_ctrl, ALUOp_ctrl);

    opcode = 6'b100011;

    #2;

    $display("CTRL LW -> MemRead=%b MemtoReg=%b RegWrite=%b",
             MemRead, MemtoReg, RegWrite_ctrl);

    opcode = 6'b101011;

    #2;

    $display("CTRL SW -> MemWrite=%b",
             MemWrite);

    opcode = 6'b000100;

    #2;

    $display("CTRL BEQ -> Branch=%b ALUOp=%b",
             Branch, ALUOp_ctrl);

    // Testes da memória de instruções

    instruction_addr = 0;
    #2;

    $display("I_MEM[0] = %h", instruction);

    instruction_addr = 4;
    #2;

    $display("I_MEM[1] = %h", instruction);

    instruction_addr = 8;
    #2;

    $display("I_MEM[2] = %h", instruction);

    instruction_addr = 12;
    #2;

    $display("I_MEM[3] = %h", instruction);

    // Teste do MIPS integrado

    $display("_____________________________________");
    $display("Teste do MIPS integrado");
    $display("_____________________________________");

    reset = 1;
    #10;

    reset = 0;
    #1;

    $display("MIPS -> PC=%d INSTR=%h ALU=%d",
             debug_pc, debug_instruction, debug_alu_result);

    #10;

    $display("MIPS -> PC=%d INSTR=%h ALU=%d",
             debug_pc, debug_instruction, debug_alu_result);

    #10;

    $display("MIPS -> PC=%d INSTR=%h ALU=%d",
             debug_pc, debug_instruction, debug_alu_result);

    #10;

    $display("MIPS -> PC=%d INSTR=%h ALU=%d",
             debug_pc, debug_instruction, debug_alu_result);

    $display("_____________________________________");
    $display("Fim dos testes");
    $display("_____________________________________");

    $finish;

end

endmodule
