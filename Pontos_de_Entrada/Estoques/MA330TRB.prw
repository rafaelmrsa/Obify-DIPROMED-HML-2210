#include 'protheus.ch'
#include 'parmtype.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA330TRB �Autor  �Delta Decis�o	   � Data �  21/10/19     ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada no c�lculo do custo m�dio	              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Especifico para Dipromed                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user function MA330TRB()

If cFilAnt == '04'
	dbSelectArea("SD3")
	dbSetOrder(4)
	dbSelectArea("TRB")
	dbSetOrder(2)
	dbSeek(cFilAnt+"SD3")
	Do While !Eof() .And. TRB->TRB_FILIAL+TRB->TRB_ALIAS == cFilAnt+"SD3"
		dbSelectArea("SD3")
		dbGoto(TRB->TRB_RECNO)		
		If SD3->D3_CF == "DE6" .and. SD3->D3_TM == "497" .and. Substr(SD3->D3_DOC,1,3) == "SZP"		
			dbSelectArea("TRB")
			If Reclock("TRB",.F.)
				TRB->(dbDelete())
				TRB->(MsUnlock())
			EndIf			
		EndIf		
		dbSelectArea("TRB")
		dbSkip()
	EndDo
EndIf	
	
return