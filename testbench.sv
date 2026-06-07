module testbench;


// ======================================
// TESTE DO PC
// ======================================

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


// ======================================
// TESTE DA ULA
// ======================================

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


// ======================================
// TESTE DO REGFILE
// ======================================

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


// ======================================
// CLOCK
// ======================================

always #5 clk = ~clk;


// ======================================
// TESTES
// ======================================

initial
begin

    $display("================================");
    $display("INICIO DOS TESTES");
    $display("================================");

    clk = 0;
    reset = 1;

    nextPC = 0;

    RegWrite = 0;
    WriteAddr = 0;
    WriteData = 0;

    ReadAddr1 = 0;
    ReadAddr2 = 0;

    #10;

    reset = 0;

    // ------------------------------
    // TESTE PC
    // ------------------------------

    nextPC = 4;
    #10;

    nextPC = 8;
    #10;

    $display("PC Atual = %d", PC);

    // ------------------------------
    // TESTE REGFILE
    // ------------------------------

    WriteAddr = 5;
    WriteData = 123;
    RegWrite = 1;

    #10;

    RegWrite = 0;

    ReadAddr1 = 5;

    #2;

    $display("R5 = %d", ReadData1);

    // ------------------------------
    // TESTE ULA
    // ------------------------------

    In1 = 10;
    In2 = 5;

    OP = 4'b0000;

    #2;

    $display("ADD = %d", result);

    OP = 4'b0001;

    #2;

    $display("SUB = %d", result);

    OP = 4'b0011;

    #2;

    $display("OR = %d", result);

    OP = 4'b0110;

    In1 = 3;
    In2 = 10;

    #2;

    $display("SLT = %d", result);

    $display("================================");
    $display("FIM DOS TESTES");
    $display("================================");

    $finish;

end

endmodule
