#include 'topconn.ch'
#include 'protheus.ch'
#include 'parmtype.ch'

/*/
{Protheus.doc} UPDNFE01
Rotina para alterar o tipo de frete de uma nota j� faturada.
@type  Function
@author user
@since 04/06/2020
@version 1.0
/*/

User Function UPDNFE01()

    Local aPergs	:= {}
	Private aRet	:= {}
	
    aAdd(aPergs, {1, "Filial"		    , Space(2), "@!", "", "", "", 50, .T.})
	aAdd(aPergs, {1, "Pedido"		    , Space(6), ""  , "", "", "", 50, .T.})
	aAdd(aPergs, {1, "Transportadora"	, Space(6), ""  , "", "", "", 50, .T.})
    aAdd(aPergs, {1, "Tipo Frete"       , Space(1), ""  , "", "", "", 50, .T.})
    
    If ParamBox(aPergs, "Parametros", aRet)
        If MsgYesNo("Aten��o, ao continuar haver� altera��o no banco de dados. Deseja prosseguir?")
            Processa({ || AtlzNfe()},"Aguarde","Atualizando...")
        EndIf
    Else
        Return .F.
    EndIf

Return 

Static Function AtlzNfe()

    Local cQuery1       := ""
    Local cQuery2       := ""
    Local cQueryUPD1    := ""
    Local cQueryUPD2    := ""
    Local cQueryUPD3    := ""
    Local cQueryUPD4    := ""
    Local cQueryUPD5    := ""
    Local cOldTransp
    Local cNotaFis
    Local cSerieNf
    Local nStatus

    // Bloco de sele��o da transportadora antiga
    cQuery1 := " SELECT C5_TRANSP FROM " + RetSQLName("SC5") + " WHERE C5_FILIAL = '" + aRet[1] + "' AND C5_NUM = '" + aRet[2] + "' AND D_E_L_E_T_ <> '*' "

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery1),"QRY1",.T.,.F.)
    DbSelectArea("QRY1")
    QRY1->(dbGoTop())

    cOldTransp := QRY1->C5_TRANSP

    QRY1->(DbCloseArea())
    // Fim do bloco

    // Bloco de sele��o da nota fiscal
    cQuery2 := " SELECT C5_NOTA, C5_SERIE FROM " + RetSQLName("SC5") + " WHERE C5_FILIAL = '" + aRet[1] + "' AND C5_NUM = '" + aRet[1] + "' AND D_E_L_E_T_ <> '*' "

    DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),"QRY2",.T.,.F.)
    DbSelectArea("QRY2")
    QRY2->(dbGoTop())

    cNotaFis := QRY2->C5_NOTA
    cSerieNf := QRY2->C5_SERIE

    QRY2->(DbCloseArea())
    // Fim do bloco

    // Bloco de descri��o dos updates
    cQueryUPD1 := " UPDATE " + RetSQLName("SC5") + " SET C5_TRANSP  = '" + Alltrim(aRet[3]) + "', C5_TPFRETE = '" + Alltrim(aRet[4]) + "' WHERE C5_FILIAL  = '" + Alltrim(aRet[1]) + "' AND C5_NUM = '" + Alltrim(aRet[2]) + "' AND D_E_L_E_T_ <> '*' "
    cQueryUPD2 := " UPDATE " + RetSQLName("SC5") + " SET C5_TRANSP  = '" + Alltrim(aRet[3]) + "' WHERE C5_FILIAL  = '" + Alltrim(aRet[1]) + "' AND C5_NUM = '" + Alltrim(aRet[2]) + "' AND D_E_L_E_T_ <> '*' " "
    cQueryUPD3 := " UPDATE " + RetSQLName("CB7") + " SET CB7_TRANSP = '" + Alltrim(aRet[3]) + "' WHERE CB7_FILIAL = '" + Alltrim(aRet[1]) + "' AND CB7_PEDIDO = '" + Alltrim(aRet[2]) + "' AND D_E_L_E_T_ <> '*' "
    cQueryUPD4 := " UPDATE " + RetSQLName("ZZ5") + " SET ZZ5_TRANSP = '" + Alltrim(aRet[3]) + "' WHERE ZZ5_FILIAL = '" + Alltrim(aRet[1]) + "' AND ZZ5_PEDIDO = '" + Alltrim(aRet[2]) + "' AND D_E_L_E_T_ <> '*' "
    cQueryUPD5 := " UPDATE " + RetSQLName("SF2") + " SET F2_TRANSP = '" + Alltrim(aRet[3]) + "' WHERE F2_FILIAL = '" + Alltrim(aRet[1]) + "' AND F2_DOC = '" + Alltrim(cNotaFis) + "' AND F2_SERIE = '" + Alltrim(cSerieNf) + "' AND D_E_L_E_T_ <> '*' "
    // Fim do bloco

    // Bloco da regra de execu��o dos updates
    If Empty(cOldTransp)
        MsgAlert("Pedido n�o encontrado, revise os par�metros!","Aten��o")
        Return
    Else
        If Alltrim(cOldTransp) == Alltrim(aRet[3])
            MsgAlert("Transportadora informada � igual a atual do pedido, revise os par�metros!","Aten��o")
            Return 
        Else
            If !Empty(aRet[4])

                // Execu��o do cen�rio 1

                nStatus := TCSQLExec(cQueryUPD1)

                If (nStatus < 0)
                    MsgAlert("Update 1: " + TCSQLError(),"Aten��o")
                    Return
                EndIf

                nStatus := TCSQLExec(cQueryUPD3)
                
                If (nStatus < 0)
                    MsgAlert("Update 3: " + TCSQLError(),"Aten��o")
                    Return
                EndIf

                nStatus := TCSQLExec(cQueryUPD4)
                
                If (nStatus < 0)
                    MsgAlert("Update 4: " + TCSQLError(),"Aten��o")
                    Return
                EndIf

                If !Empty(cNotaFis)

                    nStatus := TCSQLExec(cQueryUPD5)
                    
                    If (nStatus < 0)
                        MsgAlert("Update 5: " + TCSQLError(),"Aten��o")
                        Return
                    EndIf

                EndIf

            Else

                // Execu��o do cen�rio 2

                nStatus := TCSQLExec(cQueryUPD2)

                If (nStatus < 0)
                    MsgAlert("Update 2: " + TCSQLError(),"Aten��o")
                    Return
                EndIf

                nStatus := TCSQLExec(cQueryUPD3)
                
                If (nStatus < 0)
                    MsgAlert("Update 3: " + TCSQLError(),"Aten��o")
                    Return
                EndIf

                nStatus := TCSQLExec(cQueryUPD4)
                
                If (nStatus < 0)
                    MsgAlert("Update 4: " + TCSQLError(),"Aten��o")
                    Return
                EndIf

                If !Empty(cNotaFis)

                    nStatus := TCSQLExec(cQueryUPD5)
                    
                    If (nStatus < 0)
                        MsgAlert("Update 5: " + TCSQLError(),"Aten��o")
                        Return
                    EndIf

                EndIf

            EndIf
        EndIf       
    EndIf
    // Fim do bloco

Return