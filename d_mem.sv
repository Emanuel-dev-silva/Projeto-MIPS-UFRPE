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
// Arquivo: d_mem.sv
//
// Descrição:
// Implementa a memória de dados.
// É usada pelas instruções lw e sw.
// A escrita é síncrona.
// A leitura é assíncrona.
// _____________________________________

module d_mem #(
    parameter MEM_SIZE = 256
)(
    input clk,

    input MemRead,
    input MemWrite,

    input [31:0] addr,
    input [31:0] write_data,

    output [31:0] read_data
);

reg [31:0] mem [0:MEM_SIZE-1];

integer i;

initial
begin
    for(i = 0; i < MEM_SIZE; i = i + 1)
        mem[i] = 32'd0;
end

always @(posedge clk)
begin
    if(MemWrite)
        mem[addr[31:2]] <= write_data;
end

assign read_data = (MemRead) ? mem[addr[31:2]] : 32'd0;

endmodule
