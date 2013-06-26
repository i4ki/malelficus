---
layout: page
title: Documentation
---

 * 1 - [Introdução](#introducao)
   * 1.1 - [O que são arquivos ELF?](#arquivoself)
 * 2 - [Projeto libmalelf](#libmalelf)
   * 2.1 - [Build](#build)
   * 2.2 - [Organização](#organizacao)
   * 2.3 - [Módulo Binary](#modulobinary)
     * 2.3.1 - [Hello libmalelf!](#hellolibmalelf)
     * 2.3.2 - [Pegando o nome das seções](#nomessecoes)
   * 2.4 - [Análise de binários](#analisebinario)
     * 2.4.1 - [ELF Header](#elfheader)
     * 2.4.2 - [Program Header Table](#pht)
     * 2.4.3 - [Section Header Table](#sht)
   * 2.5 - [Módulo Infect](#moduloinfect)
   * 2.6 - [Reportando informações](#report)
     * 2.6.1 - [Arquivos XML](#xml)
     * 2.6.2 - [Stdout](#stdout)
   * 2.7 - [Módulo de Debug](#modulodebug)
 * 3 - [Projeto malelf](#malelf)
   * 3.1 - [Build do malelf](#buildmalelf)
   * 3.2 - [Usando o módulo dissect](#dissect)
   * 3.3 - [Usando o módulo infect](#infect)
 * 4 - [Projeto malelfgui](#malelfgui)
 * 5 - [Links](#links)
 * 6 - [Conclusão](#conclusao)

<a id="introducao"></a>
## 1 - Introdução ##

<p style="text-align:justify">O projeto <b>malelficus</b> começou a ser desenvolvido em 2011 por Tiago Natel de Moura com o objetivo de estudar o formato ELF (Executable and Linkable Format) e disseminar o conhecimento de desenvolvimento e análise de malwares para Linux no cenário nacional.</p>

<p style="text-align:justify">
Atualmente o projeto esta passando por um refactoring para corrigir bugs antigos, adicionar bugs novos e mudar um pouco de sua arquitetura inicial. Basicamente o projeto malelficus está dividido em 3 partes: <b>libmalelf</b>, <b>malelf</b> e <b>malelfgui</b>. Cada um desses projetos é apresentado separadamente, de forma detalhada, ao logo do documento.</p>

<p style="text-align:justify"> O repositório do projeto pode ser acessado no github através dos links: </p>

* **libmalelf** - https://github.com/SecPlus/libmalelf
* **malelf** - https://github.com/SecPlus/malelf
* **malelfgui** - https://github.com/SecPlus/malelfgui
* **malelficus** - https://github.com/SecPlus/malelficus

<p style="text-align:justify"> Você nesse momento deve estar se perguntando para que serve o repositório
malelficus, já que todos os projetos são separados? O Malelficus é o agregador, ele linka e faz build dos outros três projetos.</p>

<a id="arquivoself"></a>
### 1.1 - O que são arquivos ELF? ###

<p style="text-align:justify">O objetivo desse documento não é ensinar o formato ELF, e sim apresentar o projeto <b>malelficus</b>. Por isso, deduzimos que o leitor tenha conhecimento prévio sobre ELF para ler esse documento. Entretanto, retiramos uma parte do documento DissecandoELF.txt (escrito por Felipe Pena (sigsegv) e publicado na Cogumelo Binário 1) explicando o que são arquivos ELF para dar uma visão geral.
</p>
<p style="text-align:justify">  O ELF (Executable and Linking Format) nada mais é do que um formato padrão de arquivo executável, código objeto, objeto compartilhado, e core dumps. Em 1999 ele foi adotado como formato de arquivo binário para Unix e unix-like em x86 pelo projeto 86open. [1] Sua primeira aparição foi no Solaris 2.0 (o conhecido SunOS 5.0), que é baseado no SVR4. [2]</p>

<p> Para maiores informações verificar os Links no final do documento.</p>

<a id="libmalelf"></a>
## 2 - Libmalelf ##

<p style="text-align:center"> <i> "The libmalelf is an evil library that could be used for good! It was
developed with the intent to assist in the process of infecting binaries and
provide a safe way to analyze malwares". </i> </p>
<p style="text-align:justify">
O objetivo principal da biblioteca é facilitar o estudo de arquivos binários ELF, e ajudar no entendimento, comportamento e funcionamento e com isso permitir a realização de uma análise aprofundada de arquivos maliciosos. Através dessa análise, é possível combater pragas virtuaise efetuar respostas a incidentes de forma mais rápida e efetiva. </p>

Com a **libmalelf**, é possível:

  * Analisar e infectar binários ELF;
  * Dissecar a estrutura de dados ELF;
  * Adicionar segmentos/seções de conteúdo e cabeçalhos no binário;
  * Modificar qualquer informação de um arquivo ELF;
  * Identificar vetores de ataque;
  * Encontrar "buracos" ou lacunas para inserção de código;
  * Criar o seu próprio arquivo binário a partir do zero.

<a id="build"></a>
### 2.1 Build ###

  Para baixar o código fonte é necessário que você tenha o git instalado.

    $ git clone https://github.com/SecPlus/libmalelf.git

Dependências:

- NASM
- libxml2-dev
- libcunit1-dev (opcional)

Caso sua distribuição Linux seja baseada em Debian:

    $ git clone https://github.com/SecPlus/libmalelf.git
    $ sudo apt-get install nasm libxml2-dev libcunit1-dev
    $ ./configure --prefix=/usr --enable-tests
    $ make
    $ make check

Pronto! Agora você já tem a libmalelf em sua máquina e podemos começar a
programar.

<a id="organizacao"></a>
### 2.2 Organização ###

Vamos demonstrar como está organizado o código do projeto no github.

<pre><code>libmalelf/
--+-------
  |
  +-- src/
  |    |-- binary.c
  |    |-- ehdr.c
  |    |-- phdr.c
  |    |-- shdr.c
  |    |-- debug.c
  |    |-- report.c
  |    |-- error.c
  |    |-- infect.c
  |    |-- table.c
  |    |-- util.c
  |    +-- include/
  |          |-- malelf/
  |               |-- HEADERS FILES
  |
  +-- examples/
  |    |-- CODE EXAMPLES
  |
  +-- tests/
       |-- TEST FILES
</code></pre>


  Vamos explicar resumidamente a função de cada módulo dentro do projeto.

- **Módulo binary**: responsável por armazenar todas as informações do binário ELF.
- **Módulo ehdr**: Armazena as informações do ELF Header.
- **Módulo phdr**: Armazena as informações do Program Header Table.
- **Módulo shdr**: Armazena as informações do Section Header Table.
- **Módulo debug**: Implementa a parte de debug da biblioteca.
- **Módulo report**: Módulo responsável por gerar as informações no formato XML.
- **Módulo error**: Faz o mapeamento das mensagens de erro.
- **Módulo infect**: Implementa os métodos de infecção.
- **Módulo table**: Módulo responsável por gerar as informações na shell.
- **Módulo util**: Implementações utilitárias.

<a id="modulobinary"></a>
### 2.3 Módulo Binary ###

<p style="text-align:justify"> O módulo binary é constituido por dois arquivos: <b>binary.c</b> e <b>binary.h</b>. Podemos dizer que este é o principal módulo da biblioteca, pois ele é o responsável por armazenar todas as informações do binário. Abaixo segue como ele está definido dentro da biblioteca. </p>

<pre><code>typedef struct {
        char *fname;         /* Binary filename */
        char *bkpfile;       /* Filename of backup'ed file in case of
                                write operations */
        _i32 fd;             /* Binary file descriptor */
        _u8 *mem;            /* Binary content */
        _u32 size;           /* Binary size */
        MalelfEhdr ehdr;     /* ELF Header */
        MalelfPhdr phdr;     /* Elf Program Headers */
        MalelfShdr shdr;     /* Elf Section Headers */
        _u8 alloc_type;      /* System function used to allocate memory */
        _u32 class;          /* Binary arch */

} MalelfBinary;
</code></pre>

- **fname:** Nome do binário que iremos trabalhar. Exemplo: **/bin/ls.**;
- **bkpfile:** Backup file;
- **fd**: File descriptor;
- **mem**: Conteúdo do binário;
- **size**: Tamanho do binário;
- **ehdr**: Armazena as informações relacionadas ao ELF Header;
- **phdr**: Armazena as informações relacionadas ao Program Header Table;
- **shdr**: Armazena as informações relacionadas ao Section Header Table;
- **alloc_type**: Como a memória será alocada, com mmap ou malloc.
- **class**: Arquitetura do binário;


Os campos **ehdr**, **shdr** e **phdr** serão apresentados de forma mais detalhada ao
longo do documento.
Para começar a utilizar a libmalelf é necessário que o programador conheça
alguns métodos básicos.
<p style="text-align:justify">O método <b>malelf_binary_init()</b> deve ser chamado antes de utilizar qualquer outra função da biblioteca. Esse método é responsável por inicializar as informações do objeto MalelfBinary.</p>
<p style="text-align:justify"> Para carregar/abrir um binário, existe o método <b>malelf_binary_open()</b>, que por default utiliza a função <b>mmap()</b> para carregar o binário na memória. Caso o programador deseje utilizar o <b>malloc()</b>, existe uma função chamada <b>malelf_binary_set_alloc_type()</b> que pode ser usada passando o parâmetro <b>MALELF_ALLOC_MALLOC</b>, como no exemplo abaixo.</p>

<pre><code>MalelfBinary bin;
malelf_binary_set_alloc_type(bin, MALELF_ALLOC_MALLOC);
</code></pre>

<p style="text-align:justify">E, por último, mas não menos importante, o programador deve chamar o método <b>malelf_binary_close()</b> passando o objeto MalelfBinary como parâmetro. </p>

<p style="text-align:justify">Demonstrar todas as funcionalidades do módulo binary é uma tarefa dificil,
até porque o projeto ainda está em desenvolvimento. Demonstramos alguns códigos de exemplo a seguir, porém a melhor maneira de conhecer o módulo é lendo seu arquivo de <i>header</i>.</p>

<a id="hellolibmalelf"></a>
#### 2.3.1 - Hello libmalelf ####

  Para iniciarmos os exemplos, vamos começar com o maior clichê do mundo da
programação.

<pre><code>#include &lt;stdio.h>
#include &lt;malelf/binary.h>

int main()
{
    MalelfBinary bin;
    malelf_binary_init(&bin);

    printf("Hello Libmalelf bin[%p]\n", &bin);
    malelf_binary_close(&bin);

    return 0;
}
</code></pre>

  Agora vamos compilar o nosso exemplo acima.


    $ git clone https://github.com/SecPlus/libmalelf.git
    $ gcc -o hello hello.c -lmalelf -Wall -Wextra -Werror
    Hello Libmalelf bin[0xbfbfd8ec]

Caso a libmalelf não seja encontrada lembre-se de exportar a variável **LD_LIBRARY_PATH** para o diretóriocorreto.

    $ export LD_LIBRARY_PATH=/home/benatto/libs/


<a id="nomessecoes"></a>
#### 2.3.2 - Pegando o nome das seções ####


 <p style="text-align:justify"> A libmalelf fornece alguns métodos que facilitam o programador pegar uma
determinada seção, <b>malelf_binary_get_section()</b>, passando o objeto <b>MalelfBinary</b>, a posição da seção e o objeto <b>MalelfSection</b> que irá armazenar as informações da seção.</p>
<p style="text-align:justify">  As informações contidas na seção podem ser acessadas diretamente pelo
programador, ou através de <i>getters</i>, como no exemplo abaixo, utilizando o método <b>malelf_binary_get_section_name()</b>; Abaixo segue o código do objeto <b>MalelfSection</b> para um melhor entendimento dos seus atributos.</p>

<pre><code>typedef struct {
       char *name;
       _u16 type;
       _u32 offset;
       _u32 size;
       MalelfShdr *shdr;

} MalelfSection;
</code></pre>

<p style="text-align:justify"> O objeto <b>MalelfShdr</b> será tratado de forma mais detalhada quando entrarmos em análise de binários ELF. O exemplo abaixo é muito simples, olhem os seguintes passos:
</p>

<p>
1 - Chama o método init: <b>malelf_binary_init()</b>;<br>
2 - Carrega o binário a ser analisado: <b>malelf_binary_open()</b>;<br>
3 - Faz um for pelo número de seçoes do binário;<br>
4 - Pega o nome das seções: <b>malelf_binary_get_section_name()</b>;<br>
5 - Imprime o nome da seção;<br>
6 - Libera a memória chamando o método <b>malelf_binary_close()</b>;<br>
</p>

<pre><code>#include &lt;stdio.h>
#include &lt;assert.h>

#include &lt;malelf/binary.h>
#include &lt;malelf/error.h>

int main()
{
    MalelfBinary bin;
    MalelfSection section;
    int error = MALELF_SUCCESS, i = 0;
    char *name = NULL;

    malelf_binary_init(&bin);

    error = malelf_binary_open("/bin/ls", &bin);
    if (MALELF_SUCCESS != error) {
            MALELF_PERROR(error);
            return 1;
    }

    /* Getting only the name of sections */
    for (i = 1; i < MALELF_ELF_FIELD(&bin.ehdr, e_shnum, error); i++) {
            error = malelf_binary_get_section_name(&bin, i, &name);
            printf("Section name: %s\n", name);
    }

    malelf_binary_close(&bin);
    return 0;
}
</code></pre>

<p style="text-align:justify"> A macro <b>MALELF_ELF_FIELD</b> retorna um campo do <b>ehdr</b>, <b>phdr</b> ou <b>shdr</b>. No caso acima está retornando o campo <b>e_shnum</b> do ELF Header.</p>

<a id="analisebinario"></a>
### 2.4 - Análise de binários ###

<p style="text-align:justify"> A libmalelf fornece <i>getters</i> para acessar as informações do <b>ELF Header</b>, <b>Program Header Table</b> e do <b>Section Header Table</b>. Porém, se o programador não gosta de acessar os campos através de getters, o acesso pode ser feito diretamente. </p>

Vamos aos exemplos. =)

<a id="elfheader"></a>
#### 2.4.1 - ELF Header ####


<p style="text-align:justify"> As informações sobre o ELF header ficam concentradas dentro do módulo ehdr,
que é constituído pelos arquivos ehdr.h e ehdr.c. O exemplo a seguir tem o objetivo de imprimir as informações do ELF Header.</p>

<pre><code>#include &lt;stdio.h>
#include &lt;malelf/binary.h>
#include &lt;malelf/ehdr.h>
#include &lt;malelf/shdr.h>
#include &lt;malelf/phdr.h>
#include &lt;malelf/defines.h>

int main()
{
        /* Declarando os tipos */
        MalelfBinary binary;
        MalelfEhdr ehdr;
        MalelfEhdrTable me_type;
        MalelfEhdrTable me_machine;
        MalelfEhdrTable me_version;

        _i32 result;
        _u32 size;
        _u32 phentsize;
        _u32 shentsize;
        _u32 phnum;
        _u32 shnum;
        _u32 shstrndx;
        UNUSED(result);

        /* Chamando o metodo init */
        malelf_binary_init(&binary);

        /* Alterando o alloc_type*/
        malelf_binary_set_alloc_type(&binary, MALELF_ALLOC_MALLOC);

        /* Carregando o binario para a memoria */
        malelf_binary_open("/bin/ls", &binary);

        /* Pegando as informacoes do ELF Header */
        result = malelf_binary_get_ehdr(&binary, &ehdr);
        result = malelf_ehdr_get_version(&ehdr, &me_version);
        result = malelf_ehdr_get_type(&ehdr, &me_type);
        result = malelf_ehdr_get_machine(&ehdr, &me_machine);
        result = malelf_ehdr_get_ehsize(&ehdr, &size);
        result = malelf_ehdr_get_phentsize(&ehdr, &phentsize);
        result = malelf_ehdr_get_shentsize(&ehdr, &shentsize);
        result = malelf_ehdr_get_shnum(&ehdr, &shnum);
        result = malelf_ehdr_get_phnum(&ehdr, &phnum);
        result = malelf_ehdr_get_shstrndx(&ehdr, &shstrndx);

        printf("Version Name: %d\n", me_version.name);
        printf("Version Value: %d\n", me_version.value);
        printf("Version Description: %s\n", me_version.meaning);

        printf("Type Name: %d\n", me_type.name);
        printf("Type Value: %d\n", me_type.value);
        printf("Type Description: %s\n", me_type.meaning);

        printf("Machine Name: %d\n", me_machine.name);
        printf("Machine Value: %d\n", me_machine.value);
        printf("Machine Description: %s\n", me_machine.meaning);

        printf("Size: %d\n", size);
        printf("Program Header Table Entry Size: %d\n", phentsize);
        printf("Section Header Table Entry Size: %d\n", shentsize);
        printf("Number of Entries PHT: %d\n", phnum);
        printf("Number of Entries SHT: %d\n", shnum);
        printf("SHT index: %d\n", shstrndx);

        /* Liberando a memoria */
        malelf_binary_close(&binary);

        return 0;
}
</code></pre>

  Vamos explicar como funciona o exemplo abaixo:

<p>
1 - Inicializa o objeto <b>MalelfBinary</b>, chamando o método <b>init</b>;<br>
2 - Altera a forma de carregar o binário na memória;<br>
3 - Carrega o binário para a memória com o método <b>open</b>;<br>
4 - Salva o ELF header no objeto <b>ehdr</b>;<br>
5 - Pega todos os valores com os <i>getters</i>;<br>
6 - Imprime as informações na tela;<br>
7 - Libera a memória chamando o método <b>close</b>;<br>
</p>
  Simples, não? =)

<p style="text-align:justify">Reparem que não estamos verificando o retorno das funções, isso não é uma boa prática. Se fizéssemos todas as verificações, o texto ficaria muito longo. =)</p>

<a id="pht"></a>
#### 2.4.2 - Program Header Table ####


<p style="text-align:justify"> Para demonstrar como acessar as informações do <b>Program Header Table</b>,utilizaremos um código que está dentro do módulo <b>dissect</b> do projeto <b>malelf</b>. Mas já adiantando, a idéia é muito semelhante ao exemplo anterior.</p>

<p style="text-align:justify"> O objeto <b>MalelfTable</b> será tratado quando estivermos falando de como reportar as informações do binário, nesse momento pode ignorá-lo. </p>

  Seguem os passos para o nosso exemplo abaixo:

<p>1 - Salvamos o <b>phdr</b>;<br>
2 - Salvamos o <b>ehdr</b>;<br>
3 - Pegamos o campo <b>e_phnum,</b>;<br>
4 - Realizamos um loop de acordo com a quantidade de segmentos;<br>
5 - Pegamos o offset e imprimimos;
</p>

<pre><code>static _u32 _malelf_dissect_table_phdr()
{
        MalelfTable table;
        MalelfPhdr phdr;
        MalelfEhdr ehdr;
        _u32 phnum;
        _u32 value;
        unsigned int i;

        char *headers[] = {"N", "Offset", NULL};

        if (MALELF_SUCCESS != malelf_table_init(&table, 60, 9, 2)) {
                return MALELF_ERROR;
        }
        malelf_table_set_title(&table, "Program Header Table (PHT)");
        malelf_table_set_headers(&table, headers);

        /* Salvando o phdr */
        malelf_binary_get_phdr(&binary, &phdr);

        /* Salvando o ehdr */
        malelf_binary_get_ehdr(&binary, &ehdr);

        /* Pegando o campo e_phnum */
        malelf_ehdr_get_phnum(&ehdr, &phnum);

        /* Percorrendo os segmentos */
        for (i = 0; i < phnum; i++) {
                malelf_table_add_value(&table, (void *)i, MALELF_TABLE_INT);
                malelf_phdr_get_offset(&phdr, &value, i);
                malelf_table_add_value(&table, (void *)value, MALELF_TABLE_HEX);
        }

        malelf_table_print(&table);
        malelf_table_finish(&table);

        return MALELF_SUCCESS;
}
</code></pre>

<a id="sht"></a>
#### 2.4.3 - Section Header Table ####

<p style="text-align:justify"> Vamos a mais um exemplo. Agora vamos utilizar o módulo <b>shdr</b> para imprimir a informação do campo offset. Novamente, podem reparar que o processo é bem semelhante ao que já foi mostrado anteriormente. </p>

<pre><code class="C">
#include &lt;stdio.h>
#include &lt;malelf/binary.h>
#include &lt;malelf/ehdr.h>
#include &lt;malelf/shdr.h>
#include &lt;malelf/phdr.h>
#include &lt;malelf/defines.h>

int main()
{
        MalelfBinary bin;
        MalelfEhdr ehdr;
        MalelfShdr shdr;
        unsigned int i;

        _i32 result;
        _u32 shnum;
        _u32 offset;

        UNUSED(result);

        malelf_binary_init(&bin);
        malelf_binary_set_alloc_type(&bin, MALELF_ALLOC_MALLOC);
        malelf_binary_open("/bin/ls", &bin);

        result = malelf_binary_get_ehdr(&bin, &ehdr);
        result = malelf_binary_get_shdr(&bin, &shdr);
        result = malelf_ehdr_get_shnum(&ehdr, &shnum);

        printf("Number of Entries SHT: %d\n", shnum);

        for (i = 0; i < shnum; i++) {
                malelf_shdr_get_offset(&shdr, &offset, i);
                printf("Offset: 0x%08x\n", offset);
        }

        malelf_binary_close(&bin);

        return 0;
}
</code></pre>

<a id="moduloinfect"></a>
### 2.5 - Módulo Infect ###

*************************
* FIXME: Falta terminar *
*************************

<a id="report"></a>
### 2.6 - Reportando Informações ###

<p style="text-align:justify"> Existem duas formas de gerar relatórios de informações utilizando a <b>libmalelf</b>, através de arquivos <b>xml</b> ou <b>stdout</b>.</p>

<a id="xml"></a>
#### 2.6.1 - Arquivos XML ####

<p style="text-align:justify"> Para gerar as informações dentro de um arquivo XML a libmalelf dispõe de um
módulo chamado <b>report</b>. Com isso o programador pode enviar as informações do ELF Header, Section Program Table e Program Header Table para um arquivo no padrão XML.
</p>

<pre><code>#include &lt;stdio.h>
#include &lt;malelf/binary.h>
#include &lt;malelf/ehdr.h>
#include &lt;malelf/shdr.h>
#include &lt;malelf/phdr.h>
#include &lt;malelf/defines.h>
#include &lt;malelf/report.h>


int main()
{
    MalelfBinary bin;
    MalelfReport report;

    malelf_binary_init(&bin);
    malelf_binary_open("/bin/ls", &bin);
    malelf_report_open(&report, "/tmp/report.xml", MALELF_OUTPUT_XML);

    malelf_report_ehdr(&report, &bin);

    malelf_report_close(&report);
    malelf_binary_close(&bin);

    return 0;
}
</code></pre>

  Agora vamos ver como ficou a saída.

<pre><code>&lt;?xml version="1.0" encoding="UTF8"?>
&lt;MalelfBinary>
 &lt;MalelfEhdr>
  &lt;type>2&lt;/type>
  &lt;machine>3&lt;/machine>
  &lt;version>1&lt;/version>
  &lt;entry>0x0804c070&lt;/entry>
  &lt;phoff>0x00000034&lt;/phoff>
  &lt;shoff>0x0001a444&lt;/shoff>
  &lt;flags>0&lt;/flags>
  &lt;phentsize>32&lt;/phentsize>
  &lt;phnum>9&lt;/phnum>
  &lt;shentsize>40&lt;/shentsize>
  &lt;shnum>28&lt;/shnum>
  &lt;shstrndx>27&lt;/shstrndx>
 &lt;/MalelfEhdr>
</code></pre>

<a id="stdout"></a>
### 2.6.2 - Stdout ###

<p style="text-align:justify"> Para imprimir as informações formatadas no terminal, existe o módulo table, responsável por criar uma tabela ascii e imprimir na shell. Com o objeto MalelfTable, o programador consegue definir o tamanho da tabela, o título e o número de linhas e colunas. </p>

<p style="text-align:justify"> Para esse exemplo, vamos novamente pegar uma função que é utilizada dentro do projeto malelf.</p>
<p>
  1 - Chama o método init do módulo;<br>
  2 - Configura o título da tabela;<br>
  3 - Configura os headers;<br>
  4 - Pega o ELF Header;<br>
  5 - Pega os valores desejados do ELF Header;<br>
  6 - Imprime os valores utilizando o método <b>malelf_table_print()</b>;<br>
  7 - Libera o objeto table chamando o método <b>malelf_table_finish()</b>;<br>
</p>

<pre><code>#include &lt;stdio.h>
#include &lt;malelf/binary.h>
#include &lt;malelf/ehdr.h>
#include &lt;malelf/shdr.h>
#include &lt;malelf/phdr.h>
#include &lt;malelf/table.h>
#include &lt;malelf/error.h>

int main()
{
        MalelfTable table;
        MalelfBinary bin;
        MalelfEhdr ehdr;
        _u32 value;

        malelf_binary_init(&bin);
        malelf_binary_open("/bin/ls", &bin);
        char *headers[] = {"Structure Member", "Description", "Value", NULL};

        /* Parameters: MalelfTable, width, rows, columns */
        if (MALELF_SUCCESS != malelf_table_init(&table, 78, 3, 3)) {
                return MALELF_ERROR;
        }

        /* Configurando o titulo da tabela */
        malelf_table_set_title(&table, "ELF Header");

        /* Salvando os headers */
        malelf_table_set_headers(&table, headers);

        malelf_binary_get_ehdr(&bin, &ehdr);

        /*  1 - Row */
        MalelfEhdrTable me_type;
        malelf_ehdr_get_type(&ehdr, &me_type);
        malelf_table_add_value(&table, (void*)"e_type", MALELF_TABLE_STR);
        malelf_table_add_value(&table, (void*)"Object Type", MALELF_TABLE_STR);
        malelf_table_add_value(&table,
                               (void*)me_type.meaning,
                               MALELF_TABLE_STR);

        /*  2 - Row */
        MalelfEhdrTable me_version;
        malelf_ehdr_get_version(&ehdr, &me_version);
        malelf_table_add_value(&table, (void*)"e_version", MALELF_TABLE_STR);
        malelf_table_add_value(&table, (void*)"Version", MALELF_TABLE_STR);
        malelf_table_add_value(&table,
                               (void*)me_version.value,
                               MALELF_TABLE_INT);

        /*  3 - Row */
        malelf_ehdr_get_entry(&ehdr, &value);
        malelf_table_add_value(&table, (void*)"e_entry", MALELF_TABLE_STR);
        malelf_table_add_value(&table, (void*)"Entry Point", MALELF_TABLE_STR);
        malelf_table_add_value(&table, (void*)value, MALELF_TABLE_HEX);

        malelf_table_print(&table);

        malelf_table_finish(&table);
        malelf_binary_close(&bin);

        return 0;
}
</code></pre>

  E essa é a saída do nosso programa. =)

<img src="/images/table.png" align="left" height="140" width="600"><br>
<br>
<br>

<a id="modulodebug"></a>
### 2.7 - Módulo de Debug ###

<p style="text-align:justify"> Existe a possibilidade de ver as mensagens que a <b>libmalelf</b> reporta. Para isso, basta exportarmos uma váriavel de ambiente chamada <b>MALELF_DEBUG.</b> </p>

    $ export MALELF_DEBUG=1

  Lembram do nosso primeiro exemplo utilizando a libmalelf? Pois então vamos ver o que retorna da sua execução com a opção de debug ligada.

    $ ./hello

    [INFO][Fri Jun 14 00:31:47 2013][malelf_binary_init][binary.c:235] MalelfBinary structure initialized.

    Hello Libmalelf bin[0xbfc9605c]

    [INFO][Fri Jun 14 00:31:47 2013][malelf_binary_close][binary.c:409] Binary '(null)' closed

<p style="text-align:justify"> Caso você queira receber essas informações em um arquivo de log, pode
configurar a variável de ambiente <b>MALELF_DEBUG_FILE</b>. </p>

    $ export MALELF_DEBUG_FILE = /tmp/libmalelf.log

<a id="malelf"></a>
## 3 - Projeto malelf ##

<p style="text-align:justify"> O <b>malelf</b> é uma ferramenta que utiliza a libmalelf para analisar e infectar binários ELF. Nessa parte iremos apenas demonstrar como utilizar o binário, porque toda a inteligência do projeto fica dentro da libmalelf que já foi explicada anteriormente. </p>

<a id="buildmalelf"></a>
### 3.1 - Build do malelf ###

  O processo de build da ferramenta malelf é bem simples.

Dependências:
- libmalelf

    $ ./configure
    $ make
    $ sudo make install

  Agora que o malelf está em sua máquina podemos começar a fazer alguns exemplos.

<a id="dissect"></a>
### 3.2 - Usando o módulo dissect

  Agora vamos utilizar a ferramenta malelf para pegar as informações do binário.
Antes de tudo, vamos ver o help do módulo dissect.

    $ malelf dissect -h

This command display information about the ELF binary.

<pre><code>Usage: malelf dissect <options>
         -h, --help    	Dissect Help
         -i, --input   	Binary File
         -e, --ehdr    	Display ELF Header
         -s, --shdr    	Display Section Header Table
         -p, --phdr    	Display Program Header Table
         -S, --stable  	Display Symbol Table
         -f, --format  	Output Format (XML or Stdout). Default is Stdout.
         -o, --output  	Output File.

Example: malelf dissect -i /bin/ls -f xml -o /tmp/binary.xml
</code></pre>

  Mostrando o ELF Header na shell:

    $ malelf dissect -i /bin/ls -e

  Mostrando o Program Header Table na shell:

    $ malelf dissect -i /bin/ls -p

  Mostrando o Section Header Table na shell:

    $ malelf dissect -i /bin/ls -s

  Para jogar as informações em arquivos XML é simples:

    $ malelf dissect -i /bin/ls -f xml -o /tmp/bin.txt

<a id="infect"></a>
### 3.3 - Usando o módulo infect ###

****************************************
* FIXME: Faltando escrever essa parte. *
****************************************

<a id="malelfgui"></a>
## 4 - malelfgui ##

<p style="text-align:justify"> <b>malelfgui</b> é um front-end visual para o projeto malelf, utilizando Qt. Está em estágio inicial de desenvolvimento e, por isso, deixaremos essa parte para escrever em outro momento. Porém sinta-se a vontade de entrar no github e meter a mão na massa. </p>

- <a href="https://github.com/SecPlus/malelfgui">https://github.com/SecPlus/malelfgui</a>

<a id="links"></a>
## 5 - Links ##

[1] - Executable and Linkable Format
  <a href="http://en.wikipedia.org/wiki/Executable_and_Linkable_Format">http://en.wikipedia.org/wiki/Executable_and_Linkable_Format</a>

[2] - OS Dev - ELF
  <a href="http://wiki.osdev.org/ELF">http://wiki.osdev.org/ELF</a>

[3] - Dissecando ELF
  <a href="http://0fx66.com/files/zines/cogumelo-binario/edicoes/1/DissecandoELF.txt">http://0fx66.com/files/zines/cogumelo-binario/edicoes/1/DissecandoELF.txt</a>

<a id="conclusao"></a>
## 6 - Conclusão ##

<p style="text-align:justify"> O projeto <b>malelficus</b> ainda está em sua fase inicial, provavelmente com muitos bugs. A equipe de desenvolvedores do projeto ainda é pequena e com pouco tempo livre, pois a cerveja toma muito tempo dos programadores (sim, esse projeto foi feito por um bando de alcoólatras). Então sinta-se livre para ajudar de qualquer forma com o projeto, seja codando, reportando bugs ou dando ideias. Caso não tenha gostado do projeto, pode tacar tomate, xingar a irmã e até a mãe que está tudo beleza, mas se falar mal do código ai tu vai me ofender. hehehe =) </p>
