# Projeto MIPS Monociclo

Projeto feito para a disciplina de **Arquitetura e Organização de Computadores**, ministrada pelo professor **Vítor Coutinho**, no semestre **2026.1**.

## Integrantes

* Andrey Israel
* Emanuel Barbosa
* Érick Matheus
* João Matheus

## Sobre o projeto

Este projeto teve como objetivo implementar um processador **MIPS monociclo** em Verilog/SystemVerilog.

A gente tentou montar o processador por partes, começando pelos módulos mais básicos, como PC, banco de registradores e ULA. Depois disso, os módulos foram sendo ligados no arquivo principal do processador, o `mips.sv`.

Durante o desenvolvimento, cada parte foi sendo testada aos poucos no `testbench.sv`. Isso ajudou bastante, porque dava para ver se um módulo estava funcionando antes de juntar tudo no processador completo.

## Arquivos do projeto

O projeto foi separado em vários arquivos para ficar mais organizado:

* `design.sv`: arquivo principal, usado para incluir os outros módulos.
* `pc.sv`: módulo do contador de programa.
* `regfile.sv`: banco de registradores.
* `ula.sv`: unidade lógica e aritmética.
* `ula_ctrl.sv`: controle da ULA.
* `ctrl.sv`: unidade de controle principal.
* `i_mem.sv`: memória de instruções.
* `d_mem.sv`: memória de dados.
* `mips.sv`: módulo principal do processador.
* `testbench.sv`: arquivo usado para testar o projeto.
* `instruction.list`: arquivo com as instruções carregadas pela memória de instruções.

## Módulos implementados

### PC

O `pc` guarda o endereço da instrução atual. A cada ciclo de clock, ele recebe o próximo endereço que será executado. Quando o reset está ativo, o valor do PC volta para zero.

### RegFile

O `regfile` representa o banco de registradores do MIPS. Ele possui 32 registradores de 32 bits. O registrador zero foi tratado para continuar sempre com valor zero, como acontece no MIPS.

### ULA

A `ula` realiza as operações aritméticas, lógicas, comparações e deslocamentos. Ela recebe os operandos e um código de operação, e a partir disso gera o resultado.

### ULA Control

O módulo `ula_ctrl` recebe o `ALUOp` e o campo `funct` da instrução. Com essas informações, ele define qual operação a ULA deve executar.

### Unidade de Controle

A unidade de controle recebe o opcode da instrução e gera os sinais usados no caminho de dados, como escrita em registrador, acesso à memória, branch, jump e outros sinais necessários para executar as instruções.

### Memória de Instruções

A `i_mem` carrega as instruções a partir do arquivo `instruction.list`. Esse arquivo contém as instruções em binário, uma por linha, seguindo o formato das instruções do MIPS.

### Memória de Dados

A `d_mem` foi usada para as instruções `lw` e `sw`, permitindo leitura e escrita de dados na memória.

### Módulo MIPS

O módulo `mips` junta todos os outros módulos. Nele ficam as ligações entre PC, memória de instruções, unidade de controle, banco de registradores, ULA e memória de dados.

## Instruções implementadas

Foram implementadas instruções dos formatos R, I e J.

### Tipo R

* `add`
* `sub`
* `and`
* `or`
* `xor`
* `nor`
* `slt`
* `sltu`
* `sll`
* `srl`
* `sra`
* `sllv`
* `srlv`
* `srav`
* `jr`

### Tipo I

* `addi`
* `andi`
* `ori`
* `xori`
* `beq`
* `bne`
* `slti`
* `sltiu`
* `lui`
* `lw`
* `sw`

### Tipo J

* `j`
* `jal`

## Testes

Os testes foram feitos no arquivo `testbench.sv`.

Primeiro foram testados alguns módulos separadamente, como PC, banco de registradores, ULA, controle da ULA, unidade de controle e memória de instruções.

Depois foi feito o teste do MIPS integrado, mostrando no terminal:

* o valor atual do PC;
* a instrução sendo executada;
* o resultado da ULA;
* a saída da memória de dados.

Com esses testes, foi possível acompanhar a execução das instruções e verificar se o processador estava atualizando o PC corretamente, acessando a memória e executando os saltos e desvios.

## Como executar

O projeto foi testado no **EDA Playground**, usando **Icarus Verilog**.

Configuração usada:

* Linguagem: SystemVerilog/Verilog
* Simulador: Icarus Verilog

Para executar, basta manter os arquivos do projeto juntos no EDA Playground e rodar a simulação pelo `testbench.sv`.

O projeto foi compilado e testado sem erros e sem avisos na simulação final.

## Observações

O projeto foi desenvolvido por etapas. Primeiro foram feitos os módulos básicos, depois os testes individuais, e por fim a integração do processador completo.

A parte que exigiu mais atenção foi a atualização do PC, principalmente nas instruções de desvio e salto, como `beq`, `bne`, `j`, `jal` e `jr`.

Na memória de dados, a leitura foi feita de forma combinacional e a escrita foi feita na borda de subida do clock, para manter o comportamento estável durante os testes.

## Agradecimentos

Também usamos materiais de apoio para revisar alguns conceitos durante o desenvolvimento, principalmente sobre Verilog/SystemVerilog e circuitos digitais. Um dos canais que ajudou nos estudos foi o **WR Kits**, especialmente para reforçar a parte de lógica digital e HDL.
