/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M410PSDC �Autor  �Fabio Rogerio     � Data �  02/14/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Exclui a reserva na alteracao do pedido                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function M410PSDC()
Local aRet:= {} //Para compatibilizar com o retorno do ponto de entrada                       

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If "MATA310"$Upper(FunName())
	Return .T.
EndIf

If ALTERA
	//�������������������{�G{�G{�
	//�Estorna a reserva.�
	//�������������������{�
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