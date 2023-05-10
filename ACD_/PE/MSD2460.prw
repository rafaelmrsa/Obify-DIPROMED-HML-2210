/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MSD2460   ºAutor  ³Emerson Leal Bruno  º Data ³  07/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada no faturamento para gravar documento e    º±±
±±º          ³ serie na tabela de orderm de servico do acd			 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MSD2460()

Local aArea    		:= GetArea()
Local aAreaCB7 		:= {}
Local aAreaCB8 		:= {}
Local aAreaCB9 		:= {}
Local cDocum		:= ""
Local cSerie		:= ""
Local cPedido		:= ""
Local cProd			:= ""
Local cLote			:= ""
Local nQtde			:= 0
Local cOrdSep		:= ""

If cEmpAnt$'01/04' 
	
	cDocum	:= SD2->D2_DOC
	cSerie	:= SD2->D2_SERIE
	cPedido	:= SD2->D2_PEDIDO
	cProd	:= SD2->D2_COD
	cLote	:= SD2->D2_LOTECTL
	nQtde	:= SD2->D2_QUANT
	cOrdSep	:= SD2->D2_ORDSEP
	//	lRastro	:= Rastro(cProd)
	
	aAreaCB7 	:= CB7->(GetArea())
	
	CB7->(dBSetOrder(2))  		//CB7_FILIAL+CB7_ORDSEP		
	If CB7->(dBSeek(xFilial("CB7")+cPedido))   
		While !CB7->(Eof()) .And. CB7->CB7_PEDIDO == cPedido
			Begin Transaction
				CB7->(RecLock("CB7",.F.))
					CB7->CB7_NOTA 	:= cDocum
					CB7->CB7_SERIE  := cSerie
				CB7->(MsUnlock())
			End Transaction 
			CB7->(dbSkip())
		EndDo
	EndIf

	RestArea(aAreaCB7)
	
	aAreaCB8 	:= CB8->(GetArea())

	CB8->(dBSetOrder(2))  		//CB8_FILIAL+CB8_ORDSEP
	If CB8->(dBSeek(xFilial("CB8")+cPedido))
		While !CB8->(Eof()) .AND. CB8->CB8_PEDIDO == cPedido
			Begin Transaction
				CB8->(RecLock("CB8",.F.))
					CB8->CB8_NOTA 	:= cDocum
					CB8->CB8_SERIE  := cSerie
				CB8->(MsUnlock())
			End Transaction
			CB8->(DbSkip())
		EndDo
	EndIf
    
	RestArea(aAreaCB8)
	
	cSQL := " SELECT R_E_C_N_O_ REC FROM "+RetSQLName("CB9")
	cSQL += " WHERE CB9_FILIAL = '"+xFilial("CB9")+"' AND "
	cSQL += " CB9_PEDIDO = '"+cPedido+"' AND "  
	cSQL += " CB9_VOLUME <> ' ' AND "
	cSQL += " CB9_XNOTA = ' ' AND "
	cSQL += " CB9_XSERIE = ' ' AND "
	cSQL += " D_E_L_E_T_ = ' ' "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYCB9",.F.,.T. )
    
	aAreaCB9 := CB9->(GetArea())
		
	While !QRYCB9->(Eof())              
		CB9->(dbGoTo(QRYCB9->REC))
		CB9->(RecLock("CB9",.F.))
			CB9->CB9_XNOTA  := cDocum
			CB9->CB9_XSERIE := cSerie
		CB9->(MsUnlock())
		QRYCB9->(dbSkip()) 	
	EndDo	
	QRYCB9->(dbCloseArea())   

	RestArea(aAreaCB9)		

	ZZ5->(dbSetOrder(1))
	If ZZ5->(dbSeek(xFilial("ZZ5")+cPedido))
		While !ZZ5->(Eof()) .And. ZZ5->ZZ5_PEDIDO = cPedido
			If Empty(ZZ5->ZZ5_NOTA)
				ZZ5->(RecLock("ZZ5",.F.))
					ZZ5->ZZ5_NOTA  := cDocum
					ZZ5->ZZ5_SERIE := cSerie
				ZZ5->(MsUnlock())
			EndIf		
			ZZ5->(dbSkip())
		EndDo
	EndIf
	
EndIf

RestArea(aArea)

Return()