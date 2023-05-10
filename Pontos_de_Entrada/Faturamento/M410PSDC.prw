/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M410PSDC ºAutor  ³Fabio Rogerio     º Data ³  02/14/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exclui a reserva na alteracao do pedido                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M410PSDC()
Local aRet:= {} //Para compatibilizar com o retorno do ponto de entrada                       

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If "MATA310"$Upper(FunName())
	Return .T.
EndIf

If ALTERA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ{˜G{˜G{¿
	//³Estorna a reserva.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ{Ù
	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9")+SC5->C5_NUM,.T.)
	While !Eof() .And. (xFilial("SC9")+SC5->C5_NUM == SC9->(C9_FILIAL+C9_PEDIDO))
	
		If Empty(SC9->C9_NFISCAL)
			U_DIPXRESE("SV_EXC_NEW",SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,SC9->C9_SEQUEN,SC9->C9_QTDLIB-SC9->C9_SALDO,SC9->C9_LOTECTL,SC9->C9_NUMLOTE,SC9->C9_NUMSERI,"","","","","")	
		EndIf	
	         
		dbSelectArea("SC9")
		dbSkip()
	End
EndIf
	
Return(aRet)