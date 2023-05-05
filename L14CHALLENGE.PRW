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
    @see [Terminal de Informa��o](https://terminaldeinformacao.com/2021/12/16/como-fazer-a-importacao-de-um-arquivo-csv-ou-txt-via-advpl/)
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

    local cCod      := ""
    local cDesc     := ""
    local cTipo     := ""
    local cUM       := ""
    local nValor    := 0
    local cAtivo    := ""

    if oFile:Open()
        if !oFile:Eof()
            while oFile:HasLine()

                cLine := oFile:GetLine()
                aLine := strtokarr(cLine, ";")
    
                cCod := aLine[nCodigo]
                cDesc := SubsTr(aLine[nDesc], 1, 30)
                cTipo := aLine[nTipo]
                cUM := aLine[nUM]
                nValor := val(aLine[nPreco])
                cAtivo := aLine[nAtivo]

                if lower(cCod) != "codigo" .and. cAtivo != "I" .and. alltrim(cDesc) != "."
                    NewProd(cCod, cDesc, cTipo, cUM, nValor)
                endif

            end do
        endif
    endif

    oFile:Close()
    FwAlertInfo("Produtos cadastrados com sucesso!", "Conclu�do!")


Return 

/*/{Protheus.doc} NewProd
    Fun��o de rotina autom�tica para a grava��o de(s) produtos importador por .csv.
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

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    aAdd(aDados, {'B1_FILIAL',  FwFilial('SB1'), NIL})
    aAdd(aDados, {'B1_COD',  cCod, NIL})
    aAdd(aDados, {'B1_DESC',  cDesc, NIL})
    aAdd(aDados, {'B1_TIPO',  cTipo, NIL})
    aAdd(aDados, {'B1_UM',  cUM, NIL})
    aAdd(aDados, {'B1_PRV1',  nValor, NIL})
    aAdd(aDados, {'B1_LOCPAD',  '01', NIL})

    MsExecAuto({|x, y| MATA010(x, y)}, aDados, nOper)

    if lMsErroAuto
        MostraErro()
    endif
Return 