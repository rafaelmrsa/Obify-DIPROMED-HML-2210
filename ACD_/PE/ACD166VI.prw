/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO16    �Autor  �Microsiga           � Data �  04/01/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ACD166VI()
Local cCodSep := CB8->CB8_ORDSEP

If AllTrim(CB8->(IndexKey()))<>"CB8_FILIAL+CB8_ORDSEP+CB8_LOCAL+CB8_XLCALI+CB8_PROD+CB8_LOTECT"
	CB8->(dbOrderNickName("CB8XLOCALI"))    
	CB8->(DbSeek(xFilial("CB8")+cCodSep))	
	While !CB8->(Eof()) .and. CB8->(CB8_FILIAL+CB8_ORDSEP)==xFilial("CB8")+cCodSep .And. ( Empty(CB8->CB8_SALDOS) .Or. !Empty(CB8->CB8_OCOSEP) )
		CB8->(DbSkip())
	EndDo
EndIf	

Return .T.