#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ByeForn
    Rotina autom�tica para exclus�o de fornecedores
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @version 1.0
    /*/
User Function ByeForn()
    local aDados := {}
    local nOper  := 5 //? Opera��o de exclus�o
    local lOK    := .T.

    //? Passado o c�digo em uma vari�vel para facilitar a manuten��o (pregui�a de alterar no fonte).
    local cCodigo   := 'F00009'
    local cLoja     := ''

    private lMsErroAuto := .F.

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    DbSelectArea('SA2')
    DbSetOrder(1)

    //? Caso o programa n�o encotnre o registro, � informado.
    if !SA2->(MSSEEK(xFilial('SA2') + cCodigo))
        lOK := .F.
        MsgInfo('N�o foi encontradoo o registro informado.')
    else
        //? Atribu� em uma vari�vel por conta de um ponto de entrada que randomiza a loja do fornecedor.
        cLoja := SA2->A2_LOJA
    endif

    //? Se o retorno acima for ignorado/positivo, a opera��o de altera��o ser� executada.
    if lOK
        //? Informa��es para identificar o registro do fornecedor que ser� exclu�do.
        aAdd(aDados, {'A2_COD',     cCodigo,    NIL})
        aAdd(aDados, {'A2_LOJA',    cLoja,      NIL})

        MsExecAuto({|x, y| MATA020(x, y)}, aDados, nOper)
    endif

    if lMsErroAuto
        MostraErro()
    endif

Return 
