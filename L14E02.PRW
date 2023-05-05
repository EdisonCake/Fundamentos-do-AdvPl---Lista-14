#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} AltCust
    Rotina automática para alteração de cadastro de clientes.
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @version 1.0
    /*/
User Function AltCust()
    local aDados := {}
    local nOper  := 4 //? Operação de Alteração
    local lOK    := .T.

    //? Passado o código em uma variável para facilitar a manutenção (preguiça de alterar no fonte).
    local cCodigo := '00000T'

    private lMsErroAuto := .F.

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    DbSelectArea('SA1')
    DbSetOrder(1)

    //? Caso o programa não encotnre o registro, é informado.
    if !SA1->(MSSEEK(xFilial('SA1') + cCodigo))
        lOK := .F.
        MsgInfo('Não foi encontradoo o registro informado.')
    endif

    //? Se o retorno acima for ignorado/positivo, a operação de alteração será executada.
    if lOK
        //? Informações para identificar o registro que será alterado.
        aAdd(aDados, {'A1_FILIAL',  FwFilial('SA1'), NIL})
        aAdd(aDados, {'A1_COD',     cCodigo, NIL})
        aAdd(aDados, {'A1_LOJA',    '01', NIL})

        //! Informações que serão alteradas (é a proposta do exercício).
        aAdd(aDados, {'A1_END',     'AV. TESTE 2', NIL})
        aAdd(aDados, {'A1_TEL',     '888888888', NIL})

        MsExecAuto({|x, y| MATA030(x, y)}, aDados, nOper)
    endif

    if lMsErroAuto
        MostraErro()
    endif

Return 
