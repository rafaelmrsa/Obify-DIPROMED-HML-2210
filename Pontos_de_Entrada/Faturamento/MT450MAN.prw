/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT450MAN  ºAutor  ³Maximo Canuto V. Netoº Data ³ 03/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada executado antes da liberação manual de     º±±
±±º          ³credito                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATUALIZA C5_PRENOTA COM "F"                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT450MAN()

Local lCredito:= IIF(SC9->C9_BLCRED $ "01/04/09",.T.,.F.)
Local lContinua := .T.
Local nValLib	:= Val(GetMV("ES_VALLIB"))  
Local cUsrLib	:= GetMV("ES_XUSRLIB") 
  
U_DIPPROC(ProcName(0),U_DipUsr())

SC5->(MsSeek(xFilial("SC5")+SC9->C9_PEDIDO))

ConOut("MT450MAN - ANTES DE ATUALIZAR C5_PRENOTA")
ConOut("LIBERACAO MANUAL DE CREDITO - Data/Hora: "+ Dtoc(dDatabase)+"-"+time()+" - Usuario: "+ U_DipUsr())
ConOut("PEDIDO-PRENOTA-PARCIAL ->"  +SC5->C5_NUM+" - "+SC5->C5_PRENOTA+" - "+SC5->C5_PARCIAL)

If !Empty(SC5->C5_XBLQNF)
	Aviso("Atenção","Este pedido será rejeitado."+CHR(13)+CHR(10)+"O estorno foi solicitado pelo(a) vendedor(a).",{"Ok"},1)
	u_MTA450R()
	lContinua := .F.
EndIf

If lContinua
	IF  Empty(SC5->C5_PRENOTA) .And. lCredito  
		ConOut("MT450MAN - ANTES DE ATUALIZAR C5_PRENOTA - ENTREI NO IF DESTE PONTO"+SC5->C5_NUM)
		Reclock("SC5",.F.)	
		SC5->C5_PRENOTA := "F"
		SC5->(MsUnLock())
	   	SC5->(DbCommit()) 
	EndIf
EndIf	

//Liberação de pedidos de venda com valor superior ao definido no parametro 

IF (SC9->C9_QTDVEN * SC9->C9_PRCVEN) > nValLib  
	IF !ALLTRIM(RetCodUsr()) $ ALLTRIM(cUsrLib)
		ShowHelpDlg("UA450LibMan", {"ES_XUSRLIB - Você não tem permissão para liberar crédito de Pedidos de Venda com Valor acima de R$ 50.000,00.",""},3,;
		                           {"Selecione um Pedido de Venda com valor menor que R$ 50.000,00.",""},3)    
		lContinua:= .F.                          
	ENDIF
ENDIF


Return(lContinua)
