#include "protheus.ch"
#include "rwmake.ch"

/*/
{Protheus.doc} MTA650I
Este ponto de entrada é chamado nas funcções: 
A650Inclui (Inclusão de OP's) A650GeraC2 (Gera Op para Produto/Quantidade Informados nos parâmetros).
Será utilizado para geração automática de lote.
@type  Function
@author Felipe Almeida
@since 20/12/2019
@version 1.0
/*/

User Function MTA650I()
	
	//Local cLote := Posicione("SC2",1,xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,"SC2->C2_XLOTECT")
	Local cOP   := SC2->C2_NUM+SC2->C2_ITEM+RIGHT(SC2->C2_SEQUEN,2)
	//Local nRev  := 01
	//Local lRet  := CHKLTD3(cOP,cLote)

	/*
	If Empty(cLote) .Or. !lRet
		If Empty(cLote)
			cLote := SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))
		Else
			nRev := Val(SubStr(SC2->C2_XLOTECT,9,2))+1
			cLote := SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))
		EndIf
		SC2->(RecLock("SC2",.F.))
		SC2->C2_XLOTECT := cLote
		SC2->(MsUnlock())
	Else
		If cLote == SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))
			Return
		Else
            nRev := Val(SubStr(SC2->C2_XLOTECT,9,2))+1
            cLote := SC2->C2_NUM+StrZero(month(Date()),2)+cValToChar(StrZero(nRev,2))

            SC2->(RecLock("SC2",.F.))
            SC2->C2_XLOTECT := cLote
            SC2->(MsUnlock())
		EndIf
	EndIf
	*/

	SC2->(RecLock("SC2",.F.))
	SC2->C2_XLOTECT := cOP
	SC2->(MsUnlock())

	If MsgYesNo("Deseja imprimir etiqueta PI?")
		U_DIPETPI()
	EndIf

Return

/*
Static Function CHKLTD3(cOP,cLote)

	Local cSQL := ""
	Local lRet := .T.

	cSQL := " SELECT D3_LOTECTL "
	cSQL += " FROM "+ RetSQLName("SD3")
	cSQL += " WHERE D3_FILIAL  = '"+xFilial("SD3")+"' "
	cSQL += " AND D3_OP = '"+cOP+"' "
	cSQL += " AND D3_LOTECTL = '"+cLote+"' "
	cSQL += " AND D3_TM = '010' "
	cSQL += " AND D_E_L_E_T_ = ' ' "

	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"LOTEPCP",.T.,.T.)

	If !LOTEPCP->(Eof())
		lRet := .F.
	EndIf

	LOTEPCP->(dbCloseArea())

Return lRet 
*/