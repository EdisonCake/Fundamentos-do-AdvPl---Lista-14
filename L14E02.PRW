#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} AltCust
    Rotina autom�tica para altera��o de cadastro de clientes.
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @version 1.0
    /*/
User Function AltCust()
    local aDados := {}
    local nOper  := 4 //? Opera��o de Altera��o
    local lOK    := .T.

    //? Passado o c�digo em uma vari�vel para facilitar a manuten��o (pregui�a de alterar no fonte).
    local cCodigo := '00000T'

    private lMsErroAuto := .F.

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    DbSelectArea('SA1')
    DbSetOrder(1)

    //? Caso o programa n�o encotnre o registro, � informado.
    if !SA1->(MSSEEK(xFilial('SA1') + cCodigo))
        lOK := .F.
        MsgInfo('N�o foi encontradoo o registro informado.')
    endif

    //? Se o retorno acima for ignorado/positivo, a opera��o de altera��o ser� executada.
    if lOK
        //? Informa��es para identificar o registro que ser� alterado.
        aAdd(aDados, {'A1_FILIAL',  FwFilial('SA1'), NIL})
        aAdd(aDados, {'A1_COD',     cCodigo, NIL})
        aAdd(aDados, {'A1_LOJA',    '01', NIL})

        //! Informa��es que ser�o alteradas (� a proposta do exerc�cio).
        aAdd(aDados, {'A1_END',     'AV. TESTE 2', NIL})
        aAdd(aDados, {'A1_TEL',     '888888888', NIL})

        MsExecAuto({|x, y| MATA030(x, y)}, aDados, nOper)
    endif

    if lMsErroAuto
        MostraErro()
    endif

Return 
