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
// Arquivo: regfile.sv
//
// Descrição:
// Implementa o banco de registradores do MIPS.
// São 32 registradores de 32 bits.
// As leituras são assíncronas.
// A escrita acontece na borda de subida do clock.
// O registrador zero sempre permanece com valor zero.
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
