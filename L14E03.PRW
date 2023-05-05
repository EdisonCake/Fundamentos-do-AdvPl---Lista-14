#INCLUDE 'TOTVS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} ByeForn
    Rotina automática para exclusão de fornecedores
    @type  Function
    @author Edison Cake
    @since 05/05/2023
    @version 1.0
    /*/
User Function ByeForn()
    local aDados := {}
    local nOper  := 5 //? Operação de exclusão
    local lOK    := .T.

    //? Passado o código em uma variável para facilitar a manutenção (preguiça de alterar no fonte).
    local cCodigo   := 'F00009'
    local cLoja     := ''

    private lMsErroAuto := .F.

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'COM'

    DbSelectArea('SA2')
    DbSetOrder(1)

    //? Caso o programa não encotnre o registro, é informado.
    if !SA2->(MSSEEK(xFilial('SA2') + cCodigo))
        lOK := .F.
        MsgInfo('Não foi encontradoo o registro informado.')
    else
        //? Atribuí em uma variável por conta de um ponto de entrada que randomiza a loja do fornecedor.
        cLoja := SA2->A2_LOJA
    endif

    //? Se o retorno acima for ignorado/positivo, a operação de alteração será executada.
    if lOK
        //? Informações para identificar o registro do fornecedor que será excluído.
        aAdd(aDados, {'A2_COD',     cCodigo,    NIL})
        aAdd(aDados, {'A2_LOJA',    cLoja,      NIL})

        MsExecAuto({|x, y| MATA020(x, y)}, aDados, nOper)
    endif

    if lMsErroAuto
        MostraErro()
    endif

Return 
