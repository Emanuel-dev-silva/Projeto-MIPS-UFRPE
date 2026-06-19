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
// Esse módulo representa a memória de instruções.
// É daqui que o processador pega a instrução atual,
// usando o valor do PC como endereço.
// As instruções ficam no arquivo instruction.list.
// _____________________________________

module i_mem #(
    parameter MEM_SIZE = 256
)(
    input [31:0] addr,

    output [31:0] i_out,
    output [31:0] instruction
);

    // Vetor usado para guardar as instruções do programa.
    // Cada posição da memória guarda uma instrução de 32 bits.
    reg [31:0] mem [0:MEM_SIZE-1];

    integer i;

    initial
    begin
        // Antes de carregar o arquivo, preenchemos a memória com uma instrução simples.
        // Isso ajuda caso o PC passe do final do programa, evitando lixo na simulação.
        for(i = 0; i < MEM_SIZE; i = i + 1)
            mem[i] = 32'h00000020;

        // Aqui carregamos o arquivo do professor.
        // O arquivo instruction.list está em binário, por isso usamos readmemb.
        // Como o teste possui 64 instruções, carregamos da posição 0 até 63.
        $readmemb("instruction.list", mem, 0, 63);
    end

    // O PC anda de 4 em 4, mas a memória é indexada por palavra.
    // Por isso usamos addr[31:2].
    // Exemplo: PC=0 acessa mem[0], PC=4 acessa mem[1].
    assign i_out = mem[addr[31:2]];

    // Mantivemos essa saída também para facilitar a visualização no testbench.
    assign instruction = i_out;

endmodule
