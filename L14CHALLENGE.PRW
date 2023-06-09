#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'

//? Posi��es do Array
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
    /*/
User Function LoadProd()
    local aArea     := GetArea()
    private cFile   := ''

    //? Fun��o para a abertura/salvamento de arquivos no Windows (par�metro .T. indica SaveFile).
    cFile := tFileDialog("CSV Files(*.csv)", 'Sele��o de Arquivos',,, .F.)

    if !Empty(cFile)

        //? Executa a fun��o de importa��o de produtos somente se o arquivo for exatamente na extens�o csv.
        if File(cFile) .and. upper(substr(cFile, RAt('.', cFile) + 1, 3)) == "CSV"
            Processa({|| ComProd() }, "Importando dados...")
        else
            MSGSTOP("Arquivo e/ou extens�o inv�lida!", "Aten��o")
        endif

    endif

    RestArea(aArea)
Return 

/*/{Protheus.doc} ComProd
    "Commit Product" - Fun��o para fazer a leitura do arquivo .csv v�lido e a grava��o no banco de dados.
    @type Function
    @author Edison Cake
    @since 05/05/2023
/*/
Static Function ComProd()

    local cLine := ""
    local aLine := {}
    local oFile := FwFileReader():New(cFile)

    //? Vari�veis a serem atribu�das com as informa��es do arquivo .CSV.
    local cCod      := ""
    local cDesc     := ""
    local cTipo     := ""
    local cUM       := ""
    local nValor    := 0
    local cAtivo    := ""

    //? Verifica se foi poss�vel abrir o arquivo.
    if oFile:Open()

        //? Verifica se o arquivo n�o est� vazio.
        if !oFile:Eof()
            while oFile:HasLine()

                //? � atribu�da a linha do arquivo � uma vari�vel de texto, e ap�s, a mesma � transformada em array.
                cLine := oFile:GetLine()
                aLine := strtokarr(cLine, ";")

                //? Cada informa��o � atribu�da � uma vari�vel correspondente.
                cCod := aLine[nCodigo]
                cDesc := SubsTr(aLine[nDesc], 1, 30)
                cTipo := aLine[nTipo]
                cUM := aLine[nUM]
                nValor := val(aLine[nPreco])
                cAtivo := aLine[nAtivo]

                //? Aqui � verificado se n�o � o cabe�alho do arquivo, se o mesmo est� ativo e se a descri��o � valida.
                //? Se sim, � chamada a rotina para fazer a grava��o das informa��es.
                if lower(cCod) != "codigo" .and. cAtivo != "I" .and. alltrim(cDesc) != "."
                    NewProd(cCod, cDesc, cTipo, cUM, nValor)
                endif

            end do
        else
            MsgStop("Eu sou uma piada pra voc�? O arquivoi est� vazio!", "Ah pronto...")
        endif
    else
        MsgStop("O arquivo n�o pode ser aberto.", "Ah n�o...! :(")
    endif

    oFile:Close()
    FwAlertInfo("Produtos cadastrados com sucesso!", "Conclu�do!")


Return 

/*/{Protheus.doc} NewProd
    Fun��o de rotina autom�tica para a grava��o de(s) produtos importador por .csv que foram passados por par�metro.
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @param cCod, Caractere, C�digo do produto a ser adicionado.
    @param cDesc, Caractere, Descri��o do produto a ser adicionado.
    @param cTipo, Caractere, Tipo do produto a ser adicionado.
    @param cUM, Caractere, Unidade de medida do produto a ser adicionado.
    @param nValor, Numerico, Valor do produto a ser adicionado.
/*/
Static Function NewProd(cCod, cDesc, cTipo, cUM, nValor)
    local aDados := {}
    local nOper  := 3 //? Opera��o de Inclus�o
    private lMsErroAuto := .F.

    //? A prepara��o do ambiente auxilia para que n�o precisemos abrir o Protheus para realizar a busca pelas informa��es.
    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    //? Adicionados os dados em um array para que os mesmos sejam gravados no banco de dados.
    aAdd(aDados, {'B1_FILIAL',  FwFilial('SB1'), NIL})
    aAdd(aDados, {'B1_COD',  cCod, NIL})
    aAdd(aDados, {'B1_DESC',  cDesc, NIL})
    aAdd(aDados, {'B1_TIPO',  cTipo, NIL})
    aAdd(aDados, {'B1_UM',  cUM, NIL})
    aAdd(aDados, {'B1_PRV1',  nValor, NIL})
    aAdd(aDados, {'B1_LOCPAD',  '01', NIL})

    //? Fun��o MsExecAuto que executa a rotina autom�tica com base na opera��o pr�-definida (nesse caso, inclus�o).
    MsExecAuto({|x, y| MATA010(x, y)}, aDados, nOper)

    if lMsErroAuto
        MostraErro()
    endif
Return 
