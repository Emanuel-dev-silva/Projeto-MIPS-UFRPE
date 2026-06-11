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
// Arquivo: i_mem.sv
//
// Descrição:
// Implementa a memória de instruções.
// A memória é carregada a partir do arquivo
// externo instruction.list.
// O arquivo instruction.list contém instruções
// em binário, uma por linha.
// _____________________________________

module i_mem #(
    parameter MEM_SIZE = 256
)(
    input [31:0] addr,

    output [31:0] i_out,
    output [31:0] instruction
);

reg [31:0] mem [0:MEM_SIZE-1];

integer i;

initial
begin
    for(i = 0; i < MEM_SIZE; i = i + 1)
        mem[i] = 32'h00000020;

    $readmemb("instruction.list", mem, 0, 18);
end

assign i_out = mem[addr[31:2]];

// Mantive esta saída também para não quebrar o testbench atual.
assign instruction = i_out;

endmodule
