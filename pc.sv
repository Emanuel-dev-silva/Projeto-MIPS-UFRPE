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
// - Erick Matheus
// - João Matheus
//
// Arquivo: pc.sv
//
// Descrição:
// Implementa o contador de programa.
// O PC guarda o endereço da instrução atual.
// Em cada borda de subida do clock, recebe nextPC.
// Se reset estiver ativo, volta para zero.
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
