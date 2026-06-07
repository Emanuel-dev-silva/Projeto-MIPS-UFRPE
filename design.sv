// _____________________________________
// Projeto MIPS Monociclo
// Arquitetura e Organização de Computadores
// UFRPE
// _____________________________________


// _____________________________________
// PC
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
    else if(RegWrite && (WriteAddr != 0))
    begin
        regs[WriteAddr] <= WriteData;
    end
end

assign ReadData1 = regs[ReadAddr1];
assign ReadData2 = regs[ReadAddr2];

endmodule


// _____________________________________
// ULA
// _____________________________________

module ula(
    input [31:0] In1,
    input [31:0] In2,
    input [3:0] OP,

    output reg [31:0] result,
    output Zero_flag
);

always @(*)
begin
    case(OP)

        4'b0000:
            result = In1 + In2;

        4'b0001:
            result = In1 - In2;

        4'b0010:
            result = In1 & In2;

        4'b0011:
            result = In1 | In2;

        4'b0100:
            result = In1 ^ In2;

        4'b0101:
            result = ~(In1 | In2);

        4'b0110:
            result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;

        4'b0111:
            result = (In1 < In2) ? 32'd1 : 32'd0;

        default:
            result = 32'd0;

    endcase
end

assign Zero_flag = (result == 0);

endmodule


// _____________________________________
// Controle da ULA
// _____________________________________

module ula_ctrl(
    input [1:0] ALUOp,
    input [5:0] funct,

    output reg [3:0] OP
);

always @(*)
begin
    case(ALUOp)

        // lw, sw, addi
        2'b00:
            OP = 4'b0000;

        // beq
        2'b01:
            OP = 4'b0001;

        // tipo R
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

    output reg [1:0] ALUOp
);

always @(*)
begin
    RegDst   = 0;
    ALUSrc   = 0;
    MemtoReg = 0;
    RegWrite = 0;
    MemRead  = 0;
    MemWrite = 0;
    Branch   = 0;
    ALUOp    = 2'b00;

    case(opcode)

        // R-Type
        6'b000000:
        begin
            RegDst   = 1;
            RegWrite = 1;
            ALUOp    = 2'b10;
        end

        // addi
        6'b001000:
        begin
            RegDst   = 0;
            ALUSrc   = 1;
            RegWrite = 1;
            ALUOp    = 2'b00;
        end

        // lw
        6'b100011:
        begin
            ALUSrc   = 1;
            MemtoReg = 1;
            RegWrite = 1;
            MemRead  = 1;
            ALUOp    = 2'b00;
        end

        // sw
        6'b101011:
        begin
            ALUSrc   = 1;
            MemWrite = 1;
            ALUOp    = 2'b00;
        end

        // beq
        6'b000100:
        begin
            Branch = 1;
            ALUOp  = 2'b01;
        end

        default:
        begin
        end

    endcase
end

endmodule


// _____________________________________
// Memória de instruções
// _____________________________________

module i_mem(
    input [31:0] addr,
    output [31:0] instruction
);

reg [31:0] mem [0:255];

initial
begin
    mem[0] = 32'h2009000A; // addi $t1, $zero, 10
    mem[1] = 32'h200A0005; // addi $t2, $zero, 5
    mem[2] = 32'h012A4020; // add  $t0, $t1, $t2
    mem[3] = 32'h012A4822; // sub  $t1, $t1, $t2
end

assign instruction = mem[addr[31:2]];

endmodule


// _____________________________________
// Memória de dados
// _____________________________________

module d_mem(
    input clk,

    input MemRead,
    input MemWrite,

    input [31:0] addr,
    input [31:0] write_data,

    output reg [31:0] read_data
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

always @(*)
begin
    if(MemRead)
        read_data = mem[addr[31:2]];
    else
        read_data = 32'd0;
end

endmodule


// _____________________________________
// Top Level do processador
// _____________________________________

module mips(
    input clk,
    input reset,

    output [31:0] debug_pc,
    output [31:0] debug_instruction,
    output [31:0] debug_alu_result
);

wire [31:0] PC;
wire [31:0] nextPC;
wire [31:0] instruction;

wire [31:0] ReadData1;
wire [31:0] ReadData2;

wire [3:0] ALUControl;
wire [31:0] ALUResult;
wire Zero;

wire [5:0] opcode;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [5:0] funct;
wire [15:0] imm;

assign opcode = instruction[31:26];
assign rs     = instruction[25:21];
assign rt     = instruction[20:16];
assign rd     = instruction[15:11];
assign imm    = instruction[15:0];
assign funct  = instruction[5:0];

wire RegDst;
wire ALUSrc;
wire MemtoReg;
wire RegWrite;
wire MemRead;
wire MemWrite;
wire Branch;

wire [1:0] ALUOp;

wire [4:0] WriteAddr;
wire [31:0] WriteData;

wire [31:0] SignExtImm;
wire [31:0] ALUIn2;

assign SignExtImm = {{16{imm[15]}}, imm};
assign ALUIn2 = (ALUSrc) ? SignExtImm : ReadData2;

assign WriteAddr = (RegDst) ? rd : rt;
assign WriteData = ALUResult;

assign nextPC = PC + 4;

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
    .OP(ALUControl)
);

ula ula0(
    .In1(ReadData1),
    .In2(ALUIn2),
    .OP(ALUControl),

    .result(ALUResult),
    .Zero_flag(Zero)
);

assign debug_pc = PC;
assign debug_instruction = instruction;
assign debug_alu_result = ALUResult;

endmodule
