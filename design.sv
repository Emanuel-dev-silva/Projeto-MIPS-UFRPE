// =====================================================
// Projeto MIPS Monociclo
// Arquitetura e Organização de Computadores
// UFRPE
//
// Módulos implementados:
// - PC
// - RegFile
// - ULA
// =====================================================



// =====================================================
// PC (Program Counter)
// =====================================================

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



// =====================================================
// REGFILE
// =====================================================

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



// =====================================================
// ULA
// =====================================================

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
            result = In1 + In2; // ADD

        4'b0001:
            result = In1 - In2; // SUB

        4'b0010:
            result = In1 & In2; // AND

        4'b0011:
            result = In1 | In2; // OR

        4'b0100:
            result = In1 ^ In2; // XOR

        4'b0101:
            result = ~(In1 | In2); // NOR

        4'b0110:
            result = ($signed(In1) < $signed(In2))
                     ? 32'd1 : 32'd0; // SLT

        4'b0111:
            result = (In1 < In2)
                     ? 32'd1 : 32'd0; // SLTU

        default:
            result = 32'd0;

    endcase

end

assign Zero_flag = (result == 0);

endmodule
