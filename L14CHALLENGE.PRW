#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'

//? Posições do Array
    static nCodigo  := 1
    static nDesc    := 2
    static nTipo    := 3
    static nUM      := 4
    static nPreco   := 5
    static nAtivo   := 6

/*/{Protheus.doc} LoadProd
    Rotina de carregamento de arquivo .CSV e cadastro no Protheus.
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @see [Terminal de Informação](https://terminaldeinformacao.com/2021/12/16/como-fazer-a-importacao-de-um-arquivo-csv-ou-txt-via-advpl/)
    /*/
User Function LoadProd()
    local aArea     := GetArea()
    private cFile   := ''

    //? Função para a abertura/salvamento de arquivos no Windows (parâmetro .T. indica SaveFile).
    cFile := tFileDialog("CSV Files(*.csv)", 'Seleção de Arquivos',,, .F.)

    if !Empty(cFile)

        //? Executa a função de importação de produtos somente se o arquivo for exatamente na extensão csv.
        if File(cFile) .and. upper(substr(cFile, RAt('.', cFile) + 1, 3)) == "CSV"
            Processa({|| ComProd() }, "Importando dados...")
        else
            MSGSTOP("Arquivo e/ou extensão inválida!", "Atenção")
        endif

    endif

    RestArea(aArea)
Return 

/*/{Protheus.doc} ComProd
    "Commit Product" - Função para fazer a leitura do arquivo .csv válido e a gravação no banco de dados.
    @type Function
    @author Edison Cake
    @since 05/05/2023
/*/
Static Function ComProd()

    local cLine := ""
    local aLine := {}
    local oFile := FwFileReader():New(cFile)

    //? Variáveis a serem atribuídas com as informações do arquivo .CSV.
    local cCod      := ""
    local cDesc     := ""
    local cTipo     := ""
    local cUM       := ""
    local nValor    := 0
    local cAtivo    := ""

    //? Verifica se foi possível abrir o arquivo.
    if oFile:Open()

        //? Verifica se o arquivo não está vazio.
        if !oFile:Eof()
            while oFile:HasLine()

                //? É atribuída a linha do arquivo ä uma variável de texto, e após, a mesma é transformada em array.
                cLine := oFile:GetLine()
                aLine := strtokarr(cLine, ";")

                //? Cada informação é atribuída à uma variável correspondente.
                cCod := aLine[nCodigo]
                cDesc := SubsTr(aLine[nDesc], 1, 30)
                cTipo := aLine[nTipo]
                cUM := aLine[nUM]
                nValor := val(aLine[nPreco])
                cAtivo := aLine[nAtivo]

                //? Aqui é verificado se não é o cabeçalho do arquivo, se o mesmo está ativo e se a descrição é valida.
                //? Se sim, é chamada a rotina para fazer a gravação das informações.
                if lower(cCod) != "codigo" .and. cAtivo != "I" .and. alltrim(cDesc) != "."
                    NewProd(cCod, cDesc, cTipo, cUM, nValor)
                endif

            end do
        else
            MsgStop("Eu sou uma piada pra você? O arquivoi está vazio!", "Ah pronto...")
        endif
    else
        MsgStop("O arquivo não pode ser aberto.", "Ah não...! :(")
    endif

    oFile:Close()
    FwAlertInfo("Produtos cadastrados com sucesso!", "Concluído!")


Return 

/*/{Protheus.doc} NewProd
    Função de rotina automática para a gravação de(s) produtos importador por .csv que foram passados por parâmetro.
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @param cCod, Caractere, Código do produto a ser adicionado.
    @param cDesc, Caractere, Descrição do produto a ser adicionado.
    @param cTipo, Caractere, Tipo do produto a ser adicionado.
    @param cUM, Caractere, Unidade de medida do produto a ser adicionado.
    @param nValor, Numerico, Valor do produto a ser adicionado.
/*/
Static Function NewProd(cCod, cDesc, cTipo, cUM, nValor)
    local aDados := {}
    local nOper  := 3 //? Operação de Inclusão
    private lMsErroAuto := .F.

    //? A preparação do ambiente auxilia para que não precisemos abrir o Protheus para realizar a busca pelas informações.
    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    //? Adicionados os dados em um array para que os mesmos sejam gravados no banco de dados.
    aAdd(aDados, {'B1_FILIAL',  FwFilial('SB1'), NIL})
    aAdd(aDados, {'B1_COD',  cCod, NIL})
    aAdd(aDados, {'B1_DESC',  cDesc, NIL})
    aAdd(aDados, {'B1_TIPO',  cTipo, NIL})
    aAdd(aDados, {'B1_UM',  cUM, NIL})
    aAdd(aDados, {'B1_PRV1',  nValor, NIL})
    aAdd(aDados, {'B1_LOCPAD',  '01', NIL})

    //? Função MsExecAuto que executa a rotina automática com base na operação pré-definida (nesse caso, inclusão).
    MsExecAuto({|x, y| MATA010(x, y)}, aDados, nOper)

    if lMsErroAuto
        MostraErro()
    endif
Return 
