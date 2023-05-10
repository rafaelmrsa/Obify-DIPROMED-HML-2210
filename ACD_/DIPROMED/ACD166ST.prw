#INCLUDE "PROTHEUS.CH"   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ACD166ST  ºAutor  ³Microsiga           º Data ³  05/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACD166ST()
Local aAreaCB7 := CB7->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local cOrdSep  := PARAMIXB[1]                
Local lRet     := .F.
Local lSepOK  := .T.

CB7->(dbSetOrder(1))
If CB7->(dbSeek(xFilial("CB7")+cOrdSep))


	
	If CB7->CB7_STATUS # "0" .AND. EMPTY(CB7->CB7_STATPA) .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
   		VtBeep(3)
   		If !VTYesNo("Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso",.T.) //###### "Ordem Separacao iniciada pelo operador "+CB7->CB7_CODOPE+". Deseja continuar ?","Aviso"
      		VtKeyboard(Chr(20))  // zera o get
      		lSepOK := .F.
   		EndIf
	EndIf

	If lSepOK
		SC5->(dbSetOrder(1))
		If SC5->(dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO))
			If Empty(SC5->C5_XBLQNF)

				If CB7->CB7_LOCAL == "20"
					VTAlert("ECOMMERCE, LOCAL 20!",.T.,2000)
				EndIf	

				lRet := .T.
			Else 
				VtAlert("Não separar. Foi solicitado o estorno deste pedido.","Aviso",.t.,4000,3)
			EndIf		
		EndIf    
	EndIf

Else
	VtAlert("Ordem de separacao não encontrada. T.I.","Aviso",.t.,4000,3)
EndIf
	
RestArea(aAreaSC5)
RestArea(aAreaCB7)

Return lRet
