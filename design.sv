// _____________________________________
// Projeto MIPS Monociclo
// Arquitetura e Organização de Computadores
// UFRPE
//
// Módulos implementados até o momento:
// - PC
// - RegFile
// - ULA
// _____________________________________



// _____________________________________
// PC (Program Counter)
//
// Guarda o endereço da instrução atual.
// A cada borda de subida do clock o PC
// recebe o valor presente em nextPC.
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
// Banco de Registradores (RegFile)
//
// Possui 32 registradores de 32 bits.
// Leitura assíncrona.
// Escrita síncrona.
// O registrador R0 permanece sempre zero.
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

    // Impede escrita no registrador R0
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
//
// Responsável pelas operações aritméticas
// e lógicas utilizadas pelas instruções.
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

        // Soma
        4'b0000:
            result = In1 + In2;

        // Subtração
        4'b0001:
            result = In1 - In2;

        // AND lógico
        4'b0010:
            result = In1 & In2;

        // OR lógico
        4'b0011:
            result = In1 | In2;

        // XOR lógico
        4'b0100:
            result = In1 ^ In2;

        // NOR lógico
        4'b0101:
            result = ~(In1 | In2);

        // Comparação com sinal (SLT)
        4'b0110:
            result = ($signed(In1) < $signed(In2))
                     ? 32'd1 : 32'd0;

        // Comparação sem sinal (SLTU)
        4'b0111:
            result = (In1 < In2)
                     ? 32'd1 : 32'd0;

        default:
            result = 32'd0;

    endcase

end

// Flag usada em instruções como BEQ
assign Zero_flag = (result == 0);

endmodule

// _____________________________________
// Controle da ULA
//
// Traduz ALUOp + funct para o código
// utilizado pela ULA.
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

        // instruções tipo R
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
//
// Recebe o opcode da instrução e gera
// os sinais de controle do processador.
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

    // Valores padrão
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
            // Mantém valores padrão
        end

    endcase

end

endmodule

// _____________________________________
// Memória de instruções
//
// Armazena as instruções do programa.
// O endereço vem do PC.
// _____________________________________

module i_mem(
    input [31:0] addr,
    output [31:0] instruction
);

reg [31:0] mem [0:255];

// Algumas instruções de exemplo
initial
begin

    mem[0] = 32'h012A4020; // add
    mem[1] = 32'h014B4822; // sub
    mem[2] = 32'h8D280000; // lw
    mem[3] = 32'hAD280004; // sw

end

assign instruction = mem[addr[31:2]];

endmodule

// _____________________________________
// Memória de dados
//
// Utilizada pelas instruções lw e sw.
// Escrita síncrona.
// Leitura combinacional.
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
//
// Conecta os principais módulos já
// implementados no projeto.
// _____________________________________

module mips(
    input clk,
    input reset
);

wire [31:0] PC;
wire [31:0] nextPC;

wire [31:0] instruction;

assign nextPC = PC + 4;


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

i_mem imem0(
    .addr(PC),
    .instruction(instruction)
);

endmodule

